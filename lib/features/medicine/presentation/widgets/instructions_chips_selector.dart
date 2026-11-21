import 'package:flutter/material.dart';
import '../../../../core/widgets/medico_chip.dart';

class InstructionsChipsSelector extends StatelessWidget {
  final List<String> selectedInstructions;
  final ValueChanged<String> onToggle;

  static const List<String> presetInstructions = [
    'With food',
    'Before food',
    'After food',
    'With water',
    'Avoid alcohol',
    'Do not crush',
  ];

  const InstructionsChipsSelector({
    super.key,
    required this.selectedInstructions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetInstructions.map((instruction) {
        final isSelected = selectedInstructions.contains(instruction);
        return MedicoChip(
          label: instruction,
          isSelected: isSelected,
          onTap: () => onToggle(instruction),
        );
      }).toList(),
    );
  }
}
