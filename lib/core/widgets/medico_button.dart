import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum MedicoButtonVariant {
  primary, // Black background, white text
  lime,    // Lime background, black text
  outline, // Transparent, dark border
}

class MedicoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MedicoButtonVariant variant;
  final bool showTrailingIcon;
  final IconData trailingIcon;
  final double height;
  final bool isLoading;

  const MedicoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MedicoButtonVariant.primary,
    this.showTrailingIcon = true,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color iconCircleBg;
    Color iconColor;
    Border? border;

    switch (variant) {
      case MedicoButtonVariant.lime:
        bgColor = AppColors.accentLime;
        textColor = AppColors.primaryDark;
        iconCircleBg = AppColors.primaryDark;
        iconColor = AppColors.accentLime;
        break;
      case MedicoButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.primaryDark;
        iconCircleBg = AppColors.surface;
        iconColor = AppColors.primaryDark;
        border = Border.all(color: AppColors.cardBorder, width: 1.5);
        break;
      case MedicoButtonVariant.primary:
        bgColor = AppColors.primaryDark;
        textColor = AppColors.white;
        iconCircleBg = AppColors.textSecondary.withValues(alpha: 0.4);
        iconColor = AppColors.white;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(100),
              border: border,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                else ...[
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (showTrailingIcon) ...[
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconCircleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trailingIcon,
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
