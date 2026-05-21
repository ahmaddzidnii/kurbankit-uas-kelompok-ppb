import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_status.dart';

class VerificationStatusChip extends StatelessWidget {
  final String status;

  const VerificationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = mapAdminMosqueStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        statusInfo.label,
        style: TextStyle(
          color: statusInfo.color,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }
}

class VerificationImageBox extends StatelessWidget {
  final String? url;
  final String fallbackLabel;

  const VerificationImageBox({
    super.key,
    required this.url,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.backgroundElevatedHighlight),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackBox(label: fallbackLabel);
                },
              ),
            )
          : _FallbackBox(label: fallbackLabel),
    );
  }
}

class VerificationReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const VerificationReadOnlyField(
    this.label,
    this.value, {
    super.key,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.medium,
            color: AppColors.textSubdued,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            filled: true,
            fillColor: AppColors.backgroundHighlight,
          ),
        ),
      ],
    );
  }
}

class _FallbackBox extends StatelessWidget {
  final String label;

  const _FallbackBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: AppColors.textSubdued.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
        ],
      ),
    );
  }
}
