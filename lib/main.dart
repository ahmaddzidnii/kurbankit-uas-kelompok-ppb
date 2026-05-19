import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/presentation/mosque_registration/pages/mosque_registration_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/mosque_waiting_dashboard.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/mosque_admin_dashboard.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/calculator/calculator_template_selection_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/calculator/calculator_input_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/calculator/calculator_result_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/recipients/recipient_form_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/settings/mosque_settings_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/profile/mosque_profile_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/verification_list_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/verification_detail_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/mosque_detail_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/takedown_page.dart';
import 'package:qurban_kit/data/models/admin_mosque_record.dart';
import 'package:qurban_kit/data/models/calculator_models.dart';
import 'package:qurban_kit/data/models/auth_models.dart';
import 'core/configs/theme/app_theme.dart';
import 'presentation/splash/pages/splash.dart';
import 'presentation/auth/pages/auth.dart';
import 'presentation/home/pages/home.dart';

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
