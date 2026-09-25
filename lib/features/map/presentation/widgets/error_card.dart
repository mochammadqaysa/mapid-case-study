import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Standalone error banner card with a retry action, adhering to WCAG AA contrast (REQ-007, AC-007).
class ErrorCard extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final Key? retryButtonKey;

  const ErrorCard({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.retryButtonKey = const Key('map_error_retry_button'),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.errorSurface,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMessage,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Semantics(
              button: true,
              label: 'Coba Lagi',
              hint: 'Memuat ulang data layer GIS GEO MAPID',
              child: TextButton(
                key: retryButtonKey,
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
