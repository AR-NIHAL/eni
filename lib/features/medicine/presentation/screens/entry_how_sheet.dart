import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'add_medicine_screen.dart';

class EntryHowSheet extends StatelessWidget {
  const EntryHowSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EntryHowSheet(),
    );
  }

  void _navigateToTypeIn(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          featureName,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: const Text(
          'Scanning integration is prepared for our upcoming OCR update. Would you like to enter medicine details manually for now?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToTypeIn(context);
            },
            child: const Text('Type it in', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
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
          const SizedBox(height: 24),
          const Text(
            'Add a medicine',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Target: under a minute, with as little typing as possible.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          _buildOptionTile(
            title: 'Scan the pack',
            subtitle: 'Auto-fill name & strength from the box',
            icon: Icons.qr_code_scanner_rounded,
            isHighlighted: false,
            onTap: () => _showComingSoon(context, 'Scan the pack'),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Type it in',
            subtitle: 'Quick stepper and smart chip selections',
            icon: Icons.edit_note_rounded,
            isHighlighted: true,
            onTap: () => _navigateToTypeIn(context),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Prescription photo',
            subtitle: 'Extract medicine list from doctor prescription',
            icon: Icons.document_scanner_outlined,
            isHighlighted: false,
            onTap: () => _showComingSoon(context, 'Prescription photo'),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            title: 'Repeat a past one',
            subtitle: 'Restart a course from previously logged medicines',
            icon: Icons.replay_rounded,
            isHighlighted: false,
            onTap: () => _navigateToTypeIn(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primaryDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlighted ? AppColors.primaryDark : AppColors.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.white.withValues(alpha: 0.15)
                      : AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isHighlighted ? AppColors.accentLime : AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isHighlighted ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isHighlighted ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isHighlighted ? AppColors.white.withValues(alpha: 0.6) : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
