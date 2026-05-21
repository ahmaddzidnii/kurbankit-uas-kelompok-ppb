import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

class AdminMosqueStatusInfo {
  final String raw;
  final String normalized;
  final String label;
  final Color color;

  const AdminMosqueStatusInfo({
    required this.raw,
    required this.normalized,
    required this.label,
    required this.color,
  });

  bool get isPending => normalized == 'PENDING';

  bool get isActive =>
      normalized == 'ACTIVE' ||
      normalized == 'AKTIF' ||
      normalized == 'APPROVED';

  bool get isBlocked =>
      normalized == 'BLOCKED' ||
      normalized == 'BLOKIR' ||
      normalized == 'TAKEDOWN';
}

AdminMosqueStatusInfo mapAdminMosqueStatus(String status) {
  final raw = status.trim();
  final normalized = raw.toUpperCase();

  switch (normalized) {
    case 'PENDING':
      return const AdminMosqueStatusInfo(
        raw: 'PENDING',
        normalized: 'PENDING',
        label: 'Menunggu Persetujuan',
        color: Colors.orange,
      );
    case 'APPROVED':
      return const AdminMosqueStatusInfo(
        raw: 'APPROVED',
        normalized: 'APPROVED',
        label: 'Disetujui',
        color: Colors.green,
      );
    case 'ACTIVE':
    case 'AKTIF':
      return const AdminMosqueStatusInfo(
        raw: 'ACTIVE',
        normalized: 'ACTIVE',
        label: 'Aktif',
        color: Colors.green,
      );
    case 'REJECTED':
      return const AdminMosqueStatusInfo(
        raw: 'REJECTED',
        normalized: 'REJECTED',
        label: 'Ditolak',
        color: Colors.red,
      );
    case 'SUSPENDED':
      return const AdminMosqueStatusInfo(
        raw: 'SUSPENDED',
        normalized: 'SUSPENDED',
        label: 'Ditangguhkan',
        color: Colors.red,
      );
    case 'BLOCKED':
    case 'BLOKIR':
    case 'TAKEDOWN':
      return const AdminMosqueStatusInfo(
        raw: 'BLOCKED',
        normalized: 'BLOCKED',
        label: 'Diblokir',
        color: Colors.red,
      );
    default:
      final fallback = normalized.isEmpty ? 'UNKNOWN' : normalized;
      return AdminMosqueStatusInfo(
        raw: raw.isEmpty ? fallback : raw,
        normalized: fallback,
        label: fallback,
        color: AppColors.textSubdued,
      );
  }
}
