import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/admin_profile_tab.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/mosque_list_tab.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/request_list_tab.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/auth/data/services/auth_repository.dart';

class VerificationListPage extends StatefulWidget {
  const VerificationListPage({super.key});

  @override
  State<VerificationListPage> createState() => _VerificationListPageState();
}

class _VerificationListPageState extends State<VerificationListPage> {
  int _selectedIndex = 0;
  late final Future<UserData?> _profileFuture;

  final List<String> _titles = const ['Permintaan', 'Daftar Masjid', 'Profil'];

  @override
  void initState() {
    super.initState();
    _profileFuture = getIt<AuthRepository>().getProfile();
  }

  void _handleLogout() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
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
    final pages = [
      const RequestListTab(),
      const MosqueListTab(),
      AdminProfileTab(profileFuture: _profileFuture, onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Kalkulator Qurban',
            onPressed: () => context.push('/calculator-template-selection'),
            icon: const Icon(Icons.calculate_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          border: Border(
            top: BorderSide(color: AppColors.decorativeSubdued, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppColors.backgroundElevatedBase,
          selectedItemColor: AppColors.essentialBrightAccent,
          unselectedItemColor: AppColors.essentialSubdued,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Permintaan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque),
              label: 'Daftar Masjid',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
