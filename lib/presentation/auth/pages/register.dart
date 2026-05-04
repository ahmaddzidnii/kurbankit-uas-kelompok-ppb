import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _errorMessage = null;
      _fieldErrors = {};
    });

    // Validation
    Map<String, String> errors = {};

    if (_namaController.text.isEmpty) {
      errors['nama'] = 'Nama lengkap harus diisi';
    }

    if (_emailController.text.isEmpty) {
      errors['email'] = 'Email harus diisi';
    } else if (!_emailController.text.contains('@')) {
      errors['email'] = 'Email tidak valid';
    }

    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Buat password';
    } else if (_passwordController.text.length < 6) {
      errors['password'] = 'Password minimal 6 karakter';
    }

    if (_confirmPasswordController.text.isEmpty) {
      errors['confirmPassword'] = 'Konfirmasi password harus diisi';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      errors['confirmPassword'] = 'Password tidak cocok';
    }

    if (errors.isNotEmpty) {
      setState(() => _fieldErrors = errors);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authRepository.register(
        _namaController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );

      Navigator.pop(context);
    } on ValidationException catch (e) {
      if (e.errors != null) {
        setState(() => _fieldErrors = e.errors!.cast<String, String>());
      } else {
        setState(() => _errorMessage = e.message);
      }
    } on ServerException catch (e) {
      setState(() => _errorMessage = e.message);
    } on NetworkException {
      setState(() => _errorMessage = 'Gagal terhubung ke server');
    } catch (e) {
      setState(() => _errorMessage = 'Registrasi gagal. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBase),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 40.0,
              vertical: 32.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/qurbankit-logo-onboarding.png',
                      width: 140,
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 48),

                    // Error Message Badge
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: const Color(0xFFEF5350)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_rounded,
                              color: Color(0xFFEF5350),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gagal Mendaftar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: AppTypography.bold,
                                      color: Color(0xFFEF5350),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFEF5350),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Title
                    Text(
                      'Buat Akun Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBase,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Daftar untuk melanjutkan aktivitas Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSubdued,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const SizedBox(height: 40),

                    // Form Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Nama Lengkap Field
                          _buildTextField(
                            controller: _namaController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap Anda',
                            icon: Icons.person_outlined,
                            enabled: !_isLoading,
                            error: _fieldErrors['nama'],
                          ),

                          const SizedBox(height: 18),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'nama@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            error: _fieldErrors['email'],
                          ),

                          const SizedBox(height: 18),

                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outlined,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            error: _fieldErrors['password'],
                            onToggleObscure: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          // Confirm Password Field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Konfirmasi Password',
                            hint: '••••••••',
                            icon: Icons.lock_outlined,
                            obscureText: _obscureConfirmPassword,
                            enabled: !_isLoading,
                            error: _fieldErrors['confirmPassword'],
                            onToggleObscure: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.essentialBrightAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors
                              .essentialBrightAccent
                              .withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBase,
                            letterSpacing: 0.1,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            'Masuk di sini',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.essentialBrightAccent,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    String? error,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textBase,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textSubdued.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textSubdued,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            prefixIcon: Icon(icon),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.essentialBrightAccent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: Color(0xFFEF5350),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF5350),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
