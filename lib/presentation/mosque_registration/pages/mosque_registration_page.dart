import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';

class MosqueRegistrationPage extends StatefulWidget {
  const MosqueRegistrationPage({super.key});

  @override
  State<MosqueRegistrationPage> createState() => _MosqueRegistrationPageState();
}

class _MosqueRegistrationPageState extends State<MosqueRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mosqueName;
  late TextEditingController _operationalNumber;
  late TextEditingController _address;
  String? _selectedProvince;
  String? _selectedCity;
  String? _mosquePhotoPath;
  bool _isLoading = false;

  String? _selectedDistrict;
  String? _selectedVillage;

  // Sample province and city data (will be replaced with API call later)
  final Map<String, List<String>> _provinceCity = {
    'Jawa Timur': ['Malang', 'Surabaya', 'Sidoarjo', 'Pasuruan'],
    'Jawa Barat': ['Bandung', 'Bogor', 'Depok', 'Bekasi'],
    'DKI Jakarta': [
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Utara',
      'Jakarta Timur',
    ],
    'Jawa Tengah': ['Semarang', 'Solo', 'Yogyakarta', 'Kudus'],
  };

  // Placeholder data — nanti diganti API
  final Map<String, List<String>> _cityDistrict = {
    'Semarang': ['Semarang Tengah', 'Banyumanik', 'Tembalang', 'Pedurungan'],
    'Solo': ['Laweyan', 'Serengan', 'Pasar Kliwon', 'Banjarsari'],
    // ... isi sesuai kebutuhan sementara
  };

  final Map<String, List<String>> _districtVillage = {
    'Banyumanik': ['Banyumanik', 'Gedawang', 'Jabungan', 'Pudakpayung'],
    'Tembalang': ['Tembalang', 'Kedungmundu', 'Sambiroto', 'Bulusan'],
    // ... isi sesuai kebutuhan sementara
  };

  @override
  void initState() {
    super.initState();
    _mosqueName = TextEditingController();
    _operationalNumber = TextEditingController();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    _mosqueName.dispose();
    _operationalNumber.dispose();
    _address.dispose();
    super.dispose();
  }

  void _selectMosquePhoto() {
    // TODO: Implement image picker
    print('Select mosque photo');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Call API to submit registration
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        // Show success dialog
        _showSuccessDialog();
      });
    }
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

  Future<void> _quickTestSkipRegistration() async {
    // Quick test function - skip registration and go to admin dashboard
    try {
      await UserRoleService.setMosqueRegistered(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test mode: Mosque marked as registered!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to admin dashboard
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/mosque-admin-dashboard');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevatedBase,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkmark icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.essentialBrightAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.essentialBrightAccent,
                    size: 60,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                const Text(
                  'Pendaftaran Terkikim!',
                  style: TextStyle(
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textBase,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // Message
                Text(
                  'Terima kasih, admin masjid ${_mosqueName.text}. Pendaftaran masjid Anda sedang diverifikasi oleh Super Admin. Kami akan mengirim Anda melalui email dan WhatsApp dalam 1-3 hari kerja.',
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: AppColors.textSubdued,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Close button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to mosque dashboard waiting
                    Navigator.pushReplacementNamed(
                      context,
                      '/mosque-dashboard-waiting',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.essentialBrightAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        title: const Text('Registrasi Masjid'),
        elevation: 0,
        actions: [
          // Quick test button (for development)
          Tooltip(
            message: 'Skip registration & test dashboard (DEV ONLY)',
            child: IconButton(
              onPressed: _quickTestSkipRegistration,
              icon: const Icon(Icons.fast_forward),
            ),
          ),
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                const Text(
                  'Informasi Dasar Masjid',
                  style: TextStyle(
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textBase,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Masukkan detail dasar masjid untuk diverikasi.',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: AppColors.textSubdued,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Mosque name field
                Text(
                  'Nama Masjid (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _mosqueName,
                  decoration: InputDecoration(
                    hintText: 'Masjid Al-Barkah',
                    prefixIcon: const Icon(Icons.mosque),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama masjid tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Operational number field
                Text(
                  'Nomor Izin Operasional / SK (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _operationalNumber,
                  decoration: InputDecoration(
                    hintText: '001/SK-1234/V/2026',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // SK photo field
                Text(
                  'Unggah Foto SK (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: _selectMosquePhoto,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSubdued.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.textSubdued.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _mosquePhotoPath ??
                              'Ketuk di Sini untuk mengunggah SK',
                          style: const TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.textSubdued,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Format: JPG/PNG, maks 5MB',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: AppColors.textSubdued.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Mosque photo field
                Text(
                  'Unggah Foto Masjid (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: _selectMosquePhoto,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSubdued.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.textSubdued.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _mosquePhotoPath ??
                              'Ketuk di Sini untuk mengunggah foto masjid',
                          style: const TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.textSubdued,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Format: JPG/PNG, maks 5MB',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: AppColors.textSubdued.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Address field
                Text(
                  'Alamat Lengkap Masjid (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _address,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Jl. Kenanga No. 12, RT 01/RW 03...',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat masjid tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Province dropdown
                Text(
                  'Provinsi (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _selectedProvince,
                  items: _provinceCity.keys
                      .map(
                        (province) => DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = value;
                      _selectedCity = null;
                      _selectedDistrict = null;
                      _selectedVillage = null;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Pilih Provinsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // City dropdown
                Text(
                  'Kabupaten / Kota (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items:
                      (_selectedProvince != null
                              ? _provinceCity[_selectedProvince]!
                              : <String>[])
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                  onChanged: _selectedProvince != null
                      ? (value) {
                          setState(() {
                            _selectedCity = value;
                            _selectedDistrict = null;
                            _selectedVillage = null;
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: _selectedProvince == null
                        ? 'Pilih provinsi dulu'
                        : 'Pilih Kabupaten / Kota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // District (Kecamatan) dropdown
                Text(
                  'Kecamatan (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  items:
                      (_selectedCity != null
                              ? _cityDistrict[_selectedCity] ?? <String>[]
                              : <String>[])
                          .map(
                            (district) => DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            ),
                          )
                          .toList(),
                  onChanged: _selectedCity != null
                      ? (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _selectedVillage = null;
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: _selectedCity == null
                        ? 'Pilih kabupaten dulu'
                        : 'Pilih Kecamatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Village (Desa/Kelurahan) dropdown
                Text(
                  'Desa / Kelurahan (*)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _selectedVillage,
                  items:
                      (_selectedDistrict != null
                              ? _districtVillage[_selectedDistrict] ??
                                    <String>[]
                              : <String>[])
                          .map(
                            (village) => DropdownMenuItem(
                              value: village,
                              child: Text(village),
                            ),
                          )
                          .toList(),
                  onChanged: _selectedDistrict != null
                      ? (value) {
                          setState(() {
                            _selectedVillage = value;
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: _selectedDistrict == null
                        ? 'Pilih kecamatan dulu'
                        : 'Pilih Desa / Kelurahan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.essentialBrightAccent,
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
                            'Kirim',
                            style: TextStyle(
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
