import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/utils/date_time_formatter.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_status.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_detail_components.dart';

class MosqueDetailPage extends StatefulWidget {
  final AdminMosqueRecord? mosque;

  const MosqueDetailPage({super.key, this.mosque});

  @override
  State<MosqueDetailPage> createState() => _MosqueDetailPageState();
}

class _MosqueDetailPageState extends State<MosqueDetailPage> {
  bool _isLoading = false;
  late final ScrollController _scrollController;
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

  void _onScroll() {
    if (!mounted) {
      return;
    }

    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight + safeAreaTop;
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
            onPressed: () => dialogContext.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
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
                context.pop(true);
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

    reasonController.dispose();
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

  Widget _buildHeroHeader(AdminMosqueRecord mosque) {
    final hasImage = mosque.gambarMasjidUrl?.isNotEmpty == true;

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              mosque.gambarMasjidUrl!,
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

  Widget _buildInfoTile(String label, String value) {
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

  Widget _buildActionButton(AdminMosqueRecord mosque) {
    final isBlocked = mosque.isBlocked;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (isBlocked ? _unblockMosque : _blockMosque),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green : Colors.red,
              disabledBackgroundColor: (isBlocked ? Colors.green : Colors.red)
                  .withOpacity(0.38),
              disabledForegroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
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
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isBlocked ? 'Buka Blokir' : 'Blokir Masjid',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
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

    const double headerHeight = 320.0;
    const double overlapHeight = 40.0;

    final statusInfo = mapAdminMosqueStatus(mosque.status);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolledToTop
            ? AppColors.essentialBrightAccent
            : Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Detail Masjid'),
        elevation: _isScrolledToTop ? 4 : 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: Container(
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
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: _buildActionButton(mosque),
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
            child: _buildHeroHeader(mosque),
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
                                        mosque.nama,
                                        style: const TextStyle(
                                          fontSize: AppTypography.headingMedium,
                                          fontWeight: AppTypography.semiBold,
                                          color: AppColors.textBase,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      VerificationStatusChip(
                                        status: mosque.status,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle('Informasi Masjid'),
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
                                        mosque.nama,
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Nomor SK',
                                        mosque.nomorSK?.isNotEmpty == true
                                            ? mosque.nomorSK!
                                            : '-',
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Alamat',
                                        mosque.alamat,
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: _buildInfoTile(
                                        'Status',
                                        statusInfo.label,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _buildInfoTile(
                                        'Wilayah',
                                        mosque
                                                .detailWilayah
                                                .formattedAddress
                                                .isNotEmpty
                                            ? mosque
                                                  .detailWilayah
                                                  .formattedAddress
                                            : '-',
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _buildInfoTile(
                                        'Tanggal Daftar',
                                        AppDateTimeFormatter.formatDate(
                                          mosque.createdAt,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
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
