import 'package:flutter_test/flutter_test.dart';
import 'package:medico/core/services/medicine_ocr_parser.dart';
import 'package:medico/features/medicine/domain/entities/medicine_type.dart';

void main() {
  group('MedicineOcrParser Tests', () {
    test('extracts Maxpro 20mg capsule correctly', () {
      const text = '''
Maxpro 20 mg Capsule
Esomeprazole Magnesium Trihydrate USP
20 mg
Renata Limited
Batch: E204
Exp: 12/28
''';

      final result = MedicineOcrParser.parse(text);
      expect(result.name, 'Maxpro');
      expect(result.strength, '20mg');
      expect(result.type, MedicineType.capsule);
    });

    test('extracts Pregabalin 75mg correctly', () {
      const text = '''
Pregabalin 75mg Capsules
Each hard gelatin capsule contains Pregabalin INN 75 mg
Square Pharmaceuticals Ltd.
''';

      final result = MedicineOcrParser.parse(text);
      expect(result.name, 'Pregabalin');
      expect(result.strength, '75mg');
      expect(result.type, MedicineType.capsule);
    });

    test('extracts Augmentin 625mg tablet correctly', () {
      const text = '''
Augmentin 625mg Tablets
Amoxicillin and Clavulanate Potassium Tablets USP
625 mg
GSK
''';

      final result = MedicineOcrParser.parse(text);
      expect(result.name, 'Augmentin');
      expect(result.strength, '625mg');
      expect(result.type, MedicineType.tablet);
    });

    test('extracts composite strength like Napa Extra 500mg + 65mg', () {
      const text = '''
Napa Extra 500mg + 65mg
Paracetamol 500 mg and Caffeine 65 mg
Beximco Pharmaceuticals Ltd
''';

      final result = MedicineOcrParser.parse(text);
      expect(result.name, 'Napa Extra');
      expect(result.strength, '500mg + 65mg');
    });

    test('extracts ratio strength like Bactrim DS 800/160mg', () {
      const text = '''
Bactrim DS 800/160mg
Sulfamethoxazole and Trimethoprim
''';

      final result = MedicineOcrParser.parse(text);
      expect(result.name, 'Bactrim Ds');
      expect(result.strength, '800/160mg');
    });
  });
}
