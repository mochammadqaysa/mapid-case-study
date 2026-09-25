import 'package:flutter/material.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/map_feature_entity.dart';

/// Interactive bottom sheet overlay displaying Feature Point metadata (REQ-004, GUD-001, GUD-002).
class PoiDetailSheet extends StatelessWidget {
  final MapFeatureEntity feature;
  final VoidCallback onClose;

  const PoiDetailSheet({
    super.key,
    required this.feature,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.70;

    return Semantics(
      container: true,
      label: 'Detail Titik Landmark ${feature.name}',
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          // Drag downwards dismisses the sheet (REQ-004, AC-004)
          if (details.primaryVelocity != null && details.primaryVelocity! > 100) {
            onClose();
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 540,
              maxHeight: maxSheetHeight,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // 1. Drag Handle Pill
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Header: Title & Close Button (>= 48x48 dp touch target)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.place,
                      color: AppColors.mapPinDefault,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.name,
                          key: const Key('poi_detail_name'),
                          style: AppTextStyles.headingLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kecamatan: ${feature.district}',
                          key: const Key('poi_detail_district'),
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                  // Close Button with GUD-001 touch target
                  SizedBox(
                    width: AppConstants.minTouchTargetSize,
                    height: AppConstants.minTouchTargetSize,
                    child: IconButton(
                      key: const Key('poi_detail_close_button'),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: 'Tutup detail',
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // 3. Address (ALAMAT)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.address,
                      key: const Key('poi_detail_address'),
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Timestamp & Coordinates
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Waktu: ${feature.recordTime}',
                      key: const Key('poi_detail_time'),
                      style: AppTextStyles.caption,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Text(
                      '${feature.latitude.toStringAsFixed(4)}, ${feature.longitude.toStringAsFixed(4)}',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
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
