import 'package:flutter/material.dart';

// ===========================================================================
// TOKEN TYPOGRAPHY
// Mendefinisikan ukuran font standar berdasarkan Material Design 3
// ===========================================================================
class AppTypography {
  // ---------------------------------------------------------------------------
  // DISPLAY - Untuk heading besar di halaman utama/landing
  // ---------------------------------------------------------------------------

  /// Display Large (32px) - Hero text, judul halaman utama
  static const double displayLarge = 32.0;

  /// Display Medium (28px) - Sub-hero text
  static const double displayMedium = 28.0;

  /// Display Small (24px) - Heading section penting
  static const double displaySmall = 24.0;

  // ---------------------------------------------------------------------------
  // HEADING - Untuk judul section/komponen
  // ---------------------------------------------------------------------------

  /// Heading Large (20px) - Judul card/modal besar
  static const double headingLarge = 20.0;

  /// Heading Medium (18px) - Judul card/section standar
  static const double headingMedium = 18.0;

  /// Heading Small (16px) - Judul subsection/list item
  static const double headingSmall = 16.0;

  // ---------------------------------------------------------------------------
  // BODY - Untuk konten teks/paragraf
  // ---------------------------------------------------------------------------

  /// Body Large (16px) - Paragraf utama, teks penting
  static const double bodyLarge = 16.0;

  /// Body Medium (14px) - Teks standar aplikasi (DEFAULT)
  static const double bodyMedium = 14.0;

  /// Body Small (12px) - Caption, deskripsi sekunder
  static const double bodySmall = 12.0;

  // ---------------------------------------------------------------------------
  // LABEL - Untuk label form, tombol, dan UI text
  // ---------------------------------------------------------------------------

  /// Label Large (14px) - Label form, text button
  static const double labelLarge = 14.0;

  /// Label Medium (12px) - Label kecil, chip text
  static const double labelMedium = 12.0;

  /// Label Small (10px) - Badge, timestamp, metadata
  static const double labelSmall = 10.0;

  // ---------------------------------------------------------------------------
  // FONT WEIGHTS - Untuk konsistensi bobot font
  // ---------------------------------------------------------------------------

  /// Thin (100) - Sangat jarang dipakai
  static const FontWeight thin = FontWeight.w100;

  /// ExtraLight (200) - Jarang dipakai
  static const FontWeight extraLight = FontWeight.w200;

  /// Light (300) - Untuk teks yang perlu terlihat ringan
  static const FontWeight light = FontWeight.w300;

  /// Regular (400) - Default weight untuk body text
  static const FontWeight regular = FontWeight.w400;

  /// Medium (500) - Untuk emphasis ringan (label, subtitle)
  static const FontWeight medium = FontWeight.w500;

  /// SemiBold (600) - Untuk heading dan emphasis sedang
  static const FontWeight semiBold = FontWeight.w600;

  /// Bold (700) - Untuk heading penting dan CTA
  static const FontWeight bold = FontWeight.w700;

  /// ExtraBold (800) - Untuk emphasis sangat kuat
  static const FontWeight extraBold = FontWeight.w800;

  /// Black (900) - Untuk impact maksimal (hero text)
  static const FontWeight black = FontWeight.w900;
}
