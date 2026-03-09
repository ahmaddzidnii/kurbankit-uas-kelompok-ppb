import 'package:flutter/material.dart';

/// Kelas yang menyimpan seluruh token warna desain (Design Tokens).
/// Tema bawaan difokuskan pada Light Mode dengan struktur semantik.
class AppColors {
  // ===========================================================================
  // BACKGROUND MAIN
  // Digunakan untuk latar belakang utama lapisan dasar aplikasi.
  // ===========================================================================

  /// Latar belakang dasar halaman atau aplikasi.
  static const Color backgroundBase = Color(0xFFFAFAFA);

  /// Warna latar belakang saat elemen di-hover atau difokuskan (sedikit lebih gelap).
  static const Color backgroundHighlight = Color(0xFFF0F0F0);

  /// Warna latar belakang saat elemen ditekan/aktif (lebih gelap).
  static const Color backgroundPress = Color(0xFFE5E5E5);

  // ===========================================================================
  // BACKGROUND ELEVATED
  // Digunakan untuk komponen yang mengambang di atas background utama (Card, Dialog, Modal).
  // ===========================================================================

  /// Latar belakang dasar untuk elemen melayang (Cards, Bottom Sheets).
  static const Color backgroundElevatedBase = Color(0xFFFFFFFF);

  /// Latar belakang elemen melayang saat di-hover/difokuskan.
  static const Color backgroundElevatedHighlight = Color(0xFFF5F5F5);

  /// Latar belakang elemen melayang saat ditekan/aktif.
  static const Color backgroundElevatedPress = Color(0xFFEEEEEE);

  // ===========================================================================
  // BACKGROUND TINTED (TRANSPARAN)
  // Digunakan untuk efek overlay. Cocok diletakkan di atas gambar atau gradien.
  // ===========================================================================

  /// Latar belakang overlay dasar (Hitam dengan ~5% opacity).
  static const Color backgroundTintedBase = Color(0x0D000000);

  /// Latar belakang overlay saat di-hover (Hitam dengan ~8% opacity).
  static const Color backgroundTintedHighlight = Color(0x14000000);

  /// Latar belakang overlay saat ditekan (Hitam dengan ~12% opacity).
  static const Color backgroundTintedPress = Color(0x1F000000);

  // ===========================================================================
  // TEXT
  // Digunakan khusus untuk tipografi (huruf, angka, paragraf).
  // ===========================================================================

  /// Warna teks utama (Heading, Paragraf utama). Kontras paling tinggi.
  static const Color textBase = Color(0xFF1A1A1A);

  /// Warna teks sekunder (Subtitle, Caption, teks yang tidak terlalu penting).
  static const Color textSubdued = Color(0xFF666666);

  /// Warna teks untuk menyoroti identitas/brand aplikasi (Primary/Accent).
  static const Color textBrightAccent = Color(0xFF00796B);

  /// Warna teks untuk error, kegagalan, atau aksi destruktif (Hapus/Keluar).
  static const Color textNegative = Color(0xFFF3727F);

  /// Warna teks untuk peringatan (Warning/Caution).
  static const Color textWarning = Color(0xFFFFA42B);

  /// Warna teks untuk kesuksesan (Berhasil disimpan, dsb).
  static const Color textPositive = Color(0xFF00796B);

  /// Warna teks untuk informasi netral, pengumuman, atau tautan (Link).
  static const Color textAnnouncement = Color(0xFF4CB3FF);

  // ===========================================================================
  // ESSENTIAL
  // Digunakan untuk elemen antarmuka esensial non-teks (Ikon, Garis Batas/Border, Checkbox).
  // ===========================================================================

  /// Warna dasar untuk ikon utama atau outline aktif.
  static const Color essentialBase = Color(0xFF1A1A1A);

  /// Warna untuk ikon sekunder atau border yang tidak aktif (disable).
  static const Color essentialSubdued = Color(0xFFB3B3B3);

  /// Warna aksen utama untuk ikon atau kontrol UI aktif (Toggle On).
  static const Color essentialBrightAccent = Color(0xFF00796B);

  /// Warna untuk ikon error atau badge notifikasi peringatan.
  static const Color essentialNegative = Color(0xFFED2C3F);

  /// Warna untuk ikon peringatan (Warning).
  static const Color essentialWarning = Color(0xFFFFA42B);

  /// Warna untuk ikon sukses (Centang hijau).
  static const Color essentialPositive = Color(0xFF00796B);

  /// Warna untuk ikon informasi atau badge pengumuman.
  static const Color essentialAnnouncement = Color(0xFF4CB3FF);

  // ===========================================================================
  // DECORATIVE
  // Digunakan untuk elemen pendukung visual (Divider, Skeleton loading, Placeholder).
  // ===========================================================================

  /// Warna dekoratif utama yang cukup menonjol.
  static const Color decorativeBase = Color(0xFFD1D1D1);

  /// Warna dekoratif redup. Sangat cocok untuk Divider/Garis Pemisah atau background Skeleton.
  static const Color decorativeSubdued = Color(0xFFE8E8E8);
}
