import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicine_providers.dart';

class StockRefillCard extends ConsumerWidget {
  final MedicineEntity medicine;

  const StockRefillCard({
    super.key,
    required this.medicine,
  });

  void _showRefillSheet(BuildContext context, WidgetRef ref) {
    int addedStock = 30;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final currentStock = medicine.stockRemaining ?? 0;
          final newTotal = currentStock + addedStock;
          final dailyDoses = medicine.schedule.times.isEmpty ? 1 : medicine.schedule.times.length;
          final daysLeft = (newTotal / dailyDoses).floor();

          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refill ${medicine.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Current stock: $currentStock ${medicine.doseUnit}s',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stepper bar (matching Medico dark capsule style)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B24),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: addedStock > 5
                            ? () => setSheetState(() => addedStock -= 5)
                            : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2A34),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.remove_rounded, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '+$addedStock',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${medicine.doseUnit}s',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF9E9BA6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setSheetState(() => addedStock += 5),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.accentLime,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.add_rounded, size: 22, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Quick pack presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [10, 20, 30, 60].map((pack) {
                    final isSelected = addedStock == pack;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => setSheetState(() => addedStock = pack),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryDark : AppColors.cardBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '+$pack',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Live Prediction text
                Center(
                  child: Text(
                    'New total: $newTotal ${medicine.doseUnit}s (~$daysLeft days of supply)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm Refill button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentLime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    onPressed: () async {
                      final updated = medicine.copyWith(stockRemaining: newTotal);
                      await ref.read(updateMedicineUseCaseProvider)(updated);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.accentLime),
                                const SizedBox(width: 12),
                                Text(
                                  'Added $addedStock ${medicine.doseUnit}s to stock!',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primaryDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 20, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Refill',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = medicine.stockRemaining;
    final isLow = medicine.isLowStock;
    final dailyDoses = medicine.schedule.times.isEmpty ? 1 : medicine.schedule.times.length;
    final daysLeft = stock != null ? (stock / dailyDoses).floor() : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLow ? AppColors.warning.withValues(alpha: 0.6) : AppColors.cardBorder,
          width: isLow ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primaryDark),
                  SizedBox(width: 8),
                  Text(
                    'Supply & Refill',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isLow && stock != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        stock == 0 ? 'Out of stock' : 'Refill soon ($stock left)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock != null ? '$stock' : 'Untracked',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock != null
                        ? '${medicine.doseUnit}s remaining${daysLeft != null ? " • ~$daysLeft days left" : ""}'
                        : 'Tap refill to set initial stock',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showRefillSheet(context, ref),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.black),
                label: const Text(
                  'Refill',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
