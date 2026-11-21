import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../medicine/domain/entities/medicine_entity.dart';
import '../../../medicine/domain/entities/medicine_type.dart';

class MedicineAvatarBadge extends StatelessWidget {
  final MedicineEntity medicine;
  final double size;

  const MedicineAvatarBadge({
    super.key,
    required this.medicine,
    this.size = 46,
  });

  bool get _isAmberTablet {
    final nameLower = medicine.name.toLowerCase();
    if (nameLower.contains('ibuprofen') ||
        nameLower.contains('advil') ||
        nameLower.contains('motrin') ||
        nameLower.contains('aspirin')) {
      return true;
    }
    // If not specifically Bactrim/white, use hash for variety when tablet
    if (nameLower.contains('bactrim') || nameLower.contains('paracetamol')) {
      return false;
    }
    return medicine.name.hashCode.abs() % 2 == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF24212D),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Center(
        child: _buildGraphic(),
      ),
    );
  }

  Widget _buildGraphic() {
    switch (medicine.type) {
      case MedicineType.capsule:
        return _build3dCapsule();
      case MedicineType.tablet:
        return _build3dTablet(isAmber: _isAmberTablet);
      case MedicineType.drops:
        return _buildDropsIcon();
      case MedicineType.syrup:
        return _buildSyrupIcon();
      case MedicineType.inhaler:
      case MedicineType.injection:
      case MedicineType.powder:
      case MedicineType.other:
        return Icon(
          medicine.type.icon,
          size: size * 0.45,
          color: AppColors.accentLime,
        );
    }
  }

  Widget _build3dCapsule() {
    final width = size * 0.62;
    final height = size * 0.30;

    return Transform.rotate(
      angle: -0.62, // ~35 degrees
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Row(
            children: [
              // Lime/green left half
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFEAFF66),
                        Color(0xFFC0EC10),
                        Color(0xFF90B800),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.only(top: 1.5, left: 3, right: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              // Pearl white right half
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFEDE9E0),
                        Color(0xFFD6D1C6),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.only(top: 1.5, left: 1, right: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3dTablet({required bool isAmber}) {
    final width = size * 0.62;
    final height = size * 0.30;

    final gradientColors = isAmber
        ? const [
            Color(0xFFFFC554),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
          ]
        : const [
            Color(0xFFFFFFFF),
            Color(0xFFF1F1F6),
            Color(0xFFD2D2DE),
          ];

    return Transform.rotate(
      angle: -0.62,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 2.5,
            margin: const EdgeInsets.only(top: 1.5, left: 4, right: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isAmber ? 0.6 : 0.8),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropsIcon() {
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        width: size * 0.44,
        height: size * 0.52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7DD3FC),
              Color(0xFF0284C7),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Align(
          alignment: const Alignment(-0.3, -0.4),
          child: Container(
            width: 3,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyrupIcon() {
    return Icon(
      Icons.medication_liquid_rounded,
      size: size * 0.5,
      color: const Color(0xFFFFB74D),
    );
  }
}
