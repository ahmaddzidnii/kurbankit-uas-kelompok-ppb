import 'package:flutter/foundation.dart';

/// Service untuk manage caching dengan invalidation support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  final Map<String, _CacheEntry> _cache = {};

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  /// Get cached value atau compute jika belum ada
  Future<T> get<T>({
    required String key,
    required Future<T> Function() compute,
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final cached = _cache[key];

    // Jika ada cache dan belum expired, gunakan
    if (cached != null && !cached.isExpired) {
      return cached.value as T;
    }

    // Hapus cache yang sudah expired
    if (cached != null && cached.isExpired) {
      _cache.remove(key);
    }

    // Compute value baru
    try {
      final value = await compute();
      _cache[key] = _CacheEntry(
        value: value,
        expiresAt: DateTime.now().add(ttl),
      );
      return value;
    } catch (e) {
      // Jika error, hapus cache yang lama agar retry selalu fresh
      _cache.remove(key);
      rethrow;
    }
  }

  /// Set cache value secara manual
  void set<T>({
    required String key,
    required T value,
    Duration ttl = const Duration(minutes: 5),
  }) {
    _cache[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }

  /// Invalidate cache dengan key tertentu
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidate cache dengan pattern (prefix)
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, _) => key.startsWith(pattern));
  }

  /// Clear semua cache
  void clear() {
    _cache.clear();
  }

  /// Check apakah cache ada dan valid
  bool has(String key) {
    final cached = _cache[key];
    if (cached == null) return false;
    if (cached.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Get cache size (untuk debugging)
  int get cacheSize => _cache.length;

  /// Get all cache keys (untuk debugging)
  List<String> get cacheKeys => _cache.keys.toList();

  /// Read cache value synchronously if exists and not expired, otherwise null
  T? read<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;
    if (cached.isExpired) {
      _cache.remove(key);
      return null;
    }
    return cached.value as T;
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
