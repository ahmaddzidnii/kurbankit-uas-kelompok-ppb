import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/auth/data/services/auth_repository.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';

class VerificationListPage extends StatefulWidget {
  const VerificationListPage({super.key});

  @override
  State<VerificationListPage> createState() => _VerificationListPageState();
}

class _VerificationListPageState extends State<VerificationListPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [_RequestListTab(), _MosqueListTab()];

  final List<String> _titles = const ['Permintaan', 'Daftar Masjid'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        // --- Pengaturan Style ---
        height: 65, // Mengatur tinggi navbar agar lebih proporsional
        elevation: 3, // Menambahkan sedikit bayangan (shadow)
        backgroundColor: Colors.white, // Warna latar belakang navbar
        indicatorColor: Colors
            .green
            .shade100, // Warna sorotan (kapsul) di belakang ikon yang dipilih
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(
          milliseconds: 300,
        ), // Kecepatan animasi transisi
        // ------------------------
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.fact_check_outlined,
              color: Colors.black54,
            ), // Warna ikon saat tidak dipilih
            selectedIcon: Icon(
              Icons.fact_check,
              color: Colors.green,
            ), // Warna ikon saat dipilih
            label: 'Permintaan',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined, color: Colors.black54),
            selectedIcon: Icon(Icons.mosque, color: Colors.green),
            label: 'Daftar Masjid',
          ),
        ],
      ),
    );
  }
}

class _RequestListTab extends StatefulWidget {
  const _RequestListTab();

  @override
  State<_RequestListTab> createState() => _RequestListTabState();
}

class _RequestListTabState extends State<_RequestListTab> {
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
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.essentialBrightAccent
                        .withOpacity(0.15),
                    child: Icon(
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
                          item.nama,
                          style: const TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textBase,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.namaPengaju?.isNotEmpty == true
                              ? item.namaPengaju!
                              : 'Nama pengaju belum tersedia',
                          style: const TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: AppColors.textSubdued,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(item.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.medium,
                        color: _statusColor(item.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoChip(
                    label: 'Pengajuan',
                    value: _formatDate(item.createdAt),
                  ),
                  _InfoChip(label: 'Nomor SK', value: item.nomorSK ?? '-'),
                ],
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
                return _EmptyState(
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
                      _EmptyState(
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

class _MosqueListTab extends StatefulWidget {
  const _MosqueListTab();

  @override
  State<_MosqueListTab> createState() => _MosqueListTabState();
}

class _MosqueListTabState extends State<_MosqueListTab> {
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

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AKTIF':
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
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.essentialAnnouncement
                        .withOpacity(0.16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(item.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.medium,
                        color: _statusColor(item.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoChip(
                    label: 'Detail Wilayah',
                    value: item.detailWilayah.formattedAddress.isNotEmpty
                        ? item.detailWilayah.formattedAddress
                        : '-',
                  ),
                  _InfoChip(
                    label: 'Tersimpan',
                    value: _formatDate(item.createdAt),
                  ),
                ],
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
              hintText: 'Cari masjid...',
              prefixIcon: Icon(Icons.search),
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
                return _EmptyState(
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
                      _EmptyState(
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: AppTypography.labelSmall,
          color: AppColors.textSubdued,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSubdued.withOpacity(0.45),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
