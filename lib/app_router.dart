import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/mosque_detail_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_detail_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_list_page.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/auth/presentation/screens/auth.dart';
import 'package:qurban_kit/features/auth/presentation/screens/register.dart';
import 'package:qurban_kit/features/home/presentation/screens/home.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_input_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_result_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_template_selection_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/mosque_dashboard/screens/dashboard/admin_home_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_account_suspended_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_admin_dashboard.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_registration_rejected_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_waiting_dashboard.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/periods/periods_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/profile/mosque_profile_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/recipients/recipient_form_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/recipients/recipients_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/settings/mosque_settings_page.dart';
import 'package:qurban_kit/features/mosque_registration/presentation/mosque_registration/screens/mosque_registration_page.dart';
import 'package:qurban_kit/features/onboarding/presentation/onboarding/screens/onboarding.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';
import 'package:qurban_kit/features/splash/presentation/screens/splash.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final initialUser = state.extra is UserData
              ? state.extra as UserData
              : null;
          return HomePage(initialUser: initialUser);
        },
      ),
      GoRoute(
        path: '/mosque-registration',
        builder: (context, state) => const MosqueRegistrationPage(),
      ),
      GoRoute(
        path: '/mosque-dashboard-waiting',
        builder: (context, state) => const MosqueWaitingDashboard(),
      ),
      GoRoute(
        path: '/mosque-registration-rejected',
        builder: (context, state) {
          final mosque = state.extra is ProfileMasjid
              ? state.extra as ProfileMasjid
              : null;
          return MosqueRegistrationRejectedPage(mosque: mosque);
        },
      ),
      GoRoute(
        path: '/mosque-account-suspended',
        builder: (context, state) => const MosqueAccountSuspendedPage(),
      ),
      GoRoute(
        path: '/mosque-admin-dashboard',
        builder: (context, state) {
          final initialUser = state.extra is UserData
              ? state.extra as UserData
              : null;
          return MosqueAdminDashboard(initialUser: initialUser);
        },
      ),
      GoRoute(
        path: '/admin-home',
        builder: (context, state) {
          final user = state.extra is UserData ? state.extra as UserData : null;
          return AdminHomePage(user: user);
        },
      ),
      GoRoute(
        path: '/periods',
        builder: (context, state) => const PeriodsPage(),
      ),
      GoRoute(
        path: '/recipients',
        builder: (context, state) => const RecipientsPage(),
      ),
      GoRoute(
        path: '/mosque-recipient-form',
        builder: (context, state) => const RecipientFormPage(),
      ),
      GoRoute(
        path: '/mosque-settings',
        builder: (context, state) {
          final user = state.extra is UserData ? state.extra as UserData : null;
          return MosqueSettingsPage(user: user);
        },
      ),
      GoRoute(
        path: '/mosque-profile',
        builder: (context, state) {
          final user = state.extra is UserData ? state.extra as UserData : null;
          return MosqueProfilePage(user: user);
        },
      ),
      GoRoute(
        path: '/calculator-template-selection',
        builder: (context, state) => const CalculatorTemplateSelectionPage(),
      ),
      GoRoute(
        path: '/calculator-input/:templateId',
        builder: (context, state) {
          final templateId = state.pathParameters['templateId'];
          if (templateId == null || templateId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Template tidak ditemukan')),
            );
          }

          return CalculatorInputPage(templateId: templateId);
        },
      ),
      GoRoute(
        path: '/calculator-result',
        builder: (context, state) {
          final result = state.extra as CalculatorResult?;
          if (result == null) {
            return const Scaffold(
              body: Center(child: Text('Hasil tidak ditemukan')),
            );
          }

          return CalculatorResultPage(result: result);
        },
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const VerificationListPage(),
      ),
      GoRoute(
        path: '/admin-detail',
        builder: (context, state) {
          final request = state.extra as AdminMosqueRecord?;
          return VerificationDetailPage(request: request);
        },
      ),
      GoRoute(
        path: '/admin-mosque-detail',
        builder: (context, state) {
          final mosque = state.extra as AdminMosqueRecord?;
          return MosqueDetailPage(mosque: mosque);
        },
      ),
    ],
  );
}
