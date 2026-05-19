import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class MosqueSettingsPage extends StatefulWidget {
  final UserData? user;

  const MosqueSettingsPage({super.key, this.user});

  @override
  State<MosqueSettingsPage> createState() => _MosqueSettingsPageState();
}

class _MosqueSettingsPageState extends State<MosqueSettingsPage> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _darkMode = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await authRepository.logout();
      await UserRoleService.clearUserRoleData();
      if (!mounted) return;
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.essentialBrightAccent,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account'),
              _buildCard(
                children: [
                  _buildNavTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: () {
                      context.push('/mosque-profile', extra: widget.user);
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ubah password - Coming Soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildSectionTitle('Notifications'),
              _buildCard(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Push Notifications',
                    value: _pushNotifications,
                    onChanged: (value) =>
                        setState(() => _pushNotifications = value),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.email_outlined,
                    title: 'Email Updates',
                    value: _emailUpdates,
                    onChanged: (value) => setState(() => _emailUpdates = value),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildSectionTitle('System'),
              _buildCard(
                children: [
                  _buildInfoTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: 'Bahasa Indonesia',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildSectionTitle('Support'),
              _buildCard(
                children: [
                  _buildNavTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Qurban Kit',
                      style: TextStyle(
                        fontSize: AppTypography.headingMedium,
                        fontWeight: AppTypography.bold,
                        color: AppColors.essentialBrightAccent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Version 1.1.0',
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: AppColors.textSubdued,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFC8C8)),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    backgroundColor: const Color(0xFFFFE3E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: AppTypography.labelLarge,
          letterSpacing: 1,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textSubdued,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.decorativeSubdued),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.essentialBrightAccent.withValues(
          alpha: 0.12,
        ),
        child: Icon(icon, color: AppColors.essentialBrightAccent, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.essentialBrightAccent.withValues(
          alpha: 0.12,
        ),
        child: Icon(icon, color: AppColors.essentialBrightAccent, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.essentialBrightAccent,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.essentialBrightAccent.withValues(
          alpha: 0.12,
        ),
        child: Icon(icon, color: AppColors.essentialBrightAccent, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: AppColors.textSubdued,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
