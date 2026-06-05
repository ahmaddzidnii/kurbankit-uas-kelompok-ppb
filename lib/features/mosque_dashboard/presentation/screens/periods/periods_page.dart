import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:qurban_kit/core/services/cache_service.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/features/mosque_dashboard/data/models/period_model.dart';

class PeriodsPage extends StatefulWidget {
  const PeriodsPage({super.key});

  @override
  State<PeriodsPage> createState() => _PeriodsPageState();
}

class _PeriodsPageState extends State<PeriodsPage> {
  late Future<List<PeriodModel>> _periodsFuture;
  final _cacheService = CacheService();
  static const _cacheKey = 'periods_list';

  @override
  void initState() {
    super.initState();
    _periodsFuture = _loadPeriods();
  }

  Future<List<PeriodModel>> _loadPeriods({bool forceRefresh = false}) {
    if (forceRefresh) {
      _cacheService.invalidate(_cacheKey);
    }

    return _cacheService.get<List<PeriodModel>>(
      key: _cacheKey,
      compute: () => periodDataSource.getPeriods(),
      ttl: const Duration(minutes: 5),
    );
  }

  Future<void> _refreshPeriods({bool showMessage = false}) async {
    setState(() {
      _periodsFuture = _loadPeriods(forceRefresh: true);
    });

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar periode diperbarui')),
      );
    }
  }

  Future<void> _reloadPeriods() async {
    setState(() {
      _periodsFuture = _loadPeriods(forceRefresh: true);
    });
    await _periodsFuture;
  }

  Future<void> _openCreateDialog() async {
    final saved = await _showPeriodForm();
    if (saved && mounted) {
      await _refreshPeriods();
    }
  }

  Future<void> _openDetailSheet(String periodId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.backgroundElevatedBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      builder: (sheetContext) => _PeriodDetailLoader(
        periodId: periodId,
        onEdit: (period) async {
          Navigator.of(sheetContext).pop();
          final saved = await _showPeriodForm(period: period);
          if (saved && mounted) {
            await _refreshPeriods();
          }
        },
        onDelete: (period) async {
          final deleted = await _confirmDelete(period);
          if (deleted && mounted) {
            Navigator.of(sheetContext).pop();
            await _refreshPeriods();
          }
        },
        onToggleActive: (period, value) async {
          await _toggleActive(period, value);
          if (mounted) {
            await _refreshPeriods();
          }
        },
      ),
    );
  }

  Future<void> _toggleActive(PeriodModel period, bool value) async {
    try {
      if (value && !period.isActive) {
        await periodDataSource.activatePeriod(period.id);
      } else if (!value && period.isActive) {
        await periodDataSource.updatePeriod(period.id, isActive: false);
      }
      // sync cached active period after successful change
      try {
        final prefs = await SharedPreferences.getInstance();
        final periods = await periodDataSource.getPeriods();
        final actives = periods.where((p) => p.isActive).toList();
        if (actives.isNotEmpty) {
          await prefs.setString(
            'cached_active_period',
            jsonEncode(actives.first.toJson()),
          );
        } else {
          await prefs.remove('cached_active_period');
        }
      } catch (_) {
        // ignore cache write errors
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _resolveErrorMessage(e, 'Gagal memperbarui status periode'),
          ),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(PeriodModel period) async {
    bool isDeleting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Kunci layar agar user tidak menutup dialog secara tidak sengaja saat proses hapus berjalan
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundElevatedBase,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              // Atur padding content dan tombol aksi agar presisi
              contentPadding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON PERINGATAN (Destructive Visual Indicator)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // JUDUL DIALOG
                  const Text(
                    'Hapus Periode',
                    style: TextStyle(
                      fontSize: AppTypography.headingSmall,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // DESKRIPSI WARNING
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubdued,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Apakah Anda yakin ingin menghapus ',
                        ),
                        TextSpan(
                          text: period.displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBase,
                          ),
                        ),
                        const TextSpan(
                          text:
                              '? Semua data perhitungan di dalam periode ini akan ikut terhapus secara permanen.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    // --- TOMBOL BATAL ---
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textBase,
                            disabledForegroundColor: AppColors.textSubdued,
                            side: BorderSide(
                              color: AppColors.decorativeSubdued,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: isDeleting
                              ? null
                              : () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Batal'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // --- TOMBOL KONFIRMASI HAPUS ---
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.decorativeSubdued,
                            disabledForegroundColor: AppColors.textSubdued,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isDeleting
                              ? null
                              : () async {
                                  setDialogState(() => isDeleting = true);
                                  try {
                                    await periodDataSource.deletePeriod(
                                      period.id,
                                    );

                                    // if deleted period was active, clear cache
                                    try {
                                      if (period.isActive) {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.remove(
                                          'cached_active_period',
                                        );
                                      }
                                    } catch (_) {}

                                    if (dialogContext.mounted) {
                                      Navigator.of(dialogContext).pop(true);
                                    }
                                  } catch (e) {
                                    if (dialogContext.mounted) {
                                      // Kembalikan state ke normal jika gagal, lalu tutup dialog dengan return false
                                      setDialogState(() => isDeleting = false);
                                      Navigator.of(dialogContext).pop(false);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _resolveErrorMessage(
                                              e,
                                              'Gagal menghapus periode',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isDeleting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Hapus',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    return confirmed ?? false;
  }

  Future<bool> _showPeriodForm({PeriodModel? period}) async {
    final formKey = GlobalKey<FormState>();
    final initialHijriah = period?.tahunHijriah ?? 0;
    final initialMasehi = period?.tahunMasehi ?? 0;
    final nameController = TextEditingController(text: period?.nama ?? '');
    final hijriahController = TextEditingController(
      text: initialHijriah == 0 ? '' : initialHijriah.toString(),
    );
    final masehiController = TextEditingController(
      text: initialMasehi == 0 ? '' : initialMasehi.toString(),
    );
    bool isActive = period?.isActive ?? false;
    bool isSubmitting = false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Agar sheet bergeser naik secara fleksibel
      showDragHandle: true,
      backgroundColor: AppColors.backgroundElevatedBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> submit() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              setDialogState(() {
                isSubmitting = true;
              });

              try {
                final nama = nameController.text.trim();
                final tahunHijriah = int.parse(hijriahController.text.trim());
                final tahunMasehi = int.parse(masehiController.text.trim());

                if (period == null) {
                  await periodDataSource.createPeriod(
                    nama: nama,
                    tahunHijriah: tahunHijriah,
                    tahunMasehi: tahunMasehi,
                  );
                } else {
                  await periodDataSource.updatePeriod(
                    period.id,
                    nama: nama,
                    tahunHijriah: tahunHijriah,
                    tahunMasehi: tahunMasehi,
                    isActive: isActive,
                  );
                }

                // sync cached active period after create/update
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final periods = await periodDataSource.getPeriods();
                  final actives = periods.where((p) => p.isActive).toList();
                  if (actives.isNotEmpty) {
                    await prefs.setString(
                      'cached_active_period',
                      jsonEncode(actives.first.toJson()),
                    );
                  } else {
                    await prefs.remove('cached_active_period');
                  }
                } catch (_) {}

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _resolveErrorMessage(e, 'Gagal menyimpan periode'),
                      ),
                    ),
                  );
                  setDialogState(() {
                    isSubmitting = false;
                  });
                }
              }
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.xs,
                  // PERBAIKAN: Menggunakan dialogContext untuk menghitung ruang keyboard hp secara real-time
                  bottom:
                      AppSpacing.lg +
                      MediaQuery.of(dialogContext).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period == null
                              ? 'Tambah Periode Baru'
                              : 'Edit Data Periode',
                          style: const TextStyle(
                            fontSize: AppTypography.headingMedium,
                            fontWeight: AppTypography.bold,
                            color: AppColors.textBase,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Periode',
                            hintText: 'Contoh: Idul Adha 1447 H',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama periode wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: hijriahController,
                                decoration: const InputDecoration(
                                  labelText: 'Tahun Hijriah',
                                  hintText: '1447',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: masehiController,
                                decoration: const InputDecoration(
                                  labelText: 'Tahun Masehi',
                                  hintText: '2026',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        if (period != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.decorativeSubdued.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Set sebagai Periode Aktif',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (value) {
                                    setDialogState(() => isActive = value);
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor:
                                      AppColors.essentialBrightAccent,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            // --- Tombol Batal ---
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors
                                        .textBase, // Pindahkan warna utama ke sini
                                    disabledForegroundColor: AppColors
                                        .textSubdued, // Warna teks saat disabled
                                    side: BorderSide(
                                      color: isSubmitting
                                          ? AppColors.decorativeSubdued
                                                .withOpacity(0.4)
                                          : AppColors.decorativeSubdued,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                  ),
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.of(
                                          dialogContext,
                                        ).pop(false),
                                  child: const Text(
                                    'Batal',
                                  ), // TextStyle warna manual dihapus agar transisi disabled mulus
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // --- Tombol Simpan ---
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.essentialBrightAccent,
                                    foregroundColor: Colors.white,
                                    // Setup warna disabled agar serasi dengan sistem design Anda
                                    disabledBackgroundColor:
                                        AppColors.decorativeSubdued,
                                    disabledForegroundColor:
                                        AppColors.textSubdued,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: isSubmitting ? null : submit,
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.textSubdued,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Simpan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        title: const Text(
          'Periode',
          style: TextStyle(
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textBase,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.essentialBrightAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reloadPeriods,
          child: FutureBuilder<List<PeriodModel>>(
            future: _periodsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: const [
                    SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [_buildErrorState(snapshot.error)],
                );
              }

              final periods = snapshot.data ?? const <PeriodModel>[];
              if (periods.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [_buildEmptyState()],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: periods.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _buildSummaryCard(periods),
                    );
                  }

                  final period = periods[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildPeriodCard(period),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<PeriodModel> periods) {
    final activeCount = periods.where((period) => period.isActive).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.essentialBrightAccent,
            AppColors.essentialBrightAccent.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.event_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Periode',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${periods.length} periode terdaftar • $activeCount aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(PeriodModel period) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => _openDetailSheet(period.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          border: Border.all(
            color: period.isActive
                ? AppColors.essentialBrightAccent.withOpacity(0.3)
                : AppColors.decorativeSubdued,
            width: period.isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: period.isActive
                    ? AppColors.essentialBrightAccent.withOpacity(0.12)
                    : AppColors.decorativeSubdued.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                period.isActive
                    ? Icons.event_available_rounded
                    : Icons.event_outlined,
                color: period.isActive
                    ? AppColors.essentialBrightAccent
                    : AppColors.textSubdued,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppTypography.headingSmall,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    period.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.decorativeSubdued),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 56,
            color: AppColors.textSubdued,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Belum ada periode',
            style: TextStyle(
              color: AppColors.textBase,
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tambahkan periode pertama untuk masjid ini melalui tombol +.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSubdued,
              fontSize: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.decorativeSubdued),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppColors.textSubdued,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Gagal memuat periode',
            style: TextStyle(
              color: AppColors.textBase,
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _resolveErrorMessage(
              error ?? 'Terjadi kesalahan',
              'Gagal memuat periode',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSubdued,
              fontSize: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _refreshPeriods,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _PeriodDetailLoader extends StatefulWidget {
  final String periodId;
  final Future<void> Function(PeriodModel) onEdit;
  final Future<void> Function(PeriodModel) onDelete;
  final Future<void> Function(PeriodModel, bool) onToggleActive;

  const _PeriodDetailLoader({
    required this.periodId,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  State<_PeriodDetailLoader> createState() => _PeriodDetailLoaderState();
}

class _PeriodDetailLoaderState extends State<_PeriodDetailLoader> {
  PeriodModel? _period;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final p = await periodDataSource.getPeriodById(widget.periodId);
      if (!mounted) return;
      setState(() {
        _period = p;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_error != null || _period == null) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gagal memuat detail periode',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(onPressed: _fetch, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return _PeriodDetailSheet(
      period: _period!,
      onEdit: () => widget.onEdit(_period!),
      onDelete: () => widget.onDelete(_period!),
      onToggleActive: (value) => widget.onToggleActive(_period!, value),
    );
  }
}

class _PeriodDetailSheet extends StatefulWidget {
  final PeriodModel period;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function(bool value) onToggleActive;

  const _PeriodDetailSheet({
    required this.period,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  State<_PeriodDetailSheet> createState() => _PeriodDetailSheetState();
}

class _PeriodDetailSheetState extends State<_PeriodDetailSheet> {
  late bool _isActive;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.period.isActive;
  }

  Future<void> _handleToggle(bool value) async {
    if (_isBusy || value == _isActive) return;

    setState(() {
      _isBusy = true;
    });

    await widget.onToggleActive(value);

    if (!mounted) return;

    setState(() {
      _isActive = value;
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Detail Periode',
                    style: TextStyle(
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow('Nama', widget.period.displayTitle),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(
              'Tahun Hijriah',
              widget.period.tahunHijriah.toString(),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(
              'Tahun Masehi',
              widget.period.tahunMasehi.toString(),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(
              'ID',
              widget.period.id.isEmpty ? '-' : widget.period.id,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: AppColors.textSubdued,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: _isBusy ? null : _handleToggle,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.essentialBrightAccent,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.decorativeSubdued,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.essentialBrightAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.decorativeSubdued,
                  disabledForegroundColor: AppColors.textSubdued,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: _isBusy ? 0 : 1,
                ),
                onPressed: _isBusy
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        context.push(
                          '/period-calculations',
                          extra: {
                            'periodId': widget.period.id,
                            'periodTitle': widget.period.displayTitle,
                          },
                        );
                      },
                child: const Text('Data Perhitungan'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textBase,
                      disabledForegroundColor: AppColors.textSubdued,
                      side: BorderSide(
                        color: _isBusy
                            ? AppColors.decorativeSubdued.withOpacity(0.5)
                            : AppColors.decorativeSubdued,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isBusy ? null : widget.onEdit,
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      disabledForegroundColor: AppColors.textSubdued,
                      side: BorderSide(
                        color: _isBusy
                            ? AppColors.decorativeSubdued.withOpacity(0.5)
                            : Colors.red,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isBusy ? null : widget.onDelete,
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            color: AppColors.textSubdued,
            fontWeight: AppTypography.medium,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
        ),
      ],
    );
  }
}
