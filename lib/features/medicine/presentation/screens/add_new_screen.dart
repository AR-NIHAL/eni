import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/medicine_providers.dart';
import '../widgets/pill_scanner_graphic.dart';
import '../widgets/scan_pack_bottom_sheet.dart';

enum AddNewTab {
  medicine,
  doctorVisit,
  refill;

  String get label {
    switch (this) {
      case AddNewTab.medicine:
        return 'Medicine';
      case AddNewTab.doctorVisit:
        return 'Doctor visit';
      case AddNewTab.refill:
        return 'Refill';
    }
  }
}

class AddNewScreen extends ConsumerStatefulWidget {
  const AddNewScreen({super.key});

  @override
  ConsumerState<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends ConsumerState<AddNewScreen> {
  AddNewTab _selectedTab = AddNewTab.medicine;

  void _navigateToTypeIn() {
    context.push(AppRoutes.addMedicineForm);
  }

  void _onScanPack() {
    ScanPackBottomSheet.show(context);
  }

  void _showComingSoon(String featureTitle, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          featureTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          description,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToTypeIn();
            },
            child: const Text('Type it in instead'),
          ),
        ],
      ),
    );
  }

  void _showRepeatMedicinePicker() {
    final medicines = ref.read(medicinesStreamProvider).value ?? [];

    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No past medicines found. Let\'s type it in!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _navigateToTypeIn();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Repeat a past medicine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...medicines.map((med) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(med.type.icon, color: AppColors.primaryDark),
                  ),
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${med.doseQuantity} ${med.doseUnit} • ${med.schedule.frequency.displayName}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    // Pre-fill form notifier with existing medicine data
                    final notifier = ref.read(addMedicineProvider.notifier);
                    notifier.setName(med.name);
                    notifier.setPurpose(med.purpose ?? '');
                    notifier.setType(med.type);
                    notifier.setDoseQuantity(med.doseQuantity);
                    notifier.setFrequency(med.schedule.frequency);
                    _navigateToTypeIn();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicines = ref.watch(medicinesStreamProvider).value ?? [];

    // Format repeat subtitle text dynamically
    String repeatSubtitle = 'Select from your past prescriptions';
    if (medicines.isNotEmpty) {
      final names = medicines.take(2).map((m) => m.name).join(', ');
      final remainingCount = medicines.length - 2;
      if (remainingCount > 0) {
        repeatSubtitle = '$names and $remainingCount more';
      } else {
        repeatSubtitle = names;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Add new',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const [
          SizedBox(width: 56), // Balance the leading back button
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Pill Tab Bar (Medicine / Doctor visit / Refill)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Row(
                  children: AddNewTab.values.map((tab) {
                    final isSelected = tab == _selectedTab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentLime : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentLime.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Tab 1: Medicine View (Hero Card + 3 Secondary options)
              if (_selectedTab == AddNewTab.medicine) ...[
                // Hero Card: Scan the pack
                GestureDetector(
                  onTap: _onScanPack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fastest Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Fastest',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Centerpiece Illustration with Scanner Reticle Brackets
                        const Center(
                          child: PillScannerGraphic(size: 150),
                        ),
                        const SizedBox(height: 20),

                        // Bottom Row: Text & Camera circular button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan the pack',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Box, strip or bottle label',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                size: 24,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Section Title: Or add it another way
                const Text(
                  'Or add it another way',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Option 1: Type it in
                _buildSecondaryOptionTile(
                  icon: Icons.keyboard_outlined,
                  title: 'Type it in',
                  subtitle: 'Name, dose and times',
                  onTap: _navigateToTypeIn,
                ),
                const SizedBox(height: 12),

                // Option 2: Prescription photo
                _buildSecondaryOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Prescription photo',
                  subtitle: 'Medico reads it for you',
                  onTap: _onScanPack,
                ),
                const SizedBox(height: 12),

                // Option 3: Repeat a past medicine
                _buildSecondaryOptionTile(
                  icon: Icons.history_rounded,
                  title: 'Repeat a past medicine',
                  subtitle: repeatSubtitle,
                  onTap: _showRepeatMedicinePicker,
                ),
              ],

              // Tab 2: Doctor visit
              if (_selectedTab == AddNewTab.doctorVisit) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.cardBorder, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 32,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Doctor Visit Tracker',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep track of doctor consultations, prescriptions, and follow-up appointment reminders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showComingSoon(
                          'Doctor Visit',
                          'Doctor Visit appointment tracker is part of our upcoming consultation module.',
                        ),
                        icon: const Icon(Icons.add, color: AppColors.white),
                        label: const Text('Add doctor appointment', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Tab 3: Refill
              if (_selectedTab == AddNewTab.refill) ...[
                if (medicines.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardBorder, width: 0.8),
                    ),
                    child: const Center(
                      child: Text(
                        'No medicines added yet to refill.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a medicine to refill stock:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ...medicines.map((med) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Icon(med.type.icon, color: AppColors.primaryDark),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(med.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                      Text('${med.stockRemaining ?? 0} ${med.doseUnit}s remaining', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final updated = med.copyWith(
                                      stockRemaining: (med.stockRemaining ?? 0) + 30,
                                    );
                                    ref.read(updateMedicineUseCaseProvider)(updated);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Added 30 ${med.doseUnit}s to ${med.name}!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  ),
                                  child: const Text('+30'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryOptionTile({
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
