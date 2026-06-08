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
      // Coba ambil dari server terlebih dahulu
      final serverItems = await calculationDataSource.getCalculationsForPeriod(
        widget.periodId,
      );
      _items = serverItems.map((e) => Map<String, dynamic>.from(e)).toList();
      // simpan hasil server (boleh kosong) ke cache agar offline tetap akurat
      await _saveItems();
    } catch (_) {
      // Jika fetch gagal, coba ambil dari cache. Jika cache kosong, tetap kosong (tampilkan empty state).
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
    setState(() => _items.removeWhere((e) => e['id'] == id));
    await _saveItems();
  }

  // Dialog untuk mengganti nama item (Auto-generated name override)
  void _showEditNameDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['title']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  item['title'] = nameController.text.trim();
                });
                await _saveItems();
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet opsi ketika item ditahan (Long Press)
  void _showOptionsBottomSheet(Map<String, dynamic> item) {
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
                  item['title'] ?? '-',
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
        .where((item) => item['animalType'] == animalType)
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

        // Mengembalikan InkWell secara langsung tanpa dibungkus Dismissible
        return InkWell(
          onTap: () {
            // Cache selected item (so detail page can render without extra API)
            try {
              final key = 'period_calc_item_${item['id']}';
              // Use CacheService.set with named params
              _cache.set(key: key, value: item, ttl: const Duration(hours: 1));
            } catch (_) {}

            // Navigasi menggunakan GoRouter dengan membawa ID di path, dan data lain di extra
            context
                .push(
                  '/period-calculation-detail/${item['id']}',
                  extra: {
                    'title': item['title'],
                    'animalType': item['animalType'],
                  },
                )
                .then((_) {
                  // Otomatis refresh list jika kembali dari halaman detail
                  _loadItems();
                });
          },
          // Opsi edit & delete dipindahkan sepenuhnya ke long press / bottom sheet
          onLongPress: () => _showOptionsBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Utama (Bisa Diedit)
                      Text(
                        item['title'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nama Template (Read Only)
                      Text(
                        item['templateName'] ?? 'Template Standar',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Waktu simpan
                      Text(
                        (() {
                          final s =
                              item['savedAt'] ??
                              item['createdAt'] ??
                              item['created_at'];
                          if (s == null) return '-';
                          try {
                            return DateTime.parse(
                              s.toString(),
                            ).toLocal().toString().split('.').first;
                          } catch (_) {
                            return s.toString();
                          }
                        })(),
                        style: TextStyle(
                          color: AppColors.textSubdued,
                          fontSize: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
