import 'package:flutter/material.dart';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  int? _selectedTeacherId;
  int? _selectedLessonTypeId;
  int? _selectedGroupId;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  // Przykładowe dane do dropdownów (symulacja, potem podciągniesz z API)
  final List<Map<String, dynamic>> _teachers = [
    {'id': 1, 'name': 'Jan Kowalski'},
    {'id': 2, 'name': 'Anna Nowak'},
  ];

  final List<Map<String, dynamic>> _lessonTypes = [
    {'id': 1, 'name': 'Wykład'},
    {'id': 2, 'name': 'Ćwiczenia'},
    {'id': 3, 'name': 'Laboratorium'},
  ];

  final List<Map<String, dynamic>> _groups = [
    {'id': 1, 'name': 'Grupa 1'},
    {'id': 2, 'name': 'Grupa 2'},
  ];

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveLesson() {
    final room = _roomController.text.trim();
    final title = _titleController.text.trim();

    if (room.isEmpty ||
        title.isEmpty ||
        _selectedTeacherId == null ||
        _selectedLessonTypeId == null ||
        _selectedGroupId == null ||
        _startDate == null ||
        _endDate == null) {
      _showError('Wypełnij wszystkie pola!');
      return;
    }

    final newLesson = {
      'room': room,
      'title': title,
      'teacherId': _selectedTeacherId,
      'start': _startDate!.toIso8601String(),
      'end': _endDate!.toIso8601String(),
      'lessonTypeId': _selectedLessonTypeId,
      'groupId': _selectedGroupId,
    };

    print('Nowa lekcja: $newLesson');
    _showSuccess('Lekcja została dodana!');
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Błąd'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sukces'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj Zajęcia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Sala'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tytuł'),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedTeacherId,
              items:
                  _teachers.map<DropdownMenuItem<int>>((teacher) {
                    return DropdownMenuItem<int>(
                      value: teacher['id'] as int,
                      child: Text(teacher['name']),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedTeacherId = value),
              decoration: const InputDecoration(labelText: 'Prowadzący'),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedLessonTypeId,
              items:
                  _lessonTypes.map<DropdownMenuItem<int>>((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'] as int,
                      child: Text(type['name']),
                    );
                  }).toList(),
              onChanged:
                  (value) => setState(() => _selectedLessonTypeId = value),
              decoration: const InputDecoration(labelText: 'Typ zajęć'),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedGroupId,
              items:
                  _groups.map<DropdownMenuItem<int>>((group) {
                    return DropdownMenuItem<int>(
                      value: group['id'] as int,
                      child: Text(group['name']),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedGroupId = value),
              decoration: const InputDecoration(labelText: 'Grupa'),
            ),

            const SizedBox(height: 16),

            ListTile(
              title: Text(
                _startDate == null
                    ? 'Wybierz początek'
                    : 'Start: ${_startDate.toString()}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectStartDate(context),
            ),
            ListTile(
              title: Text(
                _endDate == null
                    ? 'Wybierz koniec'
                    : 'End: ${_endDate.toString()}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectEndDate(context),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLesson,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Dodaj Zajęcia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
