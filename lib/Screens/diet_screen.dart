import 'package:flutter/material.dart';
import '../database_helper.dart';

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<Map<String, dynamic>> meals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => isLoading = true);
    meals = await DatabaseHelper().getMeals();
    setState(() => isLoading = false);
  }

  Future<void> _addMeal() async {
    final newMeal = {'id': DateTime.now().toString(), 'name': 'New Meal', 'calories': 0};
    await DatabaseHelper().insertMeal(newMeal);
    await _loadMeals();
  }

  Future<void> _deleteMeal(String mealId) async {
    await DatabaseHelper().deleteMeal(mealId);
    await _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diet'), backgroundColor: Colors.orange[700]),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[700]))
          : Column(
        children: [
          ElevatedButton(onPressed: _addMeal, child: Text('Add Meal')),
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(meals[index]['name']),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteMeal(meals[index]['id'])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}