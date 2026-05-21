import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/utils/date_time_formatter.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_list_components.dart';

class RequestListTab extends StatefulWidget {
  const RequestListTab({super.key});

  @override
  State<RequestListTab> createState() => _RequestListTabState();
}

class _RequestListTabState extends State<RequestListTab> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<AdminMosqueRecord>> _requestsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _requestsFuture = getIt<AdminMosqueDataSource>().getRegistrationRequests();
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
      _requestsFuture = getIt<AdminMosqueDataSource>()
          .getRegistrationRequests();
    });
  }

  List<AdminMosqueRecord> _filter(List<AdminMosqueRecord> items) {
    if (_query.isEmpty) {
      return items;
    }

    return items.where((item) {
      final haystack = [
        item.nama,
        item.namaPengaju ?? '',
        item.alamat,
        item.status,
        item.nomorSK ?? '',
      ].join(' ').toLowerCase();

      return haystack.contains(_query);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
      case 'ACTIVE':
        return Colors.green;
      case 'REJECTED':
      case 'BLOKIR':
      case 'BLOCKED':
        return Colors.red;
      default:
        return AppColors.textSubdued;
    }
  }

  Widget _buildCard(AdminMosqueRecord item) {
    return InkWell(
      onTap: () async {
        final updated = await context.push<bool>('/admin-detail', extra: item);

        if (updated == true && mounted) {
          await _reload();
        }
      },
      child: Card(
        elevation: 0,
        color: AppColors.backgroundElevatedBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColors.textSubdued.withOpacity(0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.namaPengaju?.isNotEmpty == true
                    ? item.namaPengaju!
                    : 'Nama pengaju belum tersedia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: AppColors.textSubdued,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.alamat,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: AppColors.textSubdued,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dibuat ${AppDateTimeFormatter.formatDateTime(item.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: AppColors.textSubdued,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      item.nomorSK?.isNotEmpty == true
                          ? item.nomorSK!
                          : 'No. SK -',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: AppColors.textSubdued,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.medium,
                      color: _statusColor(item.status),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
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
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Cari permintaan masjid...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AdminMosqueRecord>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return VerificationEmptyState(
                  icon: Icons.error_outline,
                  title: 'Gagal memuat permintaan',
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
                        icon: Icons.inbox_outlined,
                        title: 'Tidak ada permintaan',
                        subtitle:
                            'Data permintaan pendaftaran masjid akan muncul di sini.',
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
                  separatorBuilder: (_, _) =>
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
