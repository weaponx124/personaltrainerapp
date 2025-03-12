import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database_helper.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programName;

  ProgramDetailsScreen({required this.programName});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  List<Map<String, dynamic>> programLog = [];
  bool isLoading = true;
  String unit = 'kg';
  Map<String, dynamic> programDetails = {};
  Map<String, Color> movementColors = {
    'Squat': Colors.red,
    'Bench Press': Colors.blue,
    'Deadlift': Colors.green,
    'Overhead Press': Colors.purple,
    'Pull-up': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _loadProgramLog();
    _loadUnit();
  }

  Future<void> _loadProgramLog() async {
    try {
      setState(() => isLoading = true);
      programLog = await DatabaseHelper().getProgramLog(widget.programName);
      programDetails = (await DatabaseHelper().getProgram(widget.programName))['details'] ?? {};
      print('Loaded program log for ${widget.programName}: $programLog');
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading program log: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading program log: $e')));
    }
  }

  Future<void> _loadUnit() async {
    unit = await DatabaseHelper().getWeightUnit();
    if (mounted) setState(() {});
  }

  void _logSet(int logIndex, int setIndex, int actualReps, double actualWeight) {
    setState(() {
      programLog[logIndex]['sets'][setIndex]['actualReps'] = actualReps;
      programLog[logIndex]['sets'][setIndex]['actualWeight'] = actualWeight;
      programLog[logIndex]['sets'][setIndex]['completed'] = true;
      programLog[logIndex]['completed'] = programLog[logIndex]['sets'].every((s) => s['completed'] == true);
    });
    DatabaseHelper().saveProgramLog(widget.programName, programLog);
  }

  void _toggleSetCompletion(int logIndex, int setIndex) {
    setState(() {
      final set = programLog[logIndex]['sets'][setIndex];
      set['completed'] = !set['completed'];
      programLog[logIndex]['completed'] = programLog[logIndex]['sets'].every((s) => s['completed'] == true);
    });
    DatabaseHelper().saveProgramLog(widget.programName, programLog);
  }

  Future<void> _markProgramComplete() async {
    final programs = await DatabaseHelper().getPrograms();
    final programIndex = programs.indexWhere((p) => p['name'] == widget.programName);
    if (programIndex >= 0) {
      programs[programIndex]['completed'] = true;
      await DatabaseHelper().savePrograms(programs);
      await _loadProgramLog();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Program marked as completed!')));
      Navigator.pop(context);
    }
  }

  Map<String, List<FlSpot>> _getProgressDataByMovement() {
    final progressData = <String, List<FlSpot>>{};
    for (var entry in programLog) {
      String movement = 'Unknown';
      // Extract movement from the goal string (e.g., "3 sets x 5 reps @ 100 lbs (Squat)")
      final goal = entry['goal'] as String;
      final match = RegExp(r'\(([^)]+)\)').firstMatch(goal);
      if (match != null) {
        movement = match.group(1)!;
      } else if (programDetails['movement'] != null) {
        movement = programDetails['movement'] as String;
      }
      if (!progressData.containsKey(movement)) progressData[movement] = [];
      final date = DateTime.parse(entry['date']);
      final daysSinceStart = date.difference(DateTime.now().subtract(Duration(days: 365))).inDays;
      final weight = (entry['sets'] as List).map((s) => s['actualWeight'] ?? s['weight'] as double).reduce((a, b) => a + b) / (entry['sets'] as List).length;
      progressData[movement]!.add(FlSpot(daysSinceStart.toDouble(), weight));
    }
    return progressData;
  }

  @override
  Widget build(BuildContext context) {
    final progressData = _getProgressDataByMovement();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.programName),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProgramLog,
            tooltip: 'Refresh Log',
          ),
          IconButton(
            icon: Icon(Icons.done, color: Colors.white),
            onPressed: _markProgramComplete,
            tooltip: 'Mark as Complete',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[700]))
          : programLog.isEmpty
          ? Center(child: Text('No log entries found for ${widget.programName}.', style: TextStyle(color: Colors.orange[700])))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700])),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${-value.toInt()}d ago',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()} $unit',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                          minX: -365,
                          maxX: 0,
                          minY: 0,
                          maxY: (programDetails['1RM'] ?? 200).toDouble() * 1.2,
                          lineBarsData: progressData.entries.map<LineChartBarData>((entry) {
                            return LineChartBarData(
                              spots: entry.value,
                              isCurved: true,
                              gradient: LinearGradient(colors: [movementColors[entry.key]!.withOpacity(0.8), movementColors[entry.key]!.withOpacity(0.3)]),
                              barWidth: 2,
                              dotData: FlDotData(show: true),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: progressData.keys.map((movement) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: movementColors[movement] ?? Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(movement, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Program Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700])),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: programLog.length,
                          itemBuilder: (context, logIndex) {
                            final entry = programLog[logIndex];
                            final isToday = entry['date'] == DateTime.now().toIso8601String().split('T')[0];
                            final sets = entry['sets'] as List<dynamic>;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: ExpansionTile(
                                title: Text(
                                  'Week ${entry['week']}, Day ${entry['day']}: ${entry['goal']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                                ),
                                subtitle: Text('Date: ${entry['date']}'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 16.0,
                                        columns: [
                                          DataColumn(label: Text('Set', style: TextStyle(color: Colors.orange[700]))),
                                          DataColumn(label: Text('Target Reps', style: TextStyle(color: Colors.orange[700]))),
                                          DataColumn(label: Text('Target Weight ($unit)', style: TextStyle(color: Colors.orange[700]))),
                                          DataColumn(label: Text('Actual Reps', style: TextStyle(color: Colors.orange[700]))),
                                          DataColumn(label: Text('Actual Weight ($unit)', style: TextStyle(color: Colors.orange[700]))),
                                          DataColumn(label: Text('Done', style: TextStyle(color: Colors.orange[700]))),
                                        ],
                                        rows: sets.asMap().entries.map((setEntry) {
                                          final setIndex = setEntry.key;
                                          final set = setEntry.value as Map<String, dynamic>;
                                          final targetReps = set['reps'] as int;
                                          final targetWeight = set['weight'] as double;
                                          final completed = set['completed'] as bool;
                                          final actualReps = set['actualReps'] as int?;
                                          final actualWeight = set['actualWeight'] as double?;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text('Set ${setIndex + 1}')),
                                              DataCell(Text('$targetReps')),
                                              DataCell(Text(targetWeight.toStringAsFixed(1))),
                                              DataCell(
                                                TextFormField(
                                                  initialValue: actualReps?.toString() ?? '',
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (value) {
                                                    final newReps = int.tryParse(value) ?? actualReps ?? targetReps;
                                                    _logSet(logIndex, setIndex, newReps, actualWeight ?? targetWeight);
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                TextFormField(
                                                  initialValue: actualWeight?.toStringAsFixed(1) ?? '',
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (value) {
                                                    final newWeight = double.tryParse(value) ?? actualWeight ?? targetWeight;
                                                    _logSet(logIndex, setIndex, actualReps ?? targetReps, newWeight);
                                                  },
                                                ),
                                              ),
                                              DataCell(Checkbox(
                                                value: completed,
                                                activeColor: Colors.orange[700],
                                                onChanged: isToday
                                                    ? (value) => _toggleSetCompletion(logIndex, setIndex)
                                                    : null,
                                              )),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  if (isToday)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                                        onPressed: () {
                                          setState(() {
                                            programLog[logIndex]['completed'] = true;
                                          });
                                          DatabaseHelper().saveProgramLog(widget.programName, programLog);
                                        },
                                        child: Text('Mark Day as Complete', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}