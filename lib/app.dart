import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/floating_nav_bar.dart';
import 'core/widgets/gradient_background.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_provider.dart';
import 'features/profile/profile_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/steps/steps_provider.dart';
import 'features/workouts/workout_history_screen.dart';

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Consumer<ProfileProvider>(
        builder: (context, profile, _) =>
        profile.hasProfile ? const AppShell() : const OnboardingScreen(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final PageController _pageController = PageController();
  int _index = 0;

  // While a nav-bar tap is animating across several pages, ignore the
  // intermediate page-change events so the nav dot doesn't flicker.
  bool _tapNavigating = false;
  int _navToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StepsProvider>().startTracking();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goTo(int i) async {
    if (i == _index) return;
    setState(() => _index = i);
    final token = ++_navToken;
    _tapNavigating = true;
    await _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (token == _navToken) _tapNavigating = false;
  }

  void _onPageChanged(int i) {
    if (_tapNavigating) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // viewPadding is not consumed by the Scaffold, so this is the real
    // system gesture/navigation bar height.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return GradientBackground(
      child: Scaffold(
        body: Stack(
          children: [
            // Pages run all the way to the bottom edge, so content
            // scrolls behind the floating bar.
            SafeArea(
              bottom: false,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _KeepAlive(
                    child: DashboardScreen(onOpenWorkouts: () => _goTo(1)),
                  ),
                  const _KeepAlive(child: WorkoutHistoryScreen()),
                  const _KeepAlive(child: StatsScreen()),
                  const _KeepAlive(child: ProfileScreen()),
                ],
              ),
            ),
            // Only the pill itself is drawn and tappable.
            Positioned(
              left: 24,
              right: 24,
              bottom: bottomInset + 16,
              child: FloatingNavBar(
                currentIndex: _index,
                onTap: _goTo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps a page's state alive when it is swiped off screen,
/// matching how IndexedStack behaved before.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}