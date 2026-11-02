import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/local/hive_service.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'features/goals/goal_provider.dart';
import 'features/profile/profile_provider.dart';
import 'features/steps/steps_provider.dart';
import 'features/water/water_provider.dart';
import 'features/weight/weight_provider.dart';
import 'features/workouts/workout_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(ProfileRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(WorkoutRepository()),
        ),
        ChangeNotifierProvider(create: (_) => StepsProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: const FitTrackApp(),
    ),
  );
}