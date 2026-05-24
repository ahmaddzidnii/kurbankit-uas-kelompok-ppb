import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

class RecipientsPage extends StatefulWidget {
  const RecipientsPage({super.key});

  @override
  State<RecipientsPage> createState() => _RecipientsPageState();
}

class _RecipientsPageState extends State<RecipientsPage> {
  late TextEditingController _searchController;
  String _filterStatus = 'all'; // all, verified, pending

  // Sample data - will be replaced with API calls
  final List<Map<String, dynamic>> _recipients = [
    {
      'name': 'Fatimah Zahra',
      'category': 'Mustahiq',
      'phone': '082123456789',
      'address': 'Jl. Kenanga No. 12, RT 01/RW 03',
      'status': 'verified',
      'photoUrl': null,
    },
    {
      'name': 'Ahmad Suherma',
      'category': 'Mustahiq',
      'phone': '081234567890',
      'address': 'Jl. Merdeka No. 5, RT 02/RW 02',
      'status': 'verified',
      'photoUrl': null,
    },
    {
      'name': 'Siti Nurhaliza',
      'category': 'Mustahiq',
      'phone': '083456789012',
      'address': 'Jl. Ahmad Yani No. 23, RT 03/RW 01',
      'status': 'pending',
      'photoUrl': null,
    },
    {
      'name': 'Muhammad Ali',
      'category': 'Aidil Fitri',
      'phone': '084567890123',
      'address': 'Jl. Diponegoro No. 8, RT 01/RW 04',
      'status': 'verified',
      'photoUrl': null,
    },
    {
      'name': 'Aminah Putri',
      'category': 'Mustahiq',
      'phone': '085678901234',
      'address': 'Jl. Sukarno No. 15, RT 02/RW 03',
      'status': 'pending',
      'photoUrl': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRecipients {
    return _recipients.where((recipient) {
      final matchesSearch = recipient['name'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final matchesStatus =
          _filterStatus == 'all' || recipient['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.lg),

                  // Filter tabs
                  _buildFilterTabs(),
                ],
              ),
            ),
            Expanded(
              child: _filteredRecipients.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: _filteredRecipients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildRecipientCard(
                            _filteredRecipients[index],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.essentialBrightAccent,
        onPressed: () {
          context.push('/mosque-recipient-form');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundBase,
      elevation: 0,
      title: const Text(
        'Mustahiq',
        style: TextStyle(
          fontSize: AppTypography.headingLarge,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari penerima...',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.essentialBrightAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'label': 'Semua', 'value': 'all', 'count': _recipients.length},
      {
        'label': 'Verified',
        'value': 'verified',
        'count': _recipients.where((r) => r['status'] == 'verified').length,
      },
      {
        'label': 'Pending',
        'value': 'pending',
        'count': _recipients.where((r) => r['status'] == 'pending').length,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...tabs.map((tab) {
            final tabValue = (tab['value'] as String?) ?? 'all';
            final isSelected = _filterStatus == tabValue;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: () {
                  setState(() => _filterStatus = tabValue);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.essentialBrightAccent
                        : AppColors.backgroundElevatedBase,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.essentialBrightAccent
                          : AppColors.decorativeSubdued,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${tab['label']} (${tab['count']})',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.medium,
                      color: isSelected ? Colors.white : AppColors.textBase,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecipientCard(Map<String, dynamic> recipient) {
    final isVerified = recipient['status'] == 'verified';

    return GestureDetector(
      onTap: () {
        _showRecipientDetail(recipient);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          border: Border.all(color: AppColors.decorativeSubdued, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(
                  recipient['name'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.essentialBrightAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipient['name'],
                          style: const TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.bold,
                            color: AppColors.textBase,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.essentialPositive.withValues(
                                  alpha: 0.1,
                                )
                              : const Color(0xFFFFA42B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          isVerified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.semiBold,
                            color: isVerified
                                ? AppColors.essentialPositive
                                : const Color(0xFFFFA42B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _buildMetaItem(
                        icon: Icons.category_rounded,
                        text: recipient['category'],
                      ),
                      _buildMetaItem(
                        icon: Icons.phone_rounded,
                        text: recipient['phone'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSubdued,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSubdued),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            color: AppColors.textSubdued,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 60,
            color: AppColors.decorativeSubdued,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada penerima',
            style: TextStyle(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mulai dengan menambahkan penerima baru',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipientDetail(Map<String, dynamic> recipient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Penerima',
                    style: TextStyle(
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.close_rounded, color: AppColors.textBase),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDetailRow('Nama', recipient['name']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('Kategori', recipient['category']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('No. Telepon', recipient['phone']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('Alamat', recipient['address']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(
                'Status',
                recipient['status'] == 'verified' ? 'Terverifikasi' : 'Pending',
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundHighlight,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          fontWeight: AppTypography.bold,
                          color: AppColors.textBase,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.essentialBrightAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit - Coming Soon')),
                        );
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.bold,
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
