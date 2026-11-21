import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_duration_entity.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/medicine_schedule_entity.dart';
import '../providers/medicine_providers.dart';
import 'duration_selector_chips.dart';
import 'time_chips_selector.dart';

class EditMedicineBottomSheet extends ConsumerStatefulWidget {
  final MedicineEntity medicine;

  const EditMedicineBottomSheet({
    super.key,
    required this.medicine,
  });

  static Future<void> show(BuildContext context, MedicineEntity medicine) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditMedicineBottomSheet(medicine: medicine),
    );
  }

  @override
  ConsumerState<EditMedicineBottomSheet> createState() => _EditMedicineBottomSheetState();
}

class _EditMedicineBottomSheetState extends ConsumerState<EditMedicineBottomSheet> {
  late TextEditingController _strengthController;
  late TextEditingController _stockController;
  late num _doseQuantity;
  late List<TimeOfDay> _scheduleTimes;
  late CourseDurationType _durationType;
  late int _daysCount;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _strengthController = TextEditingController(text: widget.medicine.strength ?? '');
    _stockController = TextEditingController(
      text: widget.medicine.stockRemaining != null ? '${widget.medicine.stockRemaining}' : '',
    );
    _doseQuantity = widget.medicine.doseQuantity;
    _scheduleTimes = List<TimeOfDay>.from(widget.medicine.schedule.times);
    _durationType = widget.medicine.duration.durationType;
    _daysCount = widget.medicine.duration.daysCount ?? 14;
  }

  @override
  void dispose() {
    _strengthController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_scheduleTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one schedule reminder time.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final stockText = _stockController.text.trim();
    final stockVal = stockText.isNotEmpty ? int.tryParse(stockText) : null;

    final updatedDuration = CourseDurationEntity(
      durationType: _durationType,
      daysCount: _durationType == CourseDurationType.days ? _daysCount : null,
      startDate: widget.medicine.duration.startDate,
      endDate: _durationType == CourseDurationType.days
          ? widget.medicine.duration.startDate.add(Duration(days: _daysCount))
          : null,
    );

    final updatedSchedule = MedicineScheduleEntity(
      frequency: widget.medicine.schedule.frequency,
      specificDays: widget.medicine.schedule.specificDays,
      times: _scheduleTimes,
    );

    final updatedMedicine = widget.medicine.copyWith(
      strength: _strengthController.text.trim().isNotEmpty
          ? _strengthController.text.trim()
          : null,
      doseQuantity: _doseQuantity,
      duration: updatedDuration,
      schedule: updatedSchedule,
      stockRemaining: stockVal,
    );

    await ref.read(updateMedicineUseCaseProvider)(updatedMedicine);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
              const SizedBox(width: 10),
              Text(
                'Updated ${widget.medicine.name}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Medicine',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.medicine.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 20, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Form Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strength & Unit
                  const Text(
                    'Strength / Power',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _strengthController,
                    decoration: InputDecoration(
                      hintText: 'e.g. 50 mg, 500 mg',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dose Stepper
                  const Text(
                    'Dose Quantity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B24),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_doseQuantity > 1) {
                              setState(() => _doseQuantity -= 1);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C2A34),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.remove_rounded, size: 18, color: Colors.white),
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
                                '$_doseQuantity',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.medicine.doseUnit,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9E9BA6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _doseQuantity += 1);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.accentLime,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.add_rounded, size: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Schedule Times
                  const Text(
                    'Reminder Schedule Times',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TimeChipsSelector(
                    times: _scheduleTimes,
                    onTimeAdded: (newTime) {
                      setState(() {
                        if (!_scheduleTimes.any((t) => t.hour == newTime.hour && t.minute == newTime.minute)) {
                          _scheduleTimes.add(newTime);
                        }
                      });
                    },
                    onTimeRemoved: (removedTime) {
                      setState(() {
                        if (_scheduleTimes.length > 1) {
                          _scheduleTimes.removeWhere((t) => t.hour == removedTime.hour && t.minute == removedTime.minute);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Course Duration
                  const Text(
                    'Course Duration',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DurationSelectorChips(
                    durationType: _durationType,
                    daysCount: _daysCount,
                    onTypeChanged: (type) => setState(() => _durationType = type),
                    onDaysChanged: (days) => setState(() => _daysCount = days),
                  ),
                  const SizedBox(height: 20),

                  // Stock Remaining
                  const Text(
                    'Remaining Stock / Inventory',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 24 pills (leave empty for unlimited)',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
