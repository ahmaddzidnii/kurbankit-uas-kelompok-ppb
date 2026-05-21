import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_list_components.dart';

class MosqueListTab extends StatefulWidget {
  const MosqueListTab({super.key});

  @override
  State<MosqueListTab> createState() => _MosqueListTabState();
}

class _MosqueListTabState extends State<MosqueListTab> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<AdminMosqueRecord>> _mosquesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _mosquesFuture = getIt<AdminMosqueDataSource>().getMosques();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _mosquesFuture = getIt<AdminMosqueDataSource>().getMosques();
    });
  }

  List<AdminMosqueRecord> _filter(List<AdminMosqueRecord> items) {
    if (_query.isEmpty) {
      return items;
    }

    return items.where((item) {
      final haystack = [
        item.nama,
        item.alamat,
        item.status,
        item.detailWilayah.formattedAddress,
      ].join(' ').toLowerCase();

      return haystack.contains(_query);
    }).toList();
  }

  Widget _buildCard(AdminMosqueRecord item) {
    return InkWell(
      onTap: () async {
        final updated = await context.push<bool>(
          '/admin-mosque-detail',
          extra: item,
        );

        if (updated == true && mounted) {
          await _reload();
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textBase,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.alamat,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: AppColors.textSubdued,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: TextField(
            style: const TextStyle(fontSize: AppTypography.bodyMedium),
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Cari masjid terdaftar...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.all(AppSpacing.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                borderSide: BorderSide(color: AppColors.textSubdued, width: 1),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AdminMosqueRecord>>(
            future: _mosquesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return VerificationEmptyState(
                  icon: Icons.error_outline,
                  title: 'Gagal memuat masjid',
                  subtitle: snapshot.error.toString(),
                  actionLabel: 'Coba lagi',
                  onAction: _reload,
                );
              }

              final items = _filter(snapshot.data ?? const []);
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: const [
                      SizedBox(height: 120),
                      VerificationEmptyState(
                        icon: Icons.home_work_outlined,
                        title: 'Tidak ada masjid',
                        subtitle:
                            'Daftar masjid terdaftar akan muncul di sini.',
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _buildCard(items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
