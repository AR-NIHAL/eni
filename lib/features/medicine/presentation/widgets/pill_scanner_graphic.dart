import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PillScannerGraphic extends StatelessWidget {
  final double size;

  const PillScannerGraphic({
    super.key,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 Scanner Corner Brackets
          CustomPaint(
            size: Size(size, size * 0.8),
            painter: _ScannerBracketPainter(
              color: AppColors.accentLime,
              strokeWidth: 3,
              cornerLength: 18,
            ),
          ),

          // Tilted Dual-Color Capsule Pill
          Transform.rotate(
            angle: -0.65, // ~37 degrees tilt like screenshot
            child: Container(
              width: size * 0.52,
              height: size * 0.26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Row(
                  children: [
                    // Lime half
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFE8FF66),
                              Color(0xFFB8E610),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // White / cream half
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFE6E2D8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Subtle Scan Beam Laser Line
          Positioned(
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.accentLime.withValues(alpha: 0.8),
                    AppColors.accentLime,
                    AppColors.accentLime.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentLime.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  _ScannerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = 6.0;

    // Top-left
    final tlPath = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tlPath, paint);

    // Top-right
    final trPath = Path()
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, cornerLength);
    canvas.drawPath(trPath, paint);

    // Bottom-left
    final blPath = Path()
      ..moveTo(0, h - cornerLength)
      ..lineTo(0, h - r)
      ..quadraticBezierTo(0, h, r, h)
      ..lineTo(cornerLength, h);
    canvas.drawPath(blPath, paint);

    // Bottom-right
    final brPath = Path()
      ..moveTo(w - cornerLength, h)
      ..lineTo(w - r, h)
      ..quadraticBezierTo(w, h, w, h - r)
      ..lineTo(w, h - cornerLength);
    canvas.drawPath(brPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerBracketPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
