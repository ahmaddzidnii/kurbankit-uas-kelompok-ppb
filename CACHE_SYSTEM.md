## Cache System Documentation

### Overview

Sistem caching telah diimplementasikan untuk prevent multiple fetch calls saat navigasi di dashboard. Sistem ini mendukung:

- Caching dengan TTL (Time To Live)
- Cache invalidation
- Pattern-based invalidation
- Automatic expiry handling
- Singleton pattern (tidak ada state yang nyangkut)

### Cara Menggunakan

#### 1. Basic Usage di Halaman

```dart
final _cacheService = CacheService();
static const _cacheKey = 'periods_list';

Future<List<PeriodModel>> _loadPeriods({bool forceRefresh = false}) {
  if (forceRefresh) {
    _cacheService.invalidate(_cacheKey);
  }

  return _cacheService.get<List<PeriodModel>>(
    key: _cacheKey,
    compute: () => periodDataSource.getPeriods(),
    ttl: const Duration(minutes: 5), // Cache selama 5 menit
  );
}
```

#### 2. Force Refresh (Pull to Refresh)

```dart
Future<void> _reloadPeriods() async {
  setState(() {
    _periodsFuture = _loadPeriods(forceRefresh: true);
  });
  await _periodsFuture;
}
```

#### 3. Invalidate Cache dari Luar

```dart
// Invalidate saat membuat/edit data baru
await periodDataSource.createPeriod(...);
PeriodsPage.invalidateCache(); // Invalidate cache
```

#### 4. Invalidate by Pattern

```dart
// Invalidate semua cache yang dimulai dengan 'periods_'
_cacheService.invalidatePattern('periods_');
```

#### 5. Clear Semua Cache

```dart
// Saat logout
_cacheService.clear();
```

### API Reference

#### `get<T>()`

- **Deskripsi**: Get cached value atau compute baru jika belum ada/expired
- **Parameters**:
  - `key`: String identifier untuk cache entry
  - `compute`: Future function untuk compute value jika cache tidak ada
  - `ttl`: Duration untuk cache validity (default 5 menit)
- **Returns**: `Future<T>`

#### `set<T>()`

- **Deskripsi**: Set cache value secara manual
- **Parameters**:
  - `key`: String identifier
  - `value`: Value untuk di-cache
  - `ttl`: Duration untuk cache validity

#### `invalidate()`

- **Deskripsi**: Invalidate cache dengan key tertentu
- **Parameters**:
  - `key`: String identifier

#### `invalidatePattern()`

- **Deskripsi**: Invalidate cache dengan pattern prefix
- **Parameters**:
  - `pattern`: String prefix

#### `clear()`

- **Deskripsi**: Clear semua cache entries

#### `has()`

- **Deskripsi**: Check apakah cache ada dan valid (tidak expired)
- **Returns**: `bool`

### Best Practices

1. **Define Cache Keys sebagai Constants**

   ```dart
   static const _cacheKey = 'periods_list';
   static const _cacheKey = 'user_profile';
   ```

2. **Use Appropriate TTL**
   - Real-time data: 30 seconds - 2 minutes
   - Semi-dynamic data: 5 - 10 minutes
   - Static data: 30 minutes+

3. **Invalidate After Mutations**

   ```dart
   await periodDataSource.createPeriod(...);
   _cacheService.invalidate('periods_list');
   ```

4. **No State Leaks**
   - CacheService adalah singleton, jadi tidak ada state yang nyangkut
   - Automatic cleanup saat cache expired
   - Manual cleanup saat logout

5. **Error Handling**
   - Error otomatis remove cache entry agar retry selalu fresh
   - Tidak ada error state yang nyangkut

### Debugging

```dart
// Check cache size
print('Cache size: ${_cacheService.cacheSize}');

// Check all cache keys
print('Cache keys: ${_cacheService.cacheKeys}');

// Check apakah cache valid
if (_cacheService.has('periods_list')) {
  print('Cache valid');
}
```

### Technical Details

- **Singleton Pattern**: CacheService adalah singleton (factory constructor)
- **Thread-Safe**: Menggunakan Map untuk storage
- **Automatic Expiry**: Expired cache otomatis dihapus saat diakses
- **Memory Efficient**: Cache dihapus saat:
  - Manual invalidation
  - TTL expired
  - Error during computation
  - Explicit clear()
