import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/cache_service.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

import 'package:go_router/go_router.dart';

class PeriodCalculationsPage extends StatefulWidget {
  final String periodId;
  final String periodTitle;

  const PeriodCalculationsPage({
    super.key,
    required this.periodId,
    required this.periodTitle,
  });

  @override
  State<PeriodCalculationsPage> createState() => _PeriodCalculationsPageState();
}

class _PeriodCalculationsPageState extends State<PeriodCalculationsPage>
    with SingleTickerProviderStateMixin {
  final _cache = CacheService();
  late List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  late String _cacheKey;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cacheKey = 'period_calculations_${widget.periodId}';
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final serverItems = await calculationDataSource.getCalculationsForPeriod(
        widget.periodId,
      );
      _items = serverItems.map((e) => Map<String, dynamic>.from(e)).toList();
      await _saveItems();
    } catch (_) {
      try {
        final cached = _cache.read<List<dynamic>>(_cacheKey);
        if (cached != null && cached.isNotEmpty) {
          _items = cached.cast<Map<String, dynamic>>();
        } else {
          _items = <Map<String, dynamic>>[];
        }
      } catch (_) {
        _items = <Map<String, dynamic>>[];
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveItems() async {
    _cache.invalidate(_cacheKey);
    try {
      if ((_cache as dynamic).set != null) {
        await (_cache as dynamic).set(_cacheKey, _items);
      } else if ((_cache as dynamic).put != null) {
        await (_cache as dynamic).put(_cacheKey, _items);
      } else {
        await _cache.get<List<dynamic>>(
          key: _cacheKey,
          compute: () async => _items.cast<dynamic>(),
          ttl: const Duration(days: 7),
        );
      }
    } catch (_) {
      await _cache.get<List<dynamic>>(
        key: _cacheKey,
        compute: () async => _items.cast<dynamic>(),
        ttl: const Duration(days: 7),
      );
    }
  }

  Future<void> _deleteItem(String id) async {
    // Optimistically remove from local list, attempt delete on server,
    // and revert if the server call fails.
    final index = _items.indexWhere((e) => e['id'] == id);
    if (index == -1) return;
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    try {
      await calculationDataSource.deleteCalculation(id);
      await _saveItems();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perhitungan berhasil dihapus')),
        );
      }
    } catch (e) {
      // revert
      setState(() => _items.insert(index, removed));
      await _saveItems();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus perhitungan: $e')),
        );
      }
    }
  }

  void _showEditNameDialog(Map<String, dynamic> item) {
    final titleRaw = item['title']?.toString().trim();
    final currentTitle = (titleRaw != null && titleRaw.isNotEmpty)
        ? titleRaw
        : '';
    final nameController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        bool _saving = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Ubah Nama Perhitungan'),
              content: TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama baru...',
                  border: UnderlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (nameController.text.trim().isNotEmpty) {
                            final newTitle = nameController.text.trim();
                            final oldTitle = item['title'];
                            // Optimistically update UI
                            setState(() {
                              item['title'] = newTitle;
                            });

                            setStateDialog(() => _saving = true);
                            try {
                              final res = await calculationDataSource
                                  .updateCalculationTitle(
                                    item['id'].toString(),
                                    newTitle,
                                  );
                              if (res.isNotEmpty) {
                                item.addAll(res);
                                item['title'] =
                                    res['judul'] ?? res['title'] ?? newTitle;
                              }
                              await _saveItems();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nama perhitungan diperbarui',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // revert on failure
                              setState(() {
                                item['title'] = oldTitle;
                              });
                              await _saveItems();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal memperbarui nama: $e'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted)
                                setStateDialog(() => _saving = false);
                            }
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOptionsBottomSheet(Map<String, dynamic> item) {
    final titleRaw = item['title']?.toString().trim();
    final displayTitle = (titleRaw != null && titleRaw.isNotEmpty)
        ? titleRaw
        : 'Perhitungan Tanpa Judul';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundElevatedBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Ubah Nama'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditNameDialog(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(item['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTemplateName(String? rawTemplate) {
    if (rawTemplate == null || rawTemplate.isEmpty) return 'Template Standar';

    switch (rawTemplate) {
      case 'DISTRIBUSI_KUSTOM':
        return 'Distribusi Kustom';
      case 'PROPORSIONAL_SEDERHANA':
        return 'Proporsional Sederhana';
      default:
        return rawTemplate
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
            )
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.periodTitle),
          backgroundColor: AppColors.backgroundBase,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.essentialBrightAccent,
            labelColor: AppColors.textBase,
            unselectedLabelColor: AppColors.textSubdued,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Sapi'),
              Tab(text: 'Kambing'),
            ],
          ),
        ),
        backgroundColor: AppColors.backgroundBase,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnimalList('sapi'),
                    _buildAnimalList('kambing'),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAnimalList(String animalType) {
    final filteredItems = _items
        .where(
          (item) => item['animalType']?.toString().toLowerCase() == animalType,
        )
        .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.list_alt, size: 56, color: AppColors.textSubdued),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Belum ada data perhitungan ${animalType == 'sapi' ? 'Sapi' : 'Kambing'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Simpan hasil perhitungan baru menggunakan tombol + di bawah.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSubdued),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: filteredItems.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.decorativeSubdued,
      ),
      itemBuilder: (ctx, i) {
        final item = filteredItems[i];

        final titleRaw = item['title']?.toString().trim();
        final displayTitle = (titleRaw != null && titleRaw.isNotEmpty)
            ? titleRaw
            : 'Perhitungan Tanpa Judul';

        final rawTemplate = item['template'] ?? item['templateName'];
        final displayTemplate = _formatTemplateName(rawTemplate?.toString());

        return InkWell(
          onTap: () {
            try {
              final key = 'period_calc_item_${item['id']}';
              _cache.set(key: key, value: item, ttl: const Duration(hours: 1));
            } catch (_) {}

            context
                .push(
                  '/period-calculation-detail/${item['id']}',
                  extra: {
                    'title': displayTitle,
                    'animalType': item['animalType'],
                  },
                )
                .then((_) {
                  _loadItems();
                });
          },
          onLongPress: () => _showOptionsBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Ikon di sebelah kiri
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.essentialBrightAccent.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: AppColors.essentialBrightAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayTemplate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Ikon panah di sebelah kanan
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSubdued.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
