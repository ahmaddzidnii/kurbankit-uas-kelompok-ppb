import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';

class RecipientFormPage extends StatefulWidget {
  const RecipientFormPage({super.key});

  @override
  State<RecipientFormPage> createState() => _RecipientFormPageState();
}

class _RecipientFormPageState extends State<RecipientFormPage> {
  final _nameController = TextEditingController();
  final _kkController = TextEditingController();
  final _memberCountController = TextEditingController();
  final _rtController = TextEditingController(text: '001');
  final _rwController = TextEditingController(text: '002');
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _kkController.dispose();
    _memberCountController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await authRepository.logout();
    await UserRoleService.clearUserRoleData();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
  }

  Future<void> _saveRecipient() async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.trim().isEmpty ||
        _kkController.text.trim().isEmpty ||
        _memberCountController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data penerima terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data penerima berhasil disimpan')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBase),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Family Member',
          style: TextStyle(
            color: AppColors.essentialBrightAccent,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textBase),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Penerima',
                style: TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Masukkan informasi detail kepala keluarga untuk pendaftaran bantuan sosial.',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSubdued,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildFieldLabel('Nama Kepala Keluarga'),
              _buildTextField(
                controller: _nameController,
                hintText: 'Contoh: Budi Santoso',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFieldLabel('Nomor Kartu Keluarga (KK)'),
              _buildTextField(
                controller: _kkController,
                hintText: '16 digit nomor seri',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Anggota Keluarga'),
                        _buildTextField(
                          controller: _memberCountController,
                          hintText: 'Jumlah (jiwa)',
                          icon: Icons.people_outline_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('RT'),
                        _buildSmallField(_rtController),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('RW'),
                        _buildSmallField(_rwController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFieldLabel('Alamat Lengkap'),
              _buildTextField(
                controller: _addressController,
                hintText: 'Nama jalan, gedung, blok, no. rumah...',
                icon: Icons.location_on_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveRecipient,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      'Simpan Data',
                      style: TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: AppTypography.semiBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.essentialBrightAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSubdued),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.essentialBrightAccent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: controller.text,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.essentialBrightAccent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
