import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/delta_s_screen.dart';
import 'screens/crisis_filter_screen.dart';
import 'screens/war_state_screen.dart';
import 'screens/evac_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/offline_maps_screen.dart';

// ── Shell with bottom navigation (5 tabs) ────────────────────────
// Alerts are accessed via the burger menu in the HeaderBar (not a tab)
// EVAC consolidates Shelters + Embassies + Airports
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Palantir.border, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Palantir.surface,
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(i),
          selectedItemColor: Palantir.accent,
          unselectedItemColor: Palantir.textMuted,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          iconSize: 20,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'BRIEF',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              label: 'TRUST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_outlined),
              label: 'EVAC',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.radar),
              label: 'CONFLICT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Router ────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          onComplete: () => GoRouter.of(context).go('/delta-s'),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/delta-s', builder: (_, _) => const DeltaSScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/crisis-filter', builder: (_, _) => const CrisisFilterScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/evac', builder: (_, _) => const EvacScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/war-state', builder: (_, _) => const WarStateScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const RoadmapScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (_, _) => const NotificationSettingsScreen(),
                ),
                GoRoute(
                  path: 'offline-maps',
                  builder: (_, _) => const OfflineMapsScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

// ── App Widget ────────────────────────────────────────────────────
class BreachApp extends ConsumerWidget {
  const BreachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BRE4CH',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
