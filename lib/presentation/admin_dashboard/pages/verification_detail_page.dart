import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

class VerificationDetailPage extends StatefulWidget {
  const VerificationDetailPage({super.key});

  @override
  State<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends State<VerificationDetailPage> {
  bool _isLoading = false;

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

  void _approveRegistration() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran telah disetujui')),
      );
    });
  }

  void _rejectRegistration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pendaftaran'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alasan Penolakan',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.medium,
                color: AppColors.textBase,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(),
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
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pendaftaran telah ditolak')),
              );
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
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
        title: const Text('Detail Pendaftaran'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mosque illustration
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mosque,
                      size: 80,
                      color: AppColors.essentialBrightAccent,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Masjid Al-Barkah',
                      style: TextStyle(
                        fontSize: AppTypography.headingMedium,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.essentialBrightAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mosque details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Masjid
                  const Text(
                    'Nama Masjid',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    initialValue: 'Masjid Al-Barkah',
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundHighlight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Nama Admin
                  const Text(
                    'Nama Admin',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    initialValue: 'Ahmad Fauzi',
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundHighlight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // No WhatsApp
                  const Text(
                    'No. WhatsApp',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    initialValue: '+62 812-3456-7890',
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundHighlight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Alamat Lengkap
                  const Text(
                    'Alamat Lengkap',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    initialValue:
                        'Jl. Kenanga No. 12, RT 01/RW 03, Sukun, Malang, Jawa Timur',
                    readOnly: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundHighlight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Documents section
                  const Text(
                    'Dokumen Verifikasi (SK Masjid)',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundHighlight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.backgroundElevatedHighlight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Foto SK Masjid_Barkah.jpg',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.medium,
                                  color: AppColors.textBase,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '2.4 MB',
                                style: TextStyle(
                                  fontSize: AppTypography.bodySmall,
                                  color: AppColors.textSubdued.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Download file
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Documents section - KTP
                  const Text(
                    'Dokumen Verifikasi (KTP Admin)',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: AppColors.textSubdued,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundHighlight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.backgroundElevatedHighlight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KTP_Ahmad_Fauzi.jpg',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.medium,
                                  color: AppColors.textBase,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '1.8 MB',
                                style: TextStyle(
                                  fontSize: AppTypography.bodySmall,
                                  color: AppColors.textSubdued.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Download file
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _approveRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.essentialBrightAccent,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SETUJUI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: AppTypography.medium,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _rejectRegistration,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: const Text(
                            'TOLAK',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: AppTypography.medium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
