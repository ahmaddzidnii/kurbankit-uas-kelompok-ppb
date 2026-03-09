import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/onboard-ilustration-1.png',
      title: 'Hitung Pembagian\nQurban dengan Mudah',
      description:
          'QurbanKit diharapkan dapat membantu panitia menghitung pembagian daging qurban secara otomatis, cepat, dan akurat.',
    ),
    OnboardingData(
      image: 'assets/images/onboard-ilustration-2.png',
      title: 'Gunakan Template\nPembagian',
      description:
          'Pilih metode pembagian sesuai syariat atau atur persentase pembagian secara kustom.',
    ),
    OnboardingData(
      image: 'assets/images/onboard-ilustration-3.png',
      title: 'Lihat Hasil Perhitungan\nBerat Setiap Paket',
      description:
          'Aplikasi menghitung berat daging untuk setiap paket secara otomatis.',
    ),
    OnboardingData(
      image: 'assets/images/onboard-ilustration-4.png',
      title: 'Simpan Hasil\nPerhitungan',
      description:
          'Simpan hasil perhitungan agar data pembagian mudah diakses kembali.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to home/main page
      // TODO: Implement navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo di kiri atas
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/qurbankit-logo-onboarding.png',
                  width: 148,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingContent(
                    data: _pages[index],
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                    onDotTap: (dotIndex) {
                      _pageController.animateToPage(
                        dotIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                },
              ),
            ),

            // Tombol
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.essentialBrightAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Mulai Menghitung'
                        : 'Lanjut',
                    style: const TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  final int currentPage;
  final int totalPages;
  final Function(int) onDotTap;

  const _OnboardingContent({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Ilustrasi dengan tinggi tetap
          SizedBox(
            height: 280,
            child: Center(
              child: Image.asset(
                data.image,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder jika gambar belum ada
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevatedBase,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.decorativeSubdued),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppColors.textSubdued,
                    ),
                  );
                },
              ),
            ),
          ),

          AppSpacing.vSpaceLg,

          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => _DotIndicator(
                isActive: index == currentPage,
                onTap: () => onDotTap(index),
              ),
            ),
          ),

          AppSpacing.vSpaceLg,

          // Judul dengan alokasi 2 baris
          SizedBox(
            height: 68, // Alokasi untuk 2 baris
            child: Center(
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                  height: 1.3,
                ),
              ),
            ),
          ),

          AppSpacing.vSpaceSm,

          // Deskripsi dengan alokasi 3 baris
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: SizedBox(
              height: 72, // Alokasi untuk 3 baris
              child: Center(
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: AppColors.textSubdued,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _DotIndicator({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Area tap lebih besar
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.essentialBrightAccent
                : AppColors.decorativeSubdued,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
