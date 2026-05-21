import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/core/utils/date_time_formatter.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_detail_components.dart';
import 'package:qurban_kit/features/auth/data/services/auth_repository.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';

class VerificationDetailPage extends StatefulWidget {
  final AdminMosqueRecord? request;

  const VerificationDetailPage({super.key, this.request});

  @override
  State<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends State<VerificationDetailPage> {
  bool _isLoading = false;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final authRepository = getIt<AuthRepository>();
              await authRepository.logout();
              await UserRoleService.clearUserRoleData();

              if (!context.mounted) {
                return;
              }

              context.go('/auth');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRegistration() async {
    final request = widget.request;
    if (request == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await getIt<AdminMosqueDataSource>().approveRegistration(request.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan berhasil diverifikasi')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyetujui permintaan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectRegistration() async {
    final request = widget.request;
    if (request == null) {
      return;
    }

    final reasonController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alasan penolakan',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.medium,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              setState(() => _isLoading = true);
              try {
                await getIt<AdminMosqueDataSource>().rejectRegistration(
                  request.id,
                  reason: reasonController.text.trim(),
                );
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permintaan berhasil ditolak')),
                );
                context.pop(true);
              } catch (e) {
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menolak permintaan: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    if (request == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.essentialBrightAccent,
          foregroundColor: Colors.white,
          title: const Text('Detail Permintaan'),
        ),
        body: const Center(child: Text('Data permintaan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Detail Permintaan'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.essentialBrightAccent.withOpacity(
                    0.14,
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppColors.essentialBrightAccent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.nama,
                        style: const TextStyle(
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.textBase,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        request.namaPengaju?.isNotEmpty == true
                            ? request.namaPengaju!
                            : 'Nama pengaju belum tersedia',
                        style: const TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: AppColors.textSubdued,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      VerificationStatusChip(status: request.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            VerificationImageBox(
              url: request.gambarMasjidUrl,
              fallbackLabel: 'Foto masjid belum tersedia',
            ),
            const SizedBox(height: AppSpacing.lg),
            VerificationReadOnlyField('Nama Masjid', request.nama),
            const SizedBox(height: AppSpacing.md),
            VerificationReadOnlyField(
              'Nama Pengaju',
              request.namaPengaju ?? '-',
            ),
            const SizedBox(height: AppSpacing.md),
            VerificationReadOnlyField('Nomor SK', request.nomorSK ?? '-'),
            const SizedBox(height: AppSpacing.md),
            VerificationReadOnlyField('Alamat', request.alamat, maxLines: 2),
            const SizedBox(height: AppSpacing.md),
            VerificationReadOnlyField(
              'Wilayah',
              request.detailWilayah.formattedAddress.isNotEmpty
                  ? request.detailWilayah.formattedAddress
                  : '-',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            VerificationReadOnlyField(
              'Tanggal Pengajuan',
              AppDateTimeFormatter.formatDate(request.createdAt),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Dokumen Pendukung',
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            VerificationImageBox(
              url: request.dokumenSKUrl,
              fallbackLabel: 'Dokumen verifikasi belum tersedia',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _approveRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.essentialBrightAccent,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Verifikasi',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _rejectRegistration,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
