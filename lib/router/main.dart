import 'package:go_router/go_router.dart';
import '../ui/splash_screen.dart';
import '../ui/main_navigation_screen.dart';
import '../ui/day_detail_page.dart';
import '../model/school_class.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final cours = state.extra as SchoolClass?;
        return DayDetailPage(cours: cours);
      },
    ),
  ],
);