import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/utils/date_time_formatter.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_detail_components.dart';

class VerificationDetailPage extends StatefulWidget {
  final AdminMosqueRecord? request;

  const VerificationDetailPage({super.key, this.request});

  @override
  State<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends State<VerificationDetailPage> {
  bool _isLoading = false;

  late ScrollController _scrollController;
  bool _isScrolledToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi untuk mendeteksi kapan AppBar harus berubah warna
  void _onScroll() {
    if (!mounted) return;

    // Ketinggian AppBar (biasanya 56) + SafeArea (Poni layar)
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight + safeAreaTop;

    // Titik di mana card menyentuh batas bawah AppBar
    // (Tinggi Gambar 320 - Overlap 40) - Tinggi AppBar
    final threshold = (320.0 - 40.0) - appBarHeight;

    if (_scrollController.hasClients) {
      final isScrolled = _scrollController.offset > threshold;
      if (isScrolled != _isScrolledToTop) {
        setState(() {
          _isScrolledToTop = isScrolled;
        });
      }
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

  Widget _buildHeroHeader(AdminMosqueRecord request) {
    final hasImage = request.gambarMasjidUrl?.isNotEmpty == true;

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              request.gambarMasjidUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildHeroFallback(),
            )
          else
            _buildHeroFallback(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha((0.08 * 255).round()),
                  Colors.black.withAlpha((0.45 * 255).round()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.essentialBrightAccent, Color(0xFF0E2F2B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.mosque_outlined, size: 56, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {int? maxLines}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.backgroundElevatedHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTypography.labelSmall,
              fontWeight: AppTypography.medium,
              color: AppColors.textSubdued,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textBase,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppTypography.bodyLarge,
        fontWeight: AppTypography.semiBold,
        color: AppColors.textBase,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _rejectRegistration,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isLoading ? Colors.red.withOpacity(0.28) : Colors.red,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: Colors.red,
              disabledForegroundColor: Colors.red.withOpacity(0.38),
            ),
            child: Text('Tolak', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),

        const SizedBox(width: AppSpacing.md), // Jarak antar tombol
        // 2. TOMBOL VERIFIKASI (Diletakkan di kanan untuk aksi Utama)
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _approveRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.essentialBrightAccent,
              disabledBackgroundColor: AppColors.essentialBrightAccent
                  .withOpacity(0.38),
              disabledForegroundColor: Colors.white.withOpacity(0.85),
              elevation: 0, // Dibuat flat agar lebih bersih (opsional)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5, // Sedikit ditebalkan agar lebih jelas
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Verifikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold, // Ditebalkan sedikit
                    ),
                  ),
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
          elevation: 0,
        ),
        body: const Center(child: Text('Data permintaan tidak ditemukan')),
      );
    }

    const double headerHeight = 320.0;
    const double overlapHeight = 40.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolledToTop
            ? AppColors.essentialBrightAccent
            : Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Detail Permintaan'),
        elevation: _isScrolledToTop ? 4 : 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: Container(
        // Menambahkan shadow agar terlihat seperti menempel di atas body
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        // Letakkan SafeArea di dalam Container agar background menutupi area bawah layar penuh (bezel HP)
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing
                  .md, // Ini akan memberi ruang atas-bawah tombol dengan pas
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Membatasi lebar maksimum di layar besar (Web/Tablet)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    // Di fungsi _buildActionButtons(), Anda bisa bebas set tinggi 52 atau 56 sekarang
                    child: _buildActionButtons(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: _buildHeroHeader(request),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: headerHeight - overlapHeight),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevatedBase,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 14,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          top: AppSpacing.xl,
                          bottom: 100.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.nama,
                                        style: const TextStyle(
                                          fontSize: AppTypography.headingMedium,
                                          fontWeight: AppTypography.semiBold,
                                          color: AppColors.textBase,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle('Informasi Permohonan'),
                            const SizedBox(height: AppSpacing.sm),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 700;
                                final tileWidth = isWide
                                    ? (constraints.maxWidth - AppSpacing.md) / 2
                                    : constraints.maxWidth;

                                return Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: [
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Nama Masjid',
                                        request.nama,
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Nama Pengaju',
                                        request.pengaju.displayNameWithEmail,
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Nomor SK',
                                        request.nomorSK?.isNotEmpty == true
                                            ? request.nomorSK!
                                            : '-',
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Tanggal dan waktu pengajuan',
                                        AppDateTimeFormatter.formatDate(
                                          request.createdAt,
                                          pattern: 'EEEE dd MMMM yyyy, HH:mm',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Alamat',
                                        request.alamat,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _buildInfoTile(
                                        'Wilayah',
                                        request
                                                .detailWilayah
                                                .formattedAddress
                                                .isNotEmpty
                                            ? request
                                                  .detailWilayah
                                                  .formattedAddress
                                            : '-',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle('Foto Masjid'),
                            const SizedBox(height: AppSpacing.sm),
                            VerificationImageBox(
                              url: request.gambarMasjidUrl,
                              fallbackLabel: 'Foto masjid belum tersedia',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle('Dokumen Pendukung'),
                            const SizedBox(height: AppSpacing.sm),
                            VerificationImageBox(
                              url: request.dokumenSKUrl,
                              fallbackLabel:
                                  'Dokumen verifikasi belum tersedia',
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
