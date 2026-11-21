import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/medico_button.dart';
import '../providers/medicine_providers.dart';
import '../widgets/duration_selector_chips.dart';
import '../widgets/instructions_chips_selector.dart';
import '../widgets/scan_pack_bottom_sheet.dart';
import '../widgets/time_chips_selector.dart';
import '../widgets/type_selector_chips.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _purposeController;
  late final TextEditingController _strengthController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(addMedicineProvider);
    _nameController = TextEditingController(text: state.name);
    _purposeController = TextEditingController(text: state.purpose);
    _strengthController = TextEditingController(text: state.strength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final formNotifier = ref.read(addMedicineProvider.notifier);
    formNotifier.setName(_nameController.text.trim());
    formNotifier.setPurpose(_purposeController.text.trim());
    formNotifier.setStrength(_strengthController.text.trim());

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a medicine name to continue'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final state = ref.read(addMedicineProvider);
    if (state.reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one reminder time under Remind me'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    context.push(AppRoutes.addMedicineReview);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMedicineProvider);
    final notifier = ref.read(addMedicineProvider.notifier);

    // Synchronize text controllers with state (e.g. after OCR auto-fill)
    if (_nameController.text != state.name && state.name.isNotEmpty) {
      _nameController.text = state.name;
    }
    if (_strengthController.text != state.strength && state.strength.isNotEmpty) {
      _strengthController.text = state.strength;
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
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.primaryDark),
              ),
            ),
          ),
        ),
        title: const Text('Add medicine'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: const Text(
                'Step 1 of 2',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    // Card 1: Medicine Name & Visual Placeholder
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    'MEDICINE NAME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _nameController,
                                  onChanged: notifier.setName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Pregabalin',
                                    hintStyle: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Camera / Photo Placeholder Box as in Wireframe (displays scanned packet photo)
                          GestureDetector(
                            onTap: () => ScanPackBottomSheet.show(context),
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: state.photoPath != null ? AppColors.accentLime : AppColors.cardBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: state.photoPath != null &&
                                        !kIsWeb &&
                                        File(state.photoPath!).existsSync()
                                    ? Image.file(
                                        File(state.photoPath!),
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.photo_camera_outlined,
                                          size: 28,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: What it's for, Strength, & Dose Stepper (exact structure from reference)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppColors.cardBorder.withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Section: What it's for
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "What it's for",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: _purposeController,
                                      onChanged: notifier.setPurpose,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Lower back pain',
                                        hintStyle: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                        ),
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24, thickness: 0.8, color: AppColors.cardBorder),

                          // Middle Section: Strength
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Strength',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: _strengthController,
                                      onChanged: notifier.setStrength,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. 500 mg',
                                        hintStyle: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                        ),
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24, thickness: 0.8, color: AppColors.cardBorder),

                          // Bottom Section: Dose & Centered Stepper (- on left, + on right, dose in center matching reference)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dose',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1B24),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    // Minus Button (Left, dark circular button)
                                    GestureDetector(
                                      onTap: () {
                                        if (state.doseQuantity > 1) {
                                          notifier.setDoseQuantity(state.doseQuantity - 1);
                                        }
                                      },
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2C2A34),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Center: 1 capsule (Large bold number + unit)
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '${state.doseQuantity}',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            state.type.displayName.toLowerCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF9E9BA6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Plus Button (Right, vibrant lime circular button with dark plus)
                                    GestureDetector(
                                      onTap: () {
                                        notifier.setDoseQuantity(state.doseQuantity + 1);
                                      },
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentLime,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section: Type
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TypeSelectorChips(
                      selectedType: state.type,
                      onTypeSelected: notifier.setType,
                    ),
                    const SizedBox(height: 24),

                    // Section: Remind me
                    const Text(
                      'Remind me',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TimeChipsSelector(
                      times: state.reminderTimes,
                      onTimeAdded: notifier.addReminderTime,
                      onTimeRemoved: notifier.removeReminderTime,
                    ),
                    const SizedBox(height: 24),

                    // Section: Duration
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DurationSelectorChips(
                      durationType: state.durationType,
                      daysCount: state.daysCount,
                      onTypeChanged: notifier.setDurationType,
                      onDaysChanged: notifier.setDaysCount,
                    ),
                    const SizedBox(height: 24),

                    // Section: Instructions
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InstructionsChipsSelector(
                      selectedInstructions: state.instructions,
                      onToggle: notifier.toggleInstruction,
                    ),
                    const SizedBox(height: 24),

                    // Section: Inventory & Refill Tracking Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppColors.cardBorder.withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row with Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: state.trackRefill
                                            ? AppColors.accentLime.withValues(alpha: 0.25)
                                            : AppColors.surfaceSubtle,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 20,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Track inventory & refills',
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Get alerts before doses run out',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: state.trackRefill,
                                onChanged: notifier.setTrackRefill,
                                activeTrackColor: AppColors.accentLime,
                                activeThumbColor: AppColors.primaryDark,
                              ),
                            ],
                          ),

                          if (state.trackRefill) ...[
                            const SizedBox(height: 18),
                            const Divider(height: 1, thickness: 0.8, color: AppColors.cardBorder),
                            const SizedBox(height: 16),

                            // Current Supply Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Current supply',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(state.stockRemaining / (state.reminderTimes.isEmpty ? 1 : state.reminderTimes.length)).floor()} days left',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Current Supply Stepper Bar (Dark stadium matching Dose stepper)
                            Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B24),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  // Minus
                                  GestureDetector(
                                    onTap: () {
                                      if (state.stockRemaining > 1) {
                                        notifier.setStockRemaining(state.stockRemaining - 1);
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
                                        child: Icon(Icons.remove_rounded, size: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),

                                  // Center stock count
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${state.stockRemaining}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          state.type.displayName.toLowerCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF9E9BA6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Plus
                                  GestureDetector(
                                    onTap: () {
                                      notifier.setStockRemaining(state.stockRemaining + 1);
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

                            const SizedBox(height: 10),

                            // Quick Pack Presets: 10, 20, 30, 60
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [10, 20, 30, 60].map((pack) {
                                final isSelected = state.stockRemaining == pack;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () => notifier.setStockRemaining(pack),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryDark
                                            : AppColors.surfaceSubtle,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        '$pack pack',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),
                            const Divider(height: 1, thickness: 0.8, color: AppColors.cardBorder),
                            const SizedBox(height: 16),

                            // Alert Threshold Header
                            const Text(
                              'Remind me when supply drops to',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Alert Threshold Stepper
                            Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B24),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (state.refillAlertThreshold > 1) {
                                        notifier.setRefillAlertThreshold(state.refillAlertThreshold - 1);
                                      }
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
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
                                          '${state.refillAlertThreshold}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${state.type.displayName.toLowerCase()} left',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF9E9BA6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      notifier.setRefillAlertThreshold(state.refillAlertThreshold + 1);
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
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
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Continue Button below Track & Inventory Refills
                    MedicoButton(
                      label: 'Continue',
                      onPressed: _onContinue,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
