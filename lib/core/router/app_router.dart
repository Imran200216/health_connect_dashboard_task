import 'package:go_router/go_router.dart';
import 'package:health_connect_dashboard/core/constants/app_router_constants.dart';
import 'package:health_connect_dashboard/features/home/presentation/screens/home_screen.dart';
import 'package:health_connect_dashboard/features/permission/presentation/screens/health_permission_screen.dart';
import 'package:health_connect_dashboard/features/splash/presentation/screens/splash_screen.dart';

GoRouter appRouter = GoRouter(
  // initial Location
  initialLocation: '/${AppRouterConstants.splash}',

  routes: [
    // Splash Screen
    GoRoute(
      path: '/${AppRouterConstants.splash}',
      name: AppRouterConstants.splash,
      builder: (context, state) {
        return SplashScreen();
      },
    ),

    // Health Permission Screen
    GoRoute(
      path: '/${AppRouterConstants.healthPermission}',
      name: AppRouterConstants.healthPermission,
      builder: (context, state) {
        return HealthPermissionScreen();
      },
    ),

    // Health Permission Screen
    GoRoute(
      path: '/${AppRouterConstants.home}',
      name: AppRouterConstants.home,
      builder: (context, state) {
        return HomeScreen();
      },
    ),
  ],
);
