import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/cache_service.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/mosque_dashboard/screens/dashboard/admin_home_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/periods/periods_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/profile/mosque_profile_page.dart';

class MosqueAdminDashboard extends StatefulWidget {
  final UserData? initialUser;

  const MosqueAdminDashboard({super.key, this.initialUser});

  @override
  State<MosqueAdminDashboard> createState() => _MosqueAdminDashboardState();
}

class _MosqueAdminDashboardState extends State<MosqueAdminDashboard> {
  int _selectedIndex = 0;
  UserData? _user;
  bool _isLoading = false;
  final _cacheService = CacheService();
  static const _userCacheKey = 'user_profile';

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    apiClient.setOnUnauthorized(_handleUnauthorized);

    if (_user == null) {
      _fetchUserProfile();
    }
  }

  @override
  void dispose() {
    apiClient.clearOnUnauthorized();
    super.dispose();
  }

  void _handleUnauthorized() {
    if (mounted) {
      _redirectToLogin();
    }
  }

  Future<void> _redirectToLogin() async {
    await authRepository.clearTokens();
    await UserRoleService.clearUserRoleData();
    _cacheService.clear(); // Clear semua cache saat logout

    if (mounted) {
      context.go('/auth');
    }
  }

  Future<void> _fetchUserProfile({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    try {
      if (forceRefresh) {
        _cacheService.invalidate(_userCacheKey);
      }

      final user = await _cacheService.get<UserData>(
        key: _userCacheKey,
        compute: () => authRepository.getProfile().then((u) => u!),
        ttl: const Duration(minutes: 10),
      );

      if (user != null && mounted) {
        setState(() => _user = user);
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavTapped(int index) {
    if (_selectedIndex == index) {
      return; // Jangan rebuild jika index sama
    }

    setState(() {
      _selectedIndex = index;
    });

    // Invalidate cache tertentu saat berpindah tab
    // Berguna kalau ada update di background
    switch (index) {
      case 1: // Periods tab
        // Cache periods akan di-update saat pull-to-refresh atau interval
        break;
      case 2: // Profile tab
        // Profile bisa di-cache lebih lama
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build pages dengan UniqueKey untuk memastikan state tidak nyangkut
    // Tapi pages sudah cache di level data, jadi FutureBuilder bisa reuse
    final pages = [
      AdminHomePage(user: _user),
      const PeriodsPage(), // Gunakan cache dari PeriodsPage
      MosqueProfilePage(user: _user),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border(
          top: BorderSide(color: AppColors.decorativeSubdued, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        backgroundColor: AppColors.backgroundElevatedBase,
        selectedItemColor: AppColors.essentialBrightAccent,
        unselectedItemColor: AppColors.essentialSubdued,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Periode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
