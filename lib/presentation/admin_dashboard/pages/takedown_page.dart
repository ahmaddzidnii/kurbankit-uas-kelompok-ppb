import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

class TakedownPage extends StatefulWidget {
  const TakedownPage({super.key});

  @override
  State<TakedownPage> createState() => _TakedownPageState();
}

class _TakedownPageState extends State<TakedownPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

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

  // Sample data
  final List<Map<String, String>> _activeMosques = [
    {
      'id': 'AF',
      'name': 'Masjid Al-Barkah',
      'address': 'Jl. Kenanga 12',
      'admin': 'Admin Ahmad Fauzi',
      'date': 'Tanggal 18 Mei 2026',
      'status': 'AKTIF',
    },
    {
      'id': 'SH',
      'name': 'Masjid Nurul Iman',
      'address': 'Subtitle 5',
      'admin': 'Admin Ahmad Santoso',
      'date': 'Tanggal 17 Mei 2028',
      'status': 'AKTIF',
    },
  ];

  final List<Map<String, String>> _takenDownMosques = [
    {
      'id': 'AF',
      'name': 'Masjid Al-Barkah',
      'address': 'Jl. Kenanga 12',
      'admin': 'Admin Nurul Hawa',
      'date': 'Takedown: 15 Mei 2026',
      'status': 'TAKEDOWN',
    },
    {
      'id': 'AF',
      'name': 'Masjid Al-Hikmah',
      'address': 'Jl. Mawar 8',
      'admin': 'Admin Budi',
      'date': 'Takedown: 15 Mei 2026',
      'status': 'TAKEDOWN',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AKTIF':
        return AppColors.essentialBrightAccent;
      case 'TAKEDOWN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTakedownConfirmation(Map<String, String> mosque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Takedown'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan melakukan takedown pada ${mosque['name']!} (${mosque['address']!}). Masjid akan dianggap fiktif dan dinonaktifkan. Lanjutkan?',
              style: const TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: AppColors.textSubdued,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Alasan Takedown (Opsional)',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.medium,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Call API to takedown
              Navigator.pop(context);
              _reasonController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Takedown berhasil dilakukan')),
              );
            },
            child: const Text('Takedown', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueCard(
    Map<String, String> mosque, {
    bool canTakedown = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border.all(color: AppColors.backgroundHighlight),
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                mosque['id']!,
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
                  mosque['name']!,
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textBase,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  mosque['address']!,
                  style: const TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textSubdued,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${mosque['admin']!} • ${mosque['date']!}',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textSubdued.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Status or menu
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(mosque['status']!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  mosque['status']!,
                  style: TextStyle(
                    fontSize: AppTypography.labelMedium,
                    fontWeight: AppTypography.medium,
                    color: _getStatusColor(mosque['status']!),
                  ),
                ),
              ),
              if (canTakedown)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Takedown'),
                      onTap: () => _showTakedownConfirmation(mosque),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, String>> items, bool canTakedown) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Cari masjid atau pendaftar...',
            leading: const Icon(Icons.search),
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
                    return _buildMosqueCard(
                      items[index],
                      canTakedown: canTakedown,
                    );
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
        title: const Text('Takedown Masjid Fiktif'),
        elevation: 0,
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.backgroundHighlight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUPER ADMIN - MASJID AKTIF',
                  style: TextStyle(
                    fontSize: AppTypography.labelMedium,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textSubdued,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.essentialBrightAccent,
            unselectedLabelColor: AppColors.textSubdued,
            indicatorColor: AppColors.essentialBrightAccent,
            tabs: const [
              Tab(text: 'Masjid Aktif'),
              Tab(text: 'Masjid Takedown'),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(_activeMosques, true),
                _buildTabContent(_takenDownMosques, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
