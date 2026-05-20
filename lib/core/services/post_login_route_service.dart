import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class PostLoginRouteService {
  static Future<void> syncUserState(UserData user) async {
    if (user.role != null && user.role!.isNotEmpty) {
      await UserRoleService.setUserRole(user.role!);
    }

    await UserRoleService.setMosqueRegistered(user.masjid != null);
  }

  static String resolveRoute(UserData user) {
    final role = user.role?.toUpperCase();

    if (role == 'SUPER_ADMIN') {
      return '/admin-dashboard';
    }

    if (role == 'ADMIN_MASJID') {
      final mosque = user.masjid;

      if (mosque == null) {
        return '/mosque-registration';
      }

      if (mosque.isPending) {
        return '/mosque-dashboard-waiting';
      }

      if (mosque.isRejected) {
        return '/mosque-registration-rejected';
      }

      if (mosque.isSuspended) {
        return '/mosque-account-suspended';
      }

      if (mosque.isApproved) {
        return '/mosque-admin-dashboard';
      }

      return '/mosque-registration';
    }

    return '/home';
  }
}
