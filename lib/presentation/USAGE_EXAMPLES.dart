// CONTOH PENGGUNAAN API DI HALAMAN LAIN
// Copy-paste code ini sesuai kebutuhan Anda

import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/data/models/auth_models.dart';

// ============ EXAMPLE HOME PAGE ============

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserData?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    // Fetch user profile saat page load
    _userProfileFuture = authRepository.getProfile();
  }

  Future<void> _logout() async {
    try {
      await authRepository.logout();

      if (!mounted) return;

      // Navigate ke login
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logout gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Center(
        child: FutureBuilder<UserData?>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final user = snapshot.data;

            if (user == null) {
              return const Text('User tidak ditemukan');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${user.name}!'),
                const SizedBox(height: 16),
                Text('Email: ${user.email}'),
                const SizedBox(height: 16),
                if (user.role != null) ...[
                  Text('Role: ${user.role}'),
                  const SizedBox(height: 16),
                ],
                Text('ID: ${user.id}'),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============ EXAMPLE PROFILE PAGE ============

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await authRepository.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      _user!.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _user!.email,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('ID', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      _user!.id,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_user!.role != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Role',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        _user!.role!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ HOW TO RESTORE TOKEN ON APP START ============

// Di Splash Page atau Main App:

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Get saved token
      final token = await authRepository.getAccessToken();

      if (!mounted) return;

      if (token != null) {
        // Set token to API client
        apiClient.setAuthToken(token);

        // Try to get profile to verify token is still valid
        try {
          await authRepository.getProfile();
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          // Token expired, redirect to login
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } else {
        // No token, redirect to login
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } catch (e) {
      // Error checking login status, go to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ============ API CALL FLOW ============
/*
LOGIN FLOW:
1. User enter email & password
2. Call authRepository.login(email, password)
3. AuthRepository calls AuthDataSource.login()
4. AuthDataSource call POST /auth/login
5. API returns { "accessToken": "..." }
6. AccessToken disimpan ke secure storage
7. Token di-set ke ApiClient header: "Authorization: Bearer token"
8. AuthDataSource call GET /auth/profile (dengan token di header)
9. API returns { "id": "...", "name": "...", "email": "...", "role": "..." }
10. UserData di-return ke auth page
11. User data ditampilkan di success snackbar

SUBSEQUENT API CALLS:
1. Semua request otomatis inject token di header
2. Jika API return 401 (unauthorized), token sudah expired
3. Harus call authRepository.logout() dan redirect ke login

LOGOUT FLOW:
1. User click logout button
2. Call authRepository.logout()
3. AuthRepository calls AuthDataSource.logout() -> POST /auth/logout
4. Token dihapus dari secure storage
5. Token dihapus dari ApiClient
6. Redirect ke login page

TOKEN RESTORATION ON APP START:
1. App start, splash screen show
2. Get saved token dari secure storage
3. If token exists, set ke ApiClient header
4. Try call getProfile() to verify token is still valid
5. If valid, go to home page
6. If invalid/expired, go to login page
*/
