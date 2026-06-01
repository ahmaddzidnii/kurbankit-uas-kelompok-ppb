import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';

class MosqueWaitingDashboard extends StatefulWidget {
  const MosqueWaitingDashboard({super.key});

  @override
  State<MosqueWaitingDashboard> createState() => _MosqueWaitingDashboardState();
}

class _MosqueWaitingDashboardState extends State<MosqueWaitingDashboard> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await authRepository.logout();
              await UserRoleService.clearUserRoleData();
              if (mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.essentialBrightAccent.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.essentialBrightAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pendaftaran Menunggu Verifikasi',
                              style: TextStyle(
                                fontSize: AppTypography.headingSmall,
                                fontWeight: AppTypography.semiBold,
                                color: AppColors.textBase,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Permohonan pendaftaran Anda sedang dalam proses verifikasi oleh Super Admin. Kami akan mengirimkan update melalui email dan WhatsApp.',
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                color: AppColors.textSubdued,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Registered mosque info section
            const Text(
              'Informasi Masjid Terdaftar',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Mosque detail card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevatedBase,
                border: Border.all(color: AppColors.backgroundHighlight),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.essentialBrightAccent.withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          Icons.mosque,
                          color: AppColors.essentialBrightAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masjid Al-Barkah',
                              style: TextStyle(
                                fontSize: AppTypography.headingSmall,
                                fontWeight: AppTypography.semiBold,
                                color: AppColors.textBase,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Terdaftar: 17 Mei 2026',
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                color: AppColors.textSubdued,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.lg),
                  // Info details
                  _buildInfoRow(
                    'Alamat',
                    'Jl. Kenanga No. 12, RT 01/RW 03, Malang',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Nomor SK', '001/SK-1234/V/2026'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Status', 'Menunggu Verifikasi'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Information section
            const Text(
              'Informasi Penting',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waktu Verifikasi',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Kami akan memproses verifikasi pendaftaran Anda dalam waktu 1-3 hari kerja. Update akan dikirimkan melalui email dan WhatsApp.',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.textSubdued,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.essentialBrightAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.essentialBrightAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Admin Masjid',
                    style: TextStyle(
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'admin@masjid.com',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile info
            const Text(
              'Informasi Profil',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevatedBase,
                border: Border.all(color: AppColors.backgroundHighlight),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nama Admin', 'Ahmad Fauzi'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Email', 'ahmad@masjid.com'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('No. WhatsApp', '+62 812-3456-7890'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Masjid', 'Masjid Al-Barkah'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Dashboard Masjid'),
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? _buildDashboardContent()
          : _buildProfileContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.medium,
              color: AppColors.textSubdued,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textBase,
            ),
          ),
        ),
      ],
    );
  }
}
