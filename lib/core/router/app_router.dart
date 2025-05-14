import 'dart:async';

import 'package:beatsync_app/core/router/app_routes.dart';
import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_state.dart';
import 'package:beatsync_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:beatsync_app/features/authentication/presentation/screens/registration_screen.dart';
import 'package:beatsync_app/features/authentication/presentation/screens/splash_screen.dart';
import 'package:beatsync_app/features/heart_rate/presentation/screens/heart_rate_screen.dart';
import 'package:beatsync_app/features/home/domain/usecases/get_latest_today_analysis_usecase.dart';
import 'package:beatsync_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:beatsync_app/features/home/presentation/screens/home_screen.dart';
import 'package:beatsync_app/features/main_scaffold_shell.dart';
import 'package:beatsync_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:beatsync_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:beatsync_app/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (AuthState authState) => notifyListeners(),
        );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: homeRoute,
  refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoute.splash.path,
      name: AppRoute.splash.name,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoute.register.path,
      name: AppRoute.register.name,
      builder: (BuildContext context, GoRouterState state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: AppRoute.heartRate.path,
      name: AppRoute.heartRate.name,
      builder: (BuildContext context, GoRouterState state) => const HeartRateScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>(
              create: (context) => HomeCubit(
                getLatestTodayAnalysisUseCase: sl<GetLatestTodayAnalysisUseCase>(),
                authRepository: sl<AuthRepository>(),
              )..loadHomeScreenData(),
            ),
          ],
          child: MainScaffoldShell(navigationShell: navigationShell),
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: homeRoute,
              name: 'home',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: heartRateMeasurementRoute,
              name: 'measure',
              builder: (BuildContext context, GoRouterState state) {
                return const HeartRateScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: statisticsRoute,
              name: 'statistics',
              builder: (BuildContext context, GoRouterState state) {
                return const StatisticsScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.name,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'settings',
                    name: AppRoute.settings.name,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SettingsScreen(),
                  ),
                ]),
          ],
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final AuthState authState = sl<AuthCubit>().state;
    final String currentLocation = state.matchedLocation;

    final bool isAuthenticating = authState is AuthLoading || authState is AuthInitial;
    final bool isAuthenticated = authState is Authenticated;

    final List<String> authFlowPaths = [
      AppRoute.login.path,
      AppRoute.register.path,
      AppRoute.splash.path,
    ];
    final bool onAuthScreenFlow = authFlowPaths.contains(currentLocation);

    if (isAuthenticating) {
      return currentLocation == AppRoute.splash.path ? null : AppRoute.splash.path;
    }

    if (isAuthenticated) {
      if (onAuthScreenFlow) {
        return homeRoute;
      }
    } else {
      if (currentLocation == AppRoute.splash.path) {
        return AppRoute.login.path;
      }
      if (!onAuthScreenFlow) {
        return AppRoute.login.path;
      }
    }
    return null;
  },
);
