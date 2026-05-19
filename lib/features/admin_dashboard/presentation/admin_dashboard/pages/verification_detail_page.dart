import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
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
            onPressed: () => Navigator.pop(context),
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

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
      case 'ACTIVE':
        return Colors.green;
      case 'REJECTED':
      case 'BLOCKED':
      case 'BLOKIR':
        return Colors.red;
      default:
        return AppColors.textSubdued;
    }
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
      Navigator.pop(context, true);
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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
                Navigator.pop(context, true);
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

  Widget _buildImageBox(String? url, String fallbackLabel) {
    final hasImage = url != null && url.isNotEmpty;

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
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackBox(fallbackLabel);
                },
              ),
            )
          : _fallbackBox(fallbackLabel),
    );
  }

  Widget _fallbackBox(String label) {
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

  Widget _buildField(String label, String value, {int maxLines = 1}) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(request.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          request.status,
                          style: TextStyle(
                            color: _statusColor(request.status),
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildImageBox(
              request.gambarMasjidUrl,
              'Foto masjid belum tersedia',
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildField('Nama Masjid', request.nama),
            const SizedBox(height: AppSpacing.md),
            _buildField('Nama Pengaju', request.namaPengaju ?? '-'),
            const SizedBox(height: AppSpacing.md),
            _buildField('Nomor SK', request.nomorSK ?? '-'),
            const SizedBox(height: AppSpacing.md),
            _buildField('Alamat', request.alamat, maxLines: 2),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              'Wilayah',
              request.detailWilayah.formattedAddress.isNotEmpty
                  ? request.detailWilayah.formattedAddress
                  : '-',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField('Tanggal Pengajuan', _formatDate(request.createdAt)),
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
            _buildImageBox(
              request.dokumenSKUrl,
              'Dokumen verifikasi belum tersedia',
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
