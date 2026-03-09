import 'package:flutter/material.dart';

// ===========================================================================
// TOKEN SPACING & PADDING
// Menggunakan sistem kelipatan 4 dan 8 untuk proporsi UI yang konsisten.
// ===========================================================================
class AppSpacing {
  /// Spacing ekstra kecil (4px) - Biasanya untuk jarak ikon dengan teks di sebelahnya.
  static const double xs = 4.0;

  /// Spacing kecil (8px) - Jarak antar elemen yang saling berkaitan erat (misal: label ke input).
  static const double sm = 8.0;

  /// Spacing menengah/default (16px) - Standar padding layar HP atau jarak antar komponen utama.
  static const double md = 16.0;

  /// Spacing besar (24px) - Jarak antar seksi/bagian yang berbeda dalam satu halaman.
  static const double lg = 24.0;

  /// Spacing ekstra besar (32px) - Jarak pemisah yang sangat tegas.
  static const double xl = 32.0;

  /// Spacing paling besar (48px) - Biasanya untuk jarak ke tombol di paling bawah layar.
  static const double xxl = 48.0;

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS: VERTICAL SPACING (Untuk di dalam Column)
  // ---------------------------------------------------------------------------
  static const Widget vSpaceXs = SizedBox(height: xs);
  static const Widget vSpaceSm = SizedBox(height: sm);
  static const Widget vSpaceMd = SizedBox(height: md);
  static const Widget vSpaceLg = SizedBox(height: lg);
  static const Widget vSpaceXl = SizedBox(height: xl);
  static const Widget vSpaceXxl = SizedBox(height: xxl);

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS: HORIZONTAL SPACING (Untuk di dalam Row)
  // ---------------------------------------------------------------------------
  static const Widget hSpaceXs = SizedBox(width: xs);
  static const Widget hSpaceSm = SizedBox(width: sm);
  static const Widget hSpaceMd = SizedBox(width: md);
  static const Widget hSpaceLg = SizedBox(width: lg);
  static const Widget hSpaceXl = SizedBox(width: xl);
  static const Widget hSpaceXxl = SizedBox(width: xxl);
}
