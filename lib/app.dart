import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/floating_nav_bar.dart';
import 'core/widgets/gradient_background.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_provider.dart';
import 'features/profile/profile_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/workouts/workout_history_screen.dart';
import 'features/steps/steps_provider.dart';

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
int _index = 0;

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
context.read<StepsProvider>().startTracking();
});
}
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              DashboardScreen(onOpenWorkouts: () => setState(() => _index = 1)),
              const WorkoutHistoryScreen(),
              const StatsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}