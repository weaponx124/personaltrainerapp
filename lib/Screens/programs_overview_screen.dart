import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProgramsOverviewScreen extends StatefulWidget {
  const ProgramsOverviewScreen({super.key});

  @override
  _ProgramsOverviewScreenState createState() => _ProgramsOverviewScreenState();
}

class _ProgramsOverviewScreenState extends State<ProgramsOverviewScreen> {
  List<Map<String, dynamic>> programs = [];
  bool isLoading = true;
  String selectedProgram = '';
  Map<String, dynamic> programInputs = {};
  String unit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadUnit();
    _loadPrograms();
  }

  Future<void> _loadUnit() async {
    final loadedUnit = await DatabaseHelper().getWeightUnit();
    unit = loadedUnit ?? 'kg';
    if (mounted) setState(() {});
    print('Loaded unit: $unit');
  }

  Future<void> _loadPrograms() async {
    try {
      setState(() => isLoading = true);
      final loadedPrograms = await DatabaseHelper().getPrograms();
      programs = loadedPrograms.map((program) {
        return Map<String, dynamic>.from(program);
      }).toList();
      print('Loaded programs: $programs');
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading programs: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading programs: $e')));
    }
  }

  void _startProgram(String programName) {
    selectedProgram = programName;
    programInputs.clear();
    _showProgramDialog(programName, true);
  }

  Future<void> _showProgramDialog(String programName, bool isNewInstance) async {
    final unit = await DatabaseHelper().getWeightUnit() ?? 'kg';
    print('Showing dialog for program: $programName, unit: $unit');
    if (isNewInstance) {
      if (programName == '5/3/1 Program') {
        programInputs['1RMs'] = <String, double>{};
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Start ${programName} (New Cycle)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Squat', 'Bench', 'Deadlift', 'Overhead'].map((lift) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter $lift 1RM ($unit)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsedValue = double.tryParse(value);
                        final oneRMs = programInputs['1RMs'] as Map<String, double>;
                        if (parsedValue != null && parsedValue > 0) {
                          oneRMs[lift] = parsedValue;
                        } else {
                          oneRMs.remove(lift);
                        }
                        print('Updated 1RMs in dialog: ${programInputs['1RMs']}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final oneRMs = programInputs['1RMs'] as Map<String, double>? ?? {};
                  print('1RMs before validation: $oneRMs');
                  final allValid = oneRMs.length == 4 && oneRMs.values.every((v) => v is double && v > 0);
                  if (allValid) {
                    programInputs['unit'] = unit;
                    try {
                      await DatabaseHelper().saveProgram(programName, programInputs);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/program_details', arguments: programName);
                      await _loadPrograms();
                      print('Program list refreshed after starting new $programName cycle');
                    } catch (e) {
                      print('Error saving new $programName cycle: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all 1RMs with valid values!')));
                  }
                },
                child: const Text('Start'),
              ),
            ],
          ),
        );
      } else if (['Russian Squat Program', 'Super Squats'].contains(programName)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Start ${programName} (New Cycle)'),
            content: TextField(
              decoration: InputDecoration(
                labelText: 'Enter 1RM ($unit)',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsedValue = double.tryParse(value);
                programInputs['1RM'] = parsedValue ?? 0.0;
                print('Updated 1RM: ${programInputs['1RM']}');
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final oneRM = programInputs['1RM'] as double?;
                  print('1RM before validation: $oneRM');
                  if (oneRM != null && oneRM > 0) {
                    programInputs['unit'] = unit;
                    try {
                      await DatabaseHelper().saveProgram(programName, programInputs);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/program_details', arguments: programName);
                      await _loadPrograms();
                      print('Program list refreshed after starting new $programName cycle');
                    } catch (e) {
                      print('Error saving new $programName cycle: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 1RM!')));
                  }
                },
                child: const Text('Start'),
              ),
            ],
          ),
        );
      } else if (programName == 'Texas Method') {
        programInputs['1RMs'] = <String, double>{};
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Start ${programName} (New Cycle)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Squat', 'Bench', 'Deadlift'].map((lift) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter $lift 1RM ($unit)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsedValue = double.tryParse(value);
                        final oneRMs = programInputs['1RMs'] as Map<String, double>;
                        if (parsedValue != null && parsedValue > 0) {
                          oneRMs[lift] = parsedValue;
                        } else {
                          oneRMs.remove(lift);
                        }
                        print('Updated 1RMs: ${programInputs['1RMs']}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final oneRMs = programInputs['1RMs'] as Map<String, double>? ?? {};
                  print('1RMs before validation: $oneRMs');
                  final allValid = oneRMs.length == 3 && oneRMs.values.every((v) => v is double && v > 0);
                  if (allValid) {
                    programInputs['unit'] = unit;
                    try {
                      await DatabaseHelper().saveProgram(programName, programInputs);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/program_details', arguments: programName);
                      await _loadPrograms();
                      print('Program list refreshed after starting new $programName cycle');
                    } catch (e) {
                      print('Error saving new $programName cycle: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all 1RMs with valid values!')));
                  }
                },
                child: const Text('Start'),
              ),
            ],
          ),
        );
      } else if (programName == '30-Day Squat Challenge') {
        programInputs['unit'] = unit;
        try {
          await DatabaseHelper().saveProgram(programName, programInputs);
          Navigator.pushNamed(context, '/program_details', arguments: programName);
          await _loadPrograms();
          print('Program list refreshed after starting new $programName cycle');
        } catch (e) {
          print('Error saving new $programName cycle: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
        }
      }
    } else {
      // Resume existing custom program
      final existingProgram = await DatabaseHelper().getProgram(programName);
      if (existingProgram['details'] != null && (existingProgram['details'] as Map<String, dynamic>).isNotEmpty) {
        Navigator.pushNamed(context, '/program_details', arguments: programName);
      }
    }
  }

  void _addNewProgram() {
    // No changes needed here, as it already serves as the "Add Program" list
  }

  void _createCustomProgram() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Program'),
        content: CustomProgramForm(onSave: (name, details) async {
          print('Attempting to save custom program: $name with details: $details');
          try {
            await DatabaseHelper().saveProgram(name, details);
            print('Custom program saved successfully, reloading programs...');
            final updatedPrograms = await DatabaseHelper().getPrograms();
            print('Verified loaded programs after save: $updatedPrograms');
            Navigator.pop(context);
            await _loadPrograms();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Program "$name" saved successfully!')));
          } catch (e) {
            print('Error saving custom program: $e');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
          }
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPrograms = programs.where((p) => p['completed'] != true).toList();
    final completedPrograms = programs.where((p) => p['completed'] == true).toList();
    final availablePrograms = [
      {'name': 'Russian Squat Program'},
      {'name': '5/3/1 Program'},
      {'name': 'Super Squats'},
      {'name': 'Texas Method'},
      {'name': '30-Day Squat Challenge'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('Back button pressed on ProgramsOverviewScreen, popping route');
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Program Section
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.orange[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Program', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availablePrograms.length + 1,
                      itemBuilder: (context, index) {
                        if (index == availablePrograms.length) {
                          return ListTile(
                            leading: const Icon(Icons.create, color: Colors.orange),
                            title: const Text('Custom Program'),
                            onTap: _createCustomProgram,
                          );
                        }
                        final program = availablePrograms[index];
                        return ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.orange),
                          title: Text(program['name'] as String),
                          onTap: () => _startProgram(program['name'] as String),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Current Cycles Section
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.lightGreen[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Cycles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700])),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentPrograms.length,
                        itemBuilder: (context, index) {
                          final program = currentPrograms[index] as Map<String, dynamic>;
                          final String startDate = (program['startDate'] as String?)?.toString() ?? 'Not started';
                          final String oneRM = (program['details']?['1RM'] as double?)?.toString() ?? 'Not set';
                          final String programUnit = (program['details']?['unit'] as String?) ?? unit;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              title: Text(program['name'] as String, style: const TextStyle(fontSize: 16, color: Colors.green)),
                              subtitle: Text('Started: $startDate | 1RM: $oneRM $programUnit', style: const TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.play_arrow, color: Colors.green),
                              onTap: () => _startProgram(program['name'] as String),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Completed Cycles Section
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completed Cycles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[700])),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: completedPrograms.length,
                        itemBuilder: (context, index) {
                          final program = completedPrograms[index] as Map<String, dynamic>;
                          final String completedDate = (program['startDate'] as String?)?.toString() ?? 'Unknown';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              title: Text(program['name'] as String, style: const TextStyle(fontSize: 16, color: Colors.red)),
                              subtitle: Text('Completed: $completedDate', style: const TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.check, color: Colors.green),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomProgramForm extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onSave;

  const CustomProgramForm({super.key, required this.onSave});

  @override
  _CustomProgramFormState createState() => _CustomProgramFormState();
}

class _CustomProgramFormState extends State<CustomProgramForm> {
  final _formKey = GlobalKey<FormState>();
  String programName = '';
  String movement = 'Squat';
  double oneRM = 0.0;
  int sets = 5;
  int reps = 5;
  List<double> percentages = [65.0, 70.0, 75.0, 80.0, 85.0];
  double increment = 2.5;
  bool isPercentageBased = true;
  String unit = 'kg';

  final List<String> movements = ['Squat', 'Bench Press', 'Deadlift', 'Overhead Press', 'Pull-up'];

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final loadedUnit = await DatabaseHelper().getWeightUnit();
    unit = loadedUnit ?? 'kg';
    if (mounted) setState(() {});
    print('Loaded unit in CustomProgramForm: $unit');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Program Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Enter a program name' : null,
              onSaved: (value) => programName = value!,
              onChanged: (value) => programName = value ?? '',
            ),
            DropdownButtonFormField<String>(
              value: movement,
              hint: const Text('Select Movement'),
              items: movements.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => movement = value!),
              decoration: const InputDecoration(labelText: 'Movement'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '1RM ($unit)'),
              keyboardType: TextInputType.number,
              validator: (value) => double.tryParse(value ?? '') == null ? 'Enter a valid 1RM' : null,
              onSaved: (value) => oneRM = double.parse(value!),
              onChanged: (value) => oneRM = double.tryParse(value) ?? 0.0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
              onSaved: (value) => sets = int.parse(value!),
              onChanged: (value) => sets = int.tryParse(value) ?? 5,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
              onSaved: (value) => reps = int.parse(value!),
              onChanged: (value) => reps = int.tryParse(value) ?? 5,
            ),
            SwitchListTile(
              title: const Text('Percentage Based'),
              value: isPercentageBased,
              onChanged: (value) => setState(() => isPercentageBased = value),
            ),
            if (isPercentageBased)
              Column(
                children: List.generate(5, (index) {
                  final controller = TextEditingController(text: percentages[index].toStringAsFixed(1));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Set ${index + 1} Percentage (%)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newValue = double.tryParse(value) ?? percentages[index];
                        setState(() => percentages[index] = newValue);
                        controller.value = TextEditingController(text: newValue.toStringAsFixed(1)).value;
                      },
                    ),
                  );
                }),
              ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Increment per Workout (%)'),
              keyboardType: TextInputType.number,
              validator: (value) => double.tryParse(value ?? '') == null ? 'Enter a valid increment' : null,
              onSaved: (value) => increment = double.parse(value!),
              onChanged: (value) => increment = double.tryParse(value) ?? 2.5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final unit = await DatabaseHelper().getWeightUnit() ?? 'kg';
                  final details = {
                    'movement': movement,
                    '1RM': oneRM,
                    'sets': sets,
                    'reps': reps,
                    'percentages': percentages,
                    'increment': increment,
                    'isPercentageBased': isPercentageBased,
                    'goal': 'Custom Program',
                    'unit': unit,
                  };
                  print('Saving custom program: $programName with details: $details');
                  try {
                    await DatabaseHelper().saveProgram(programName, details);
                    print('Custom program save completed successfully');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Program "$programName" saved successfully!')));
                  } catch (e) {
                    print('Error saving custom program: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly!')));
                }
              },
              child: const Text('Save Program', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}