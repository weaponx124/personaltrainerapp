import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> progress = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => isLoading = true);
    progress = await DatabaseHelper().getProgress();
    setState(() => isLoading = false);
  }

  Future<void> _addProgress() async {
    final newProgress = {'id': DateTime.now().toString(), 'weight': 0.0, 'date': DateTime.now().toIso8601String()};
    await DatabaseHelper().insertProgress(newProgress);
    await _loadProgress();
  }

  Future<void> _deleteProgress(String progressId) async {
    await DatabaseHelper().deleteProgress(progressId);
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress'), backgroundColor: Colors.orange[700]),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[700]))
          : Column(
        children: [
          ElevatedButton(onPressed: _addProgress, child: Text('Add Progress')),
          Expanded(
            child: ListView.builder(
              itemCount: progress.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('Weight: ${progress[index]['weight']}'),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProgress(progress[index]['id'])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}