import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/medicine_ocr_parser.dart';
import '../../../../core/services/ocr_scanner_service.dart';
import '../providers/medicine_providers.dart';

class ScanPackBottomSheet extends ConsumerStatefulWidget {
  const ScanPackBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ScanPackBottomSheet(),
    );
  }

  @override
  ConsumerState<ScanPackBottomSheet> createState() => _ScanPackBottomSheetState();
}

class _ScanPackBottomSheetState extends ConsumerState<ScanPackBottomSheet> {
  bool _isProcessing = false;

  Future<void> _handleOcrResult(MedicineOcrResult result) async {
    final notifier = ref.read(addMedicineProvider.notifier);

    // Reset before pre-filling
    notifier.reset();

    if (result.name != null && result.name!.isNotEmpty) {
      notifier.setName(result.name!);
    }
    if (result.strength != null && result.strength!.isNotEmpty) {
      notifier.setStrength(result.strength!);
    }
    if (result.type != null) {
      notifier.setType(result.type!);
    }
    if (result.imagePath != null) {
      notifier.setPhotoPath(result.imagePath);
    }

    if (!mounted) return;
    Navigator.pop(context); // Close bottom sheet

    // Navigate to AddMedicineScreen form
    context.push(AppRoutes.addMedicineForm);

    final autoFillSummary = [
      if (result.name != null) result.name,
      if (result.strength != null) result.strength,
    ].join(' ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                autoFillSummary.isNotEmpty
                    ? 'Auto-filled: $autoFillSummary'
                    : 'Scanned packet! Please verify details.',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _scanCamera() async {
    setState(() => _isProcessing = true);
    try {
      final result = await OcrScannerService.instance.scanFromCamera();
      if (result != null) {
        await _handleOcrResult(result);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _scanGallery() async {
    setState(() => _isProcessing = true);
    try {
      final result = await OcrScannerService.instance.scanFromGallery();
      if (result != null) {
        await _handleOcrResult(result);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _useSample(String sampleName) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth simulation
    final result = OcrScannerService.getSampleScan(sampleName);
    await _handleOcrResult(result);
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  color: AppColors.accentLime,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Medicine Pack',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Auto-extract name, power (mg), and form',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isProcessing) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primaryDark),
                  SizedBox(height: 16),
                  Text(
                    'Scanning & extracting text...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Reading medicine name and strength (mg)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Main Capture Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Take Photo',
                    subtitle: 'Use camera',
                    onTap: _scanCamera,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.photo_library_rounded,
                    title: 'Gallery',
                    subtitle: 'Choose photo',
                    onTap: _scanGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Samples Section
            const Text(
              'Or test with a sample packet:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSampleChip('Maxpro 20mg', () => _useSample('maxpro')),
                _buildSampleChip('Pregabalin 75mg', () => _useSample('pregabalin')),
                _buildSampleChip('Augmentin 625mg', () => _useSample('augmentin')),
                _buildSampleChip('Napa Extra 500mg', () => _useSample('paracetamol')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder, width: 0.8),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accentLime, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.cardBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 13, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
