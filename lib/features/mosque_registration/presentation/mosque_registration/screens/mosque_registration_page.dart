import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/admin_profile_tab.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/auth/data/services/auth_repository.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/mosque_registration_request_model.dart';
import 'package:qurban_kit/features/mosque_registration/data/services/mosque_repository.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/wilayah_model.dart';
import 'package:qurban_kit/features/mosque_registration/data/services/wilayah_data_source.dart';
import 'package:image_picker/image_picker.dart';

class MosqueRegistrationPage extends StatefulWidget {
  const MosqueRegistrationPage({super.key});

  @override
  State<MosqueRegistrationPage> createState() => _MosqueRegistrationPageState();
}

class _MosqueRegistrationPageState extends State<MosqueRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final WilayahDataSource _wilayahDataSource = getIt<WilayahDataSource>();
  late final Future<UserData?> _profileFuture;
  late TextEditingController _mosqueName;
  late TextEditingController _operationalNumber;
  late TextEditingController _address;

  List<WilayahOption> _provinceOptions = [];
  List<WilayahOption> _cityOptions = [];
  List<WilayahOption> _districtOptions = [];
  List<WilayahOption> _villageOptions = [];
  Future<List<WilayahOption>>? _provinceLoadFuture;
  Future<List<WilayahOption>>? _cityLoadFuture;
  Future<List<WilayahOption>>? _districtLoadFuture;
  Future<List<WilayahOption>>? _villageLoadFuture;

  String? _selectedProvince;
  String? _selectedCity;
  String? _mosquePhotoPath;
  String? _skPhotoPath;
  bool _isLoading = false;
  int _selectedIndex = 0;

  String? _selectedDistrict;
  String? _selectedVillage;

  @override
  void initState() {
    super.initState();
    _profileFuture = getIt<AuthRepository>().getProfile();
    _mosqueName = TextEditingController();
    _operationalNumber = TextEditingController();
    _address = TextEditingController();
    _loadProvinces();
  }

  @override
  void dispose() {
    _mosqueName.dispose();
    _operationalNumber.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces({String? search}) async {
    final future = _wilayahDataSource.getProvinces(search: search);
    setState(() {
      _provinceLoadFuture = future;
      _provinceOptions = [];
    });

    try {
      final provinces = await future;
      if (!mounted) {}

      setState(() {
        _provinceOptions = provinces;
        if (identical(_provinceLoadFuture, future)) {
          _provinceLoadFuture = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (identical(_provinceLoadFuture, future)) {
          _provinceLoadFuture = null;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat provinsi: $e')));
    }
  }

  Future<void> _loadCities(String parentId) async {
    final future = _wilayahDataSource.getKabupaten(parentId: parentId);
    setState(() {
      _cityLoadFuture = future;
      _cityOptions = [];
      _districtOptions = [];
      _villageOptions = [];
    });

    try {
      final cities = await future;
      if (!mounted) {
        return;
      }

      setState(() {
        _cityOptions = cities;
        if (identical(_cityLoadFuture, future)) {
          _cityLoadFuture = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (identical(_cityLoadFuture, future)) {
          _cityLoadFuture = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kabupaten/kota: $e')),
      );
    }
  }

  Future<void> _loadDistricts(String parentId) async {
    final future = _wilayahDataSource.getKecamatan(parentId: parentId);
    setState(() {
      _districtLoadFuture = future;
      _districtOptions = [];
      _villageOptions = [];
    });

    try {
      final districts = await future;
      if (!mounted) {
        return;
      }

      setState(() {
        _districtOptions = districts;
        if (identical(_districtLoadFuture, future)) {
          _districtLoadFuture = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (identical(_districtLoadFuture, future)) {
          _districtLoadFuture = null;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kecamatan: $e')));
    }
  }

  Future<void> _loadVillages(String parentId) async {
    final future = _wilayahDataSource.getDesa(parentId: parentId);
    setState(() {
      _villageLoadFuture = future;
      _villageOptions = [];
    });

    try {
      final villages = await future;
      if (!mounted) {
        return;
      }

      setState(() {
        _villageOptions = villages;
        if (identical(_villageLoadFuture, future)) {
          _villageLoadFuture = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (identical(_villageLoadFuture, future)) {
          _villageLoadFuture = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat desa/kelurahan: $e')),
      );
    }
  }

  WilayahOption? _findOptionById(List<WilayahOption> options, String? id) {
    if (id == null) {
      return null;
    }

    for (final option in options) {
      if (option.id == id) {
        return option;
      }
    }

    return null;
  }

  Future<WilayahOption?> _openWilayahPicker({
    required String title,
    required String searchHint,
    required List<WilayahOption> Function() optionsBuilder,
    Future<List<WilayahOption>>? loadingFuture,
  }) async {
    var currentSearch = '';

    Widget buildPickerContent(List<WilayahOption> options) {
      var filteredOptions = List<WilayahOption>.from(options);

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          void handleSearchChanged(String value) {
            currentSearch = value;

            final query = value.trim().toLowerCase();
            setSheetState(() {
              filteredOptions = query.isEmpty
                  ? List<WilayahOption>.from(options)
                  : options
                        .where(
                          (option) => option.nama.toLowerCase().contains(query),
                        )
                        .toList();
            });
          }

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.78,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevatedBase,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: AppTypography.headingMedium,
                              fontWeight: AppTypography.semiBold,
                              color: AppColors.textBase,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: searchHint,
                        filled: true,
                        fillColor: AppColors.backgroundElevatedBase,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(
                            color: AppColors.decorativeSubdued.withOpacity(0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(
                            color: AppColors.essentialBrightAccent,
                          ),
                        ),
                      ),
                      onChanged: handleSearchChanged,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: filteredOptions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                currentSearch.trim().isEmpty
                                    ? 'Belum ada data'
                                    : 'Tidak ada data yang cocok',
                                style: const TextStyle(
                                  color: AppColors.textSubdued,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredOptions.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final province = filteredOptions[index];
                              return ListTile(
                                title: Text(province.nama),
                                onTap: () {
                                  context.pop(province);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<WilayahOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        if (loadingFuture == null) {
          return buildPickerContent(optionsBuilder());
        }

        return FutureBuilder<List<WilayahOption>>(
          future: loadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevatedBase,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevatedBase,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'Gagal memuat data',
                        style: const TextStyle(color: AppColors.textSubdued),
                      ),
                    ),
                  ),
                ),
              );
            }

            return buildPickerContent(optionsBuilder());
          },
        );
      },
    );
  }

  Future<void> _pickImage({required bool isSK}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final int size = await picked.length();
      if (size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File terlalu besar. Maks 5MB.')),
          );
        }
        return;
      }

      setState(() {
        if (isSK) {
          _skPhotoPath = picked.path;
        } else {
          _mosquePhotoPath = picked.path;
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Image pick error: $e');
    }
  }

  void _removeImage({required bool isSK}) {
    setState(() {
      if (isSK) {
        _skPhotoPath = null;
      } else {
        _mosquePhotoPath = null;
      }
    });
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.backgroundElevatedBase,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: AppColors.decorativeSubdued.withOpacity(0.6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.essentialBrightAccent),
      ),
    );
  }

  Widget _buildUploadField({
    required String label,
    required String placeholder,
    String? currentPath,
    required VoidCallback onPick,
    VoidCallback? onRemove,
  }) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: AppColors.decorativeSubdued.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: currentPath == null
                  ? Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: AppColors.essentialBrightAccent,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.file(
                        File(currentPath),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              currentPath ?? placeholder,
              style: const TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (currentPath != null && onRemove != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.close, color: AppColors.essentialSubdued),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVillage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih desa/kelurahan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (_mosquePhotoPath == null || _skPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah foto masjid dan dokumen SK.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = MosqueRegistrationRequest(
        nama: _mosqueName.text.trim(),
        nomorSk: _operationalNumber.text.trim().isEmpty
            ? null
            : _operationalNumber.text.trim(),
        alamat: _address.text.trim(),
        idDesa: _selectedVillage!,
        fotoMasjidPath: _mosquePhotoPath,
        fotoDokumenSkPath: _skPhotoPath,
      );

      await getIt<MosqueRepository>().registerMosque(request);

      if (!mounted) return;

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      final message = _resolveErrorMessage(
        e,
        'Gagal mengirim data pendaftaran',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _resolveErrorMessage(Object error, String fallback) {
    if (error is ValidationException) {
      final errors = error.errors;
      if (errors != null && errors.isNotEmpty) {
        final firstEntry = errors.entries.first;
        final field = firstEntry.key.toString();
        final value = firstEntry.value;

        if (value is List && value.isNotEmpty) {
          return '$field: ${value.first}';
        }

        return '$field: $value';
      }

      if (error.message.trim().isNotEmpty) {
        return error.message;
      }
    }

    if (error is AppException && error.message.trim().isNotEmpty) {
      return error.message;
    }

    return fallback;
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final authRepository = getIt<AuthRepository>();
              await authRepository.logout();
              await UserRoleService.clearUserRoleData();

              if (mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                    context.pop();
                    // TODO: Navigate to mosque dashboard waiting
                    context.go('/mosque-dashboard-waiting');
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
    const titles = ['Registrasi Masjid', 'Profil'];
    final pages = [
      _buildRegistrationContent(),
      AdminProfileTab(profileFuture: _profileFuture, onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
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
              label: 'Registrasi',
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

  Widget _buildRegistrationContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mosque name field
                  Text(
                    'Nama Masjid (*)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _mosqueName,
                    decoration: _inputDecoration(hint: 'Masjid Al-Barkah'),
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
                    decoration: _inputDecoration(hint: '001/SK-1234/V/2026'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // SK photo field
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: _buildUploadField(
                      label: 'Unggah Foto SK (*)',
                      placeholder: 'Ketuk di Sini untuk mengunggah SK',
                      currentPath: _skPhotoPath,
                      onPick: () => _pickImage(isSK: true),
                      onRemove: () => _removeImage(isSK: true),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mosque photo field
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: _buildUploadField(
                      label: 'Unggah Foto Masjid (*)',
                      placeholder: 'Ketuk di Sini untuk mengunggah foto masjid',
                      currentPath: _mosquePhotoPath,
                      onPick: () => _pickImage(isSK: false),
                      onRemove: () => _removeImage(isSK: false),
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
                    decoration: _inputDecoration(
                      hint: 'Jl. Kenanga No. 12, RT 01/RW 03...',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat masjid tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Province selector
                  Text(
                    'Provinsi (*)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FormField<String>(
                    initialValue: _selectedProvince,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Provinsi wajib dipilih';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              final province = await _openWilayahPicker(
                                title: 'Pilih Provinsi',
                                searchHint: 'Cari provinsi, mis. yog',
                                optionsBuilder: () => _provinceOptions,
                                loadingFuture: _provinceLoadFuture,
                              );

                              if (province == null) {
                                return;
                              }

                              setState(() {
                                _selectedProvince = province.id;
                                _selectedCity = null;
                                _selectedDistrict = null;
                                _selectedVillage = null;
                                _cityOptions = [];
                                _districtOptions = [];
                                _villageOptions = [];
                              });
                              state.didChange(province.id);
                              _loadCities(province.id);
                            },
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hint: 'Pilih Provinsi',
                              ),
                              isEmpty: _selectedProvince == null,
                              child: _selectedProvince == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _findOptionById(
                                            _provinceOptions,
                                            _selectedProvince,
                                          )?.nama ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textBase,
                                      ),
                                    ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // City selector
                  Text(
                    'Kabupaten / Kota (*)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FormField<String>(
                    initialValue: _selectedCity,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kabupaten / kota wajib dipilih';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _selectedProvince == null
                                ? null
                                : () async {
                                    final city = await _openWilayahPicker(
                                      title: 'Pilih Kabupaten / Kota',
                                      searchHint: 'Cari kabupaten / kota',
                                      optionsBuilder: () => _cityOptions,
                                      loadingFuture: _cityLoadFuture,
                                    );

                                    if (city == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedCity = city.id;
                                      _selectedDistrict = null;
                                      _selectedVillage = null;
                                      _districtOptions = [];
                                      _villageOptions = [];
                                    });
                                    state.didChange(city.id);
                                    _loadDistricts(city.id);
                                  },
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hint: _selectedProvince == null
                                    ? 'Pilih provinsi dulu'
                                    : 'Pilih Kabupaten / Kota',
                              ),
                              isEmpty: _selectedCity == null,
                              child: _selectedCity == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _findOptionById(
                                            _cityOptions,
                                            _selectedCity,
                                          )?.nama ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textBase,
                                      ),
                                    ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // District selector
                  Text(
                    'Kecamatan (*)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FormField<String>(
                    initialValue: _selectedDistrict,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kecamatan wajib dipilih';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _selectedCity == null
                                ? null
                                : () async {
                                    final district = await _openWilayahPicker(
                                      title: 'Pilih Kecamatan',
                                      searchHint: 'Cari kecamatan',
                                      optionsBuilder: () => _districtOptions,
                                      loadingFuture: _districtLoadFuture,
                                    );

                                    if (district == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedDistrict = district.id;
                                      _selectedVillage = null;
                                      _villageOptions = [];
                                    });
                                    state.didChange(district.id);
                                    _loadVillages(district.id);
                                  },
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hint: _selectedCity == null
                                    ? 'Pilih kabupaten dulu'
                                    : 'Pilih Kecamatan',
                              ),
                              isEmpty: _selectedDistrict == null,
                              child: _selectedDistrict == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _findOptionById(
                                            _districtOptions,
                                            _selectedDistrict,
                                          )?.nama ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textBase,
                                      ),
                                    ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Village selector
                  Text(
                    'Desa / Kelurahan (*)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FormField<String>(
                    initialValue: _selectedVillage,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Desa / kelurahan wajib dipilih';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _selectedDistrict == null
                                ? null
                                : () async {
                                    final village = await _openWilayahPicker(
                                      title: 'Pilih Desa / Kelurahan',
                                      searchHint: 'Cari desa / kelurahan',
                                      optionsBuilder: () => _villageOptions,
                                      loadingFuture: _villageLoadFuture,
                                    );

                                    if (village == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedVillage = village.id;
                                    });
                                    state.didChange(village.id);
                                  },
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hint: _selectedDistrict == null
                                    ? 'Pilih kecamatan dulu'
                                    : 'Pilih Desa / Kelurahan',
                              ),
                              isEmpty: _selectedVillage == null,
                              child: _selectedVillage == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _findOptionById(
                                            _villageOptions,
                                            _selectedVillage,
                                          )?.nama ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textBase,
                                      ),
                                    ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.essentialBrightAccent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
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
      ),
    );
  }
}
