import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/features/mosque_registration/presentation/screens/mosque_registration_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_waiting_dashboard.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/mosque_admin_dashboard.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_template_selection_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_input_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/calculator/calculator_result_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/recipients/recipient_form_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/settings/mosque_settings_page.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/profile/mosque_profile_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_list_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/verification_detail_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/mosque_detail_page.dart';
import 'package:qurban_kit/features/admin_dashboard/presentation/screens/takedown_page.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'core/configs/theme/app_theme.dart';
import 'package:qurban_kit/features/splash/presentation/screens/splash.dart';
import 'package:qurban_kit/features/auth/presentation/screens/auth.dart';
import 'package:qurban_kit/features/home/presentation/screens/home.dart';

void main() {
  setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/auth':
            return MaterialPageRoute(
              builder: (context) => const AuthPage(),
              settings: settings,
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: settings,
            );
          case '/mosque-registration':
            return MaterialPageRoute(
              builder: (context) => const MosqueRegistrationPage(),
              settings: settings,
            );
          case '/mosque-dashboard-waiting':
            return MaterialPageRoute(
              builder: (context) => const MosqueWaitingDashboard(),
              settings: settings,
            );
          case '/mosque-admin-dashboard':
            return MaterialPageRoute(
              builder: (context) => const MosqueAdminDashboard(),
              settings: settings,
            );
          case '/calculator-template-selection':
            return MaterialPageRoute(
              builder: (context) => const CalculatorTemplateSelectionPage(),
              settings: settings,
            );
          case '/calculator-input':
            final templateId = settings.arguments as String?;
            if (templateId == null) return null;
            return MaterialPageRoute(
              builder: (context) => CalculatorInputPage(templateId: templateId),
              settings: settings,
            );
          case '/calculator-result':
            final result = settings.arguments as CalculatorResult?;
            if (result == null) return null;
            return MaterialPageRoute(
              builder: (context) => CalculatorResultPage(result: result),
              settings: settings,
            );
          case '/mosque-recipient-form':
            return MaterialPageRoute(
              builder: (context) => const RecipientFormPage(),
              settings: settings,
            );
          case '/mosque-settings':
            final user = settings.arguments as UserData?;
            return MaterialPageRoute(
              builder: (context) => MosqueSettingsPage(user: user),
              settings: settings,
            );
          case '/mosque-profile':
            final user = settings.arguments as UserData?;
            return MaterialPageRoute(
              builder: (context) => MosqueProfilePage(user: user),
              settings: settings,
            );
          case '/admin-dashboard':
            return MaterialPageRoute(
              builder: (context) => const VerificationListPage(),
              settings: settings,
            );
          case '/admin-detail':
            final request = settings.arguments as AdminMosqueRecord?;
            return MaterialPageRoute(
              builder: (context) => VerificationDetailPage(request: request),
              settings: settings,
            );
          case '/admin-mosque-detail':
            final mosque = settings.arguments as AdminMosqueRecord?;
            return MaterialPageRoute(
              builder: (context) => MosqueDetailPage(mosque: mosque),
              settings: settings,
            );
          case '/admin-takedown':
            return MaterialPageRoute(
              builder: (context) => const TakedownPage(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}
