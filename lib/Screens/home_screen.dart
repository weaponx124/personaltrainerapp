import 'package:flutter/material.dart';
import '../database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String unit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    unit = await DatabaseHelper().getWeightUnit();
    setState(() {});
  }

  void _updateWeightUnit(String newUnit) async {
    await DatabaseHelper().setWeightUnit(newUnit);
    setState(() => unit = newUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Trainer'),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Weight Unit'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('kg'),
                        onTap: () {
                          _updateWeightUnit('kg');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('lbs'),
                        onTap: () {
                          _updateWeightUnit('lbs');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.orange[100],
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.orange),
                title: const Text('Programs', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  print('Navigating to /programs');
                  Navigator.pushNamed(context, '/programs');
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.orange[100],
              child: ListTile(
                leading: const Icon(Icons.line_weight, color: Colors.orange),
                title: const Text('Body Weight Progress', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  print('Navigating to /body_weight');
                  Navigator.pushNamed(context, '/body_weight');
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.orange[100],
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.orange),
                title: const Text('Workouts', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  print('Navigating to /workout');
                  Navigator.pushNamed(context, '/workout');
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.orange[100],
              child: ListTile(
                leading: const Icon(Icons.food_bank, color: Colors.orange),
                title: const Text('Diet', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  print('Navigating to /diet');
                  Navigator.pushNamed(context, '/diet');
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.orange[100],
              child: ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.orange),
                title: const Text('Progress', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  print('Navigating to /progress');
                  Navigator.pushNamed(context, '/progress');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}