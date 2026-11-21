import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HeroCapsuleGraphic extends StatelessWidget {
  final double size;

  const HeroCapsuleGraphic({
    super.key,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: Center(
        child: Transform.rotate(
          angle: -0.65, // ~37 degrees diagonal tilt like screenshot
          child: Container(
            width: size * 0.65,
            height: size * 0.32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentLime.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Row(
                children: [
                  // Lime / chartreuse half
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFEAFF66),
                            Color(0xFFC0EC10),
                            Color(0xFFA0C800),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Highlight shine
                          Positioned(
                            top: 4,
                            left: 12,
                            right: 8,
                            height: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Translucent white / pill half with micro dots
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFEDE9E0),
                            Color(0xFFDCD6C8),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Highlight shine
                          Positioned(
                            top: 4,
                            left: 8,
                            right: 12,
                            height: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          // Subtle pellets/micro-beads
                          Positioned(
                            top: 14,
                            left: 12,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 14,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.07),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 22,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
