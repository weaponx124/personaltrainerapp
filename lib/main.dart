import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/programs_overview_screen.dart';
import 'screens/program_details_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/progress_screen.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initialize(); // Initialize database with default data
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Trainer App',
      theme: const ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/programs': (context) => ProgramsOverviewScreen(),
        '/program_details': (context) => ProgramDetailsScreen(
          programName: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/body_weight': (context) => const Scaffold(body: Center(child: Text('Body Weight Progress'))),
        '/workout': (context) => const WorkoutScreen(),
        '/diet': (context) => const DietScreen(),
        '/progress': (context) => const ProgressScreen(),
      },
    );
  }
}