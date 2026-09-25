import 'package:flutter/material.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Floating action button triggering on-demand hardware GPS positioning (REQ-005, GUD-001, antislop-human).
///
/// Ensures minimum touch target size of 48x48 dp and displays a loading spinner during GPS acquisition.
class UserLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const UserLocationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Temukan Lokasi Saya',
      hint: 'Mengambil koordinat GPS terkini dan memusatkan peta',
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
          key: const Key('user_location_button'),
          onTap: isLoading ? null : onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTargetSize,
              minHeight: AppConstants.minTouchTargetSize,
            ),
            child: Container(
              width: AppConstants.minTouchTargetSize,
              height: AppConstants.minTouchTargetSize,
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
