import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';
import 'package:qurban_kit/data/sources/admin_mosque_data_source.dart';

class MosqueDetailPage extends StatefulWidget {
  final AdminMosqueRecord? mosque;

  const MosqueDetailPage({super.key, this.mosque});

  @override
  State<MosqueDetailPage> createState() => _MosqueDetailPageState();
}

class _MosqueDetailPageState extends State<MosqueDetailPage> {
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

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'BLOCKED':
      case 'BLOKIR':
      case 'TAKEDOWN':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return AppColors.textSubdued;
    }
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

  Future<void> _blockMosque() async {
    final mosque = widget.mosque;
    if (mosque == null) {
      return;
    }

    final reasonController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Blokir Masjid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masjid ${mosque.nama} akan diblokir.',
              style: const TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: AppColors.textSubdued,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Alasan blokir',
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
                hintText: 'Masukkan alasan blokir',
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
                await getIt<AdminMosqueDataSource>().blockMosque(
                  mosque.id,
                  reason: reasonController.text.trim(),
                );
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masjid berhasil diblokir')),
                );
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memblokir masjid: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Blokir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _unblockMosque() async {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Endpoint buka blokir belum tersedia di backend.'),
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

  Widget _buildImageBox(String? url) {
    final hasImage = url != null && url.isNotEmpty;

    return Container(
      height: 210,
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
                  return _fallbackBox();
                },
              ),
            )
          : _fallbackBox(),
    );
  }

  Widget _fallbackBox() {
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
          const Text(
            'Foto masjid tidak tersedia',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mosque = widget.mosque;
    if (mosque == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.essentialBrightAccent,
          foregroundColor: Colors.white,
          title: const Text('Detail Masjid'),
        ),
        body: const Center(child: Text('Data masjid tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Detail Masjid'),
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
                  backgroundColor: AppColors.essentialAnnouncement.withOpacity(
                    0.14,
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppColors.essentialAnnouncement,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.nama,
                        style: const TextStyle(
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.textBase,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        mosque.alamat,
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
                          color: _statusColor(mosque.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          mosque.status,
                          style: TextStyle(
                            color: _statusColor(mosque.status),
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
            _buildImageBox(mosque.gambarMasjidUrl),
            const SizedBox(height: AppSpacing.lg),
            _buildField('Nama Masjid', mosque.nama),
            const SizedBox(height: AppSpacing.md),
            _buildField('Nomor SK', mosque.nomorSK ?? '-'),
            const SizedBox(height: AppSpacing.md),
            _buildField('Alamat', mosque.alamat, maxLines: 2),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              'Wilayah',
              mosque.detailWilayah.formattedAddress.isNotEmpty
                  ? mosque.detailWilayah.formattedAddress
                  : '-',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField('Tanggal Daftar', _formatDate(mosque.createdAt)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || mosque.isBlocked
                        ? _unblockMosque
                        : _blockMosque,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mosque.isBlocked
                          ? Colors.green
                          : Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      mosque.isBlocked ? 'Buka Blokir' : 'Blokir Masjid',
                      style: const TextStyle(color: Colors.white),
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
