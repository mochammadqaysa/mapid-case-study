import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Floating custom compass button placed independently above the location FAB.
///
/// Features:
/// - Smooth appearance when map is rotated (bearing != 0)
/// - Real-time rotating needle pointing to true North
/// - Tapping resets the camera bearing back to North (0°)
/// - Meets accessibility guidelines (48x48 dp touch target, WCAG compliant)
class MapCompassButton extends StatelessWidget {
  final double bearing;
  final VoidCallback onPressed;

  const MapCompassButton({
    super.key,
    required this.bearing,
    required this.onPressed,
  });

  bool get _isRotated {
    final normalized = (bearing.abs() % 360.0);
    return normalized > 1.0 && normalized < 359.0;
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = _isRotated;

    return Semantics(
      button: true,
      label: 'Arahkan Peta ke Utara',
      hint: 'Mereset rotasi peta menghadap lurus ke Utara',
      child: AnimatedOpacity(
        key: const Key('map_compass_animated_opacity'),
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: isVisible ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            key: const Key('map_compass_ignore_pointer'),
            ignoring: !isVisible,
            child: Material(
              color: AppColors.surface,
              elevation: 3,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const Key('map_compass_button'),
                onTap: onPressed,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppConstants.minTouchTargetSize,
                    minHeight: AppConstants.minTouchTargetSize,
                  ),
                  child: Container(
                    width: AppConstants.minTouchTargetSize,
                    height: AppConstants.minTouchTargetSize,
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -bearing * (pi / 180.0),
                      child: const _CompassNeedle(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painted navigation compass needle (North red arrow, South slate arrow).
class _CompassNeedle extends StatelessWidget {
  const _CompassNeedle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 28),
      painter: _CompassNeedlePainter(),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // North Needle (Vibrant Red)
    final northPaint = Paint()
      ..color = const Color(0xFFEF4444) // Red 500
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(centerX, 0)
      ..lineTo(size.width, centerY)
      ..lineTo(centerX, centerY - 2)
      ..close();

    final northPathLeft = Path()
      ..moveTo(centerX, 0)
      ..lineTo(0, centerY)
      ..lineTo(centerX, centerY - 2)
      ..close();

    final northShadePaint = Paint()
      ..color = const Color(0xFFDC2626) // Red 600 shadow side
      ..style = PaintingStyle.fill;

    canvas.drawPath(northPath, northPaint);
    canvas.drawPath(northPathLeft, northShadePaint);

    // South Needle (Slate Gray)
    final southPaint = Paint()
      ..color = const Color(0xFF94A3B8) // Slate 400
      ..style = PaintingStyle.fill;

    final southPath = Path()
      ..moveTo(centerX, size.height)
      ..lineTo(size.width, centerY)
      ..lineTo(centerX, centerY + 2)
      ..close();

    final southPathLeft = Path()
      ..moveTo(centerX, size.height)
      ..lineTo(0, centerY)
      ..lineTo(centerX, centerY + 2)
      ..close();

    final southShadePaint = Paint()
      ..color = const Color(0xFF64748B) // Slate 500
      ..style = PaintingStyle.fill;

    canvas.drawPath(southPath, southPaint);
    canvas.drawPath(southPathLeft, southShadePaint);

    // Pivot Center Ring
    final pivotPaint = Paint()
      ..color = const Color(0xFF0F172A) // Slate 900
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 2.5, pivotPaint);

    final innerPivotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 1.0, innerPivotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
