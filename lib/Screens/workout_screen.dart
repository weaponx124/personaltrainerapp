import 'package:flutter/material.dart';
import '../database_helper.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Map<String, dynamic>> workouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => isLoading = true);
    workouts = await DatabaseHelper().getWorkouts();
    setState(() => isLoading = false);
  }

  Future<void> _addWorkout() async {
    final newWorkout = {'id': DateTime.now().toString(), 'name': 'New Workout', 'exercises': []};
    await DatabaseHelper().insertWorkout(newWorkout);
    await _loadWorkouts();
  }

  Future<void> _deleteWorkout(String workoutId) async {
    await DatabaseHelper().deleteWorkout(workoutId);
    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workouts'), backgroundColor: Colors.orange[700]),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[700]))
          : Column(
        children: [
          ElevatedButton(onPressed: _addWorkout, child: Text('Add Workout')),
          Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(workouts[index]['name']),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteWorkout(workouts[index]['id'])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}