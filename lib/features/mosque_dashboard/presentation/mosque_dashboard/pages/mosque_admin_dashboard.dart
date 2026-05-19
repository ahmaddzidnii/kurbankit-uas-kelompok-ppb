import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'dashboard/admin_home_page.dart';
import 'periods/periods_page.dart';
import 'recipients/recipients_page.dart';
import 'settings/mosque_settings_page.dart';

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

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = await authRepository.getProfile();
      if (user != null) {
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
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminHomePage(user: _user),
      const PeriodsPage(),
      const RecipientsPage(),
      MosqueSettingsPage(user: _user),
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Periode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Participant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
