import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

class VerificationListPage extends StatefulWidget {
  const VerificationListPage({super.key});

  @override
  State<VerificationListPage> createState() => _VerificationListPageState();
}

class _VerificationListPageState extends State<VerificationListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Sample data - will be replaced with API calls
  final List<Map<String, String>> _pendingRegistrations = [
    {
      'id': 'AF',
      'name': 'Masjid Al-Barkah',
      'address': 'Jl. Kenanga 12',
      'admin': 'Admin Ahmad Fauzi',
      'date': 'Tanggal 17 Mei 2026',
      'status': 'MENUNGGU',
    },
    {
      'id': 'SH',
      'name': 'Masjid Nurul Iman',
      'address': 'Jl. Anggrek 5',
      'admin': 'Admin Ahmad Fauzi',
      'date': 'Tanggal 17 Mei 2026',
      'status': 'MENUNGGU',
    },
  ];

  final List<Map<String, String>> _approvedRegistrations = [
    {
      'id': 'AF',
      'name': 'Masjid Al-Barkah',
      'address': 'Jl. Kenanga 12',
      'admin': 'Admin Burrill Howo',
      'date': 'Tanggal 17 Mei 2026',
      'status': 'DISETUJUI',
    },
  ];

  final List<Map<String, String>> _rejectedRegistrations = [
    {
      'id': 'SH',
      'name': 'Masjid Nurul Iman',
      'address': 'Subtitle 5',
      'admin': 'Admin Ahmad Santoso',
      'date': 'Tanggal 17 Mei 2026',
      'status': 'DITOLAK',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'MENUNGGU':
        return Colors.grey;
      case 'DISETUJUI':
        return Colors.green;
      case 'DITOLAK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRegistrationCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detail page
        Navigator.pushNamed(context, '/admin-detail');
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(
                  item['id']!,
                  style: const TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.essentialBrightAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item['address']!,
                    style: const TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item['admin']} • ${item['date']}',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: AppColors.textSubdued.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(item['status']!).withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                item['status']!,
                style: TextStyle(
                  fontSize: AppTypography.labelMedium,
                  fontWeight: AppTypography.medium,
                  color: _getStatusColor(item['status']!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, String>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textBase,
            ),
            decoration: InputDecoration(
              hintText: 'Cari masjid atau pendaftar...',
              hintStyle: const TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: AppColors.textSubdued,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSubdued,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.backgroundElevatedBase,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.backgroundHighlight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.backgroundHighlight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.essentialBrightAccent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: AppColors.textSubdued.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Tidak ada data',
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: AppColors.textSubdued,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildRegistrationCard(items[index]);
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Verifikasi Masjid'),
        elevation: 0,
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.essentialBrightAccent,
            unselectedLabelColor: AppColors.textSubdued,
            indicatorColor: AppColors.essentialBrightAccent,
            dividerColor: Colors.transparent, // hilangkan border hitam bawah
            isScrollable: false, // full width
            indicatorSize: TabBarIndicatorSize.tab, // indikator selebar tab
            tabs: const [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Ditolak'),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(_pendingRegistrations),
                _buildTabContent(_approvedRegistrations),
                _buildTabContent(_rejectedRegistrations),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
