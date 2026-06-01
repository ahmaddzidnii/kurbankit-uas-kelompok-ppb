import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/features/mosque_dashboard/data/models/period_model.dart';

class PeriodsPage extends StatefulWidget {
  const PeriodsPage({super.key});

  @override
  State<PeriodsPage> createState() => _PeriodsPageState();
}

class _PeriodsPageState extends State<PeriodsPage> {
  late Future<List<PeriodModel>> _periodsFuture;

  @override
  void initState() {
    super.initState();
    _periodsFuture = _loadPeriods();
  }

  Future<List<PeriodModel>> _loadPeriods() {
    return periodDataSource.getPeriods();
  }

  Future<void> _refreshPeriods({bool showMessage = false}) async {
    setState(() {
      _periodsFuture = _loadPeriods();
    });

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar periode diperbarui')),
      );
    }
  }

  Future<void> _reloadPeriods() async {
    setState(() {
      _periodsFuture = _loadPeriods();
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
      backgroundColor: Colors.transparent,
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
    } catch (e) {
      if (!mounted) {
        return;
      }

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Periode'),
        content: Text(
          'Hapus ${period.displayTitle}? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await periodDataSource.deletePeriod(period.id);
                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(dialogContext).pop(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _resolveErrorMessage(e, 'Gagal menghapus periode'),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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

                if (!dialogContext.mounted) {
                  return;
                }

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

            return AlertDialog(
              title: Text(period == null ? 'Tambah Periode' : 'Edit Periode'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Periode',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama periode wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: hijriahController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun Hijriah',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tahun Hijriah wajib diisi';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: masehiController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun Masehi',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tahun Masehi wajib diisi';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      if (period != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Aktif'),
                            Switch(
                              value: isActive,
                              onChanged: (value) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: Text(isSubmitting ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
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
                  children: [
                    SizedBox(
                      height: 160,
                      child: const Center(child: CircularProgressIndicator()),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          period.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppTypography.headingSmall,
                            fontWeight: AppTypography.bold,
                            color: AppColors.textBase,
                          ),
                        ),
                      ),
                      //   const SizedBox(width: AppSpacing.sm),
                      //   _buildStatusChip(period.isActive),
                    ],
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

  // Widget _buildStatusChip(bool isActive) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: AppSpacing.sm,
  //       vertical: 6,
  //     ),
  //     decoration: BoxDecoration(
  //       color: isActive
  //           ? AppColors.essentialBrightAccent.withOpacity(0.12)
  //           : AppColors.decorativeSubdued.withOpacity(0.15),
  //       borderRadius: BorderRadius.circular(AppRadius.full),
  //     ),
  //     child: Text(
  //       isActive ? 'Aktif' : 'Nonaktif',
  //       style: TextStyle(
  //         color: isActive
  //             ? AppColors.essentialBrightAccent
  //             : AppColors.textSubdued,
  //         fontSize: AppTypography.labelSmall,
  //         fontWeight: AppTypography.semiBold,
  //       ),
  //     ),
  //   );
  // }

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
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
    }

    if (_error != null || _period == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat detail periode',
                  style: TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textBase,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _fetch,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // When loaded, return the original detail sheet directly (no extra padding wrapper)
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
    if (_isBusy || value == _isActive) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    await widget.onToggleActive(value);

    if (!mounted) {
      return;
    }

    setState(() {
      _isActive = value;
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
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
                    onPressed: _isBusy
                        ? null
                        : () => Navigator.of(context).pop(),
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
                  onPressed: _isBusy ? null : widget.onEdit,
                  child: const Text('Edit Periode'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isBusy ? null : widget.onDelete,
                  child: const Text(
                    'Hapus Periode',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
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
