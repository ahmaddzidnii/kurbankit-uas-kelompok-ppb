import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class MosqueRegistrationRejectedPage extends StatelessWidget {
  final ProfileMasjid? mosque;

  const MosqueRegistrationRejectedPage({super.key, this.mosque});

  String get _reasonText {
    final reason = mosque?.rejectionReason;
    if (reason != null && reason.trim().isNotEmpty) {
      return reason;
    }

    return 'Pendaftaran masjid Anda ditolak karena belum memenuhi persyaratan atau ada data yang perlu diperbaiki. Silakan cek kembali informasi yang dimasukkan lalu ajukan registrasi ulang.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Pendaftaran Ditolak'),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevatedBase,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.backgroundHighlight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cancel_outlined,
                            size: 44,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Pendaftaran Masjid Ditolak',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.headingMedium,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textBase,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Silakan cek alasan di bawah dan ajukan ulang setelah data diperbaiki.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.textSubdued,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Alasan Penolakan',
                                    style: TextStyle(
                                      fontSize: AppTypography.bodyMedium,
                                      fontWeight: AppTypography.semiBold,
                                      color: AppColors.textBase,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _reasonText,
                                style: const TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  color: AppColors.textSubdued,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => context.go('/mosque-registration'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.essentialBrightAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                            ),
                            child: const Text('Registrasi Lagi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
