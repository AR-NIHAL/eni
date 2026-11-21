import '../utils/text_sanitizer.dart';
import '../../features/medicine/domain/entities/medicine_type.dart';

class MedicineOcrResult {
  final String? name;
  final String? strength;
  final MedicineType? type;
  final String? imagePath;
  final String rawText;

  MedicineOcrResult({
    this.name,
    this.strength,
    this.type,
    this.imagePath,
    required this.rawText,
  });

  bool get hasData => name != null || strength != null || type != null;
}

class MedicineOcrParser {
  MedicineOcrParser._();

  // Common pharmaceutical metadata and junk words to exclude when finding medicine name
  static final Set<String> _junkWords = {
    'usp',
    'bp',
    'inn',
    'rx',
    'rx only',
    'batch',
    'lot',
    'mfg',
    'exp',
    'date',
    'mrp',
    'bdt',
    'tk',
    'dar',
    'lic',
    'no',
    'nos',
    'strip',
    'box',
    'bottle',
    'pack',
    'tablet',
    'tablets',
    'capsule',
    'capsules',
    'cap',
    'tabs',
    'tab',
    'syrup',
    'suspension',
    'drops',
    'injection',
    'mg',
    'mcg',
    'ml',
    'gm',
    'g',
    'iu',
    'film',
    'coated',
    'film-coated',
    'enteric',
    'enteric-coated',
    'modified',
    'release',
    'extended',
    'sustained',
    'delayed',
    'orally',
    'disintegrating',
    'oral',
    'use',
    'only',
    'for',
    'store',
    'below',
    'degree',
    'celsius',
    'keep',
    'out',
    'of',
    'reach',
    'children',
    'manufactured',
    'marketed',
    'by',
    'ltd',
    'limited',
    'pharma',
    'pharmaceuticals',
    'laboratories',
    'healthcare',
    'darl',
    'reg',
  };

  /// Parses raw recognized text lines and extracts medicine name, strength, and type
  static MedicineOcrResult parse(String rawText, {String? imagePath}) {
    if (rawText.trim().isEmpty) {
      return MedicineOcrResult(rawText: rawText, imagePath: imagePath);
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 1)
        .toList();

    // 1. Extract Strength / Power (e.g. "20mg", "75 mg", "500mg + 65mg", "800/160mg")
    String? extractedStrength = _extractStrength(rawText);

    // 2. Extract Medicine Form / Type (e.g. Capsule, Tablet, Syrup, etc.)
    MedicineType? extractedType = _extractMedicineType(rawText);

    // 3. Extract Medicine Name
    String? extractedName = _extractMedicineName(lines, extractedStrength);

    return MedicineOcrResult(
      name: extractedName,
      strength: extractedStrength,
      type: extractedType,
      imagePath: imagePath,
      rawText: rawText,
    );
  }

  static String? _extractStrength(String text) {
    // Check composite like 500mg + 65mg
    final compositeRegex = RegExp(
      r'(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml)\s*[\+\/]\s*(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml)?',
      caseSensitive: false,
    );
    final compositeMatch = compositeRegex.firstMatch(text);
    if (compositeMatch != null) {
      final val1 = compositeMatch.group(1);
      final unit1 = compositeMatch.group(2)?.toLowerCase();
      final val2 = compositeMatch.group(3);
      final unit2 = compositeMatch.group(4)?.toLowerCase() ?? unit1;
      return '$val1$unit1 + $val2$unit2';
    }

    // Check ratio like 800/160 mg
    final ratioRegex = RegExp(
      r'(\d+)\s*\/\s*(\d+)\s*(mg|mcg|g|ml)',
      caseSensitive: false,
    );
    final ratioMatch = ratioRegex.firstMatch(text);
    if (ratioMatch != null) {
      return '${ratioMatch.group(1)}/${ratioMatch.group(2)}${ratioMatch.group(3)?.toLowerCase()}';
    }

    // Standard strength (e.g. 20 mg, 75mg, 500 mg, 5ml, 0.5 mg)
    final standardRegex = RegExp(
      r'\b(\d+(?:\.\d+)?)\s*(mg|mcg|ml|iu|g|%)\b',
      caseSensitive: false,
    );
    final match = standardRegex.firstMatch(text);
    if (match != null) {
      final value = match.group(1);
      final unit = match.group(2)?.toLowerCase();
      return '$value$unit';
    }

    return null;
  }

  static MedicineType? _extractMedicineType(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('capsule') || lower.contains('cap ') || lower.contains('caps')) {
      return MedicineType.capsule;
    }
    if (lower.contains('tablet') || lower.contains('tablets') || lower.contains('tab ') || lower.contains('tabs')) {
      return MedicineType.tablet;
    }
    if (lower.contains('syrup') || lower.contains('suspension') || lower.contains('oral solution')) {
      return MedicineType.syrup;
    }
    if (lower.contains('drop') || lower.contains('drops')) {
      return MedicineType.drops;
    }
    if (lower.contains('inhaler') || lower.contains('inhalation') || lower.contains('spray')) {
      return MedicineType.inhaler;
    }
    if (lower.contains('injection') || lower.contains('inj') || lower.contains('vial') || lower.contains('ampoule')) {
      return MedicineType.injection;
    }
    if (lower.contains('powder') || lower.contains('sachet')) {
      return MedicineType.powder;
    }

    return null;
  }

  static String? _extractMedicineName(List<String> lines, String? strength) {
    for (final line in lines) {
      // 1. Strip strength and number patterns from the line first
      String lineWithoutNumbers = line
          .replaceAll(
            RegExp(r'\b\d+(?:\.\d+)?\s*[\+\/]\s*\d+(?:\.\d+)?\s*(mg|mcg|ml|g|iu|%)\b', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'\b\d+(?:\.\d+)?\s*(mg|mcg|ml|iu|g|%)\b', caseSensitive: false),
            '',
          )
          .replaceAll(RegExp(r'\b\d+\s*[\+\/]\s*\d+\b'), '') // e.g. 800/160
          .replaceAll(RegExp(r'\b\d+\b'), ''); // standalone numbers e.g. 20, 75

      // 2. Clean candidate line
      final clean = _cleanCandidateLine(lineWithoutNumbers);
      if (clean == null || clean.length < 3) continue;

      // 3. Strip common generic/type words
      final nameCandidate = clean.replaceAll(
        RegExp(
          r'\b(capsules?|tablets?|syrup|drops?|suspension|injection|mg|mcg|ml|usp|bp|inn)\b',
          caseSensitive: false,
        ),
        '',
      ).trim();

      // Check if after stripping it still has a valid brand/medicine name
      if (nameCandidate.length >= 3 && !_isAllJunk(nameCandidate)) {
        return _formatMedicineName(nameCandidate);
      }
    }

    return null;
  }

  static String? _cleanCandidateLine(String line) {
    // Remove symbols and multiple spaces
    var cleaned = line.replaceAll(RegExp(r'[^\w\s\-]'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    final words = cleaned.split(' ');
    // Filter out standalone junk tokens
    final filtered = words.where((w) {
      final lw = w.toLowerCase();
      return !_junkWords.contains(lw);
    }).toList();

    if (filtered.isEmpty) return null;
    return filtered.join(' ');
  }

  static bool _isAllJunk(String candidate) {
    final words = candidate.toLowerCase().split(RegExp(r'\s+'));
    return words.every((w) => _junkWords.contains(w) || w.length <= 1);
  }

  static String _formatMedicineName(String name) {
    return TextSanitizer.capitalizeWords(name);
  }
}
