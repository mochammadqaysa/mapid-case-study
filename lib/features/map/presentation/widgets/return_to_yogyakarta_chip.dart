import 'package:flutter/material.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Floating action chip allowing immediate camera recentering to Yogyakarta (REQ-006, ADR-0001).
///
/// Displayed when user device location is detected to be >50,000 meters outside Yogyakarta center.
/// Ensures touch target meets or exceeds 48 dp height.
class ReturnToYogyakartaChip extends StatelessWidget {
  final VoidCallback onTap;

  const ReturnToYogyakartaChip({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali ke Yogyakarta',
      hint: 'Pusatkan kembali peta ke Daerah Istimewa Yogyakarta',
      child: Material(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('return_to_yogyakarta_chip'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTargetSize,
              minHeight: AppConstants.minTouchTargetSize,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.explore,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kembali ke Yogyakarta',
                    style: AppTextStyles.chipLabel,
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
