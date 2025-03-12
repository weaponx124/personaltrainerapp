import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _programsKey = 'programs';
  static const String _programLogKeyPrefix = 'programLog_';
  static const String _workoutsKey = 'workouts';
  static const String _suggestedExercisesKey = 'suggestedExercises';
  static const String _mealsKey = 'meals';
  static const String _progressKey = 'progress';
  static const String _weightUnitKey = 'weightUnit';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Initialize the database (if needed)
  Future<void> initialize() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_programsKey)) {
      await _initializeDefaultData();
    }
  }

  Future<void> _initializeDefaultData() async {
    final defaultPrograms = [
      {'name': 'Russian Squat Program', 'id': Uuid().v4(), 'completed': false, 'startDate': '', 'details': {}},
      {'name': '5/3/1 Program', 'id': Uuid().v4(), 'completed': false, 'startDate': '', 'details': {}},
      {'name': 'Super Squats', 'id': Uuid().v4(), 'completed': false, 'startDate': '', 'details': {}},
      {'name': 'Texas Method', 'id': Uuid().v4(), 'completed': false, 'startDate': '', 'details': {}},
      {'name': '30-Day Squat Challenge', 'id': Uuid().v4(), 'completed': false, 'startDate': '', 'details': {}},
    ];
    print('Initialized default programs: $defaultPrograms');
    await savePrograms(defaultPrograms);
  }

  // Programs
  Future<List<Map<String, dynamic>>> getPrograms() async {
    final prefs = await _prefs;
    final programsJson = prefs.getString(_programsKey);
    return programsJson != null ? jsonDecode(programsJson).cast<Map<String, dynamic>>() : [];
  }

  Future<void> savePrograms(List<Map<String, dynamic>> programs) async {
    final prefs = await _prefs;
    await prefs.setString(_programsKey, jsonEncode(programs));
    print('Attempted to save programs to SharedPreferences: Success: true');
  }

  Future<Map<String, dynamic>> getProgram(String programName) async {
    final programs = await getPrograms();
    return programs.firstWhere((program) => program['name'] == programName, orElse: () => {});
  }

  Future<void> saveProgram(String programName, Map<String, dynamic> details) async {
    final programs = await getPrograms();
    final programIndex = programs.indexWhere((program) => program['name'] == programName);
    final programId = Uuid().v4();
    final startDate = DateTime.now().toIso8601String().split('T')[0]; // e.g., "2025-03-11"
    final newProgram = {
      'name': programName,
      'id': programId,
      'details': details,
      'completed': false,
      'startDate': startDate,
    };
    if (programIndex >= 0) {
      programs[programIndex] = newProgram;
    } else {
      programs.add(newProgram);
    }
    await savePrograms(programs);
  }

  // Program Log
  Future<List<Map<String, dynamic>>> getProgramLog(String programName) async {
    final prefs = await _prefs;
    final logJson = prefs.getString(_programLogKeyPrefix + programName);
    return logJson != null ? jsonDecode(logJson).cast<Map<String, dynamic>>() : [];
  }

  Future<void> saveProgramLog(String programName, List<Map<String, dynamic>> log) async {
    final prefs = await _prefs;
    await prefs.setString(_programLogKeyPrefix + programName, jsonEncode(log));
    print('Saved program log for $programName: $log');
  }

  // Workouts
  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final prefs = await _prefs;
    final workoutsJson = prefs.getString(_workoutsKey);
    return workoutsJson != null ? jsonDecode(workoutsJson).cast<Map<String, dynamic>>() : [];
  }

  Future<List<String>> getSuggestedExercises() async {
    final prefs = await _prefs;
    final exercisesJson = prefs.getString(_suggestedExercisesKey);
    return exercisesJson != null ? jsonDecode(exercisesJson).cast<String>() : [];
  }

  Future<void> insertWorkout(Map<String, dynamic> workout) async {
    final prefs = await _prefs;
    final workouts = await getWorkouts();
    workouts.add(workout);
    await prefs.setString(_workoutsKey, jsonEncode(workouts));
  }

  Future<void> deleteWorkout(String workoutId) async {
    final prefs = await _prefs;
    final workouts = await getWorkouts();
    final updatedWorkouts = workouts.where((w) => w['id'] != workoutId).toList();
    await prefs.setString(_workoutsKey, jsonEncode(updatedWorkouts));
  }

  // Meals
  Future<List<Map<String, dynamic>>> getMeals() async {
    final prefs = await _prefs;
    final mealsJson = prefs.getString(_mealsKey);
    return mealsJson != null ? jsonDecode(mealsJson).cast<Map<String, dynamic>>() : [];
  }

  Future<void> insertMeal(Map<String, dynamic> meal) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    meals.add(meal);
    await prefs.setString(_mealsKey, jsonEncode(meals));
  }

  Future<void> deleteMeal(String mealId) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    final updatedMeals = meals.where((m) => m['id'] != mealId).toList();
    await prefs.setString(_mealsKey, jsonEncode(updatedMeals));
  }

  // Progress
  Future<List<Map<String, dynamic>>> getProgress() async {
    final prefs = await _prefs;
    final progressJson = prefs.getString(_progressKey);
    return progressJson != null ? jsonDecode(progressJson).cast<Map<String, dynamic>>() : [];
  }

  Future<void> insertProgress(Map<String, dynamic> progress) async {
    final prefs = await _prefs;
    final progressList = await getProgress();
    progressList.add(progress);
    await prefs.setString(_progressKey, jsonEncode(progressList));
  }

  Future<void> deleteProgress(String progressId) async {
    final prefs = await _prefs;
    final progressList = await getProgress();
    final updatedProgress = progressList.where((p) => p['id'] != progressId).toList();
    await prefs.setString(_progressKey, jsonEncode(updatedProgress));
  }

  // Weight Unit
  Future<String> getWeightUnit() async {
    final prefs = await _prefs;
    return prefs.getString(_weightUnitKey) ?? 'kg';
  }

  Future<void> setWeightUnit(String unit) async {
    final prefs = await _prefs;
    await prefs.setString(_weightUnitKey, unit);
    print('Set weight unit to: $unit');
  }
}