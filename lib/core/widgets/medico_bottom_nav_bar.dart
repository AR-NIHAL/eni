import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MedicoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const MedicoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            // Left Group: Home and History buttons
            _buildTabButton(
              index: 0,
              icon: Icons.home_rounded,
              isSelected: currentIndex == 0,
            ),
            const SizedBox(width: 12),
            _buildTabButton(
              index: 1,
              icon: Icons.bar_chart_rounded,
              isSelected: currentIndex == 1,
            ),

            const Spacer(),

            // Right Group: White wide pill for Add
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : const Color(0xFF222222),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: isSelected ? AppColors.primaryDark : const Color(0xFFB0B0B0),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 96,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              size: 28,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
