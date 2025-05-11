import 'package:flutter/material.dart';
import 'package:ab_planner/services/lesson_service.dart';

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
  String? _selectedFrequency;
  String? _selectedTerm;
  bool _isLoading = false;

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
    {'id': 3, 'name': 'Grupa 3'},
  ];

  final List<String> _frequencies = ['once', 'weekly', 'biweekly'];
  final List<String> _terms = ['winter', 'summer'];

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
          _startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
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
          _endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _saveLesson() async {
    final room = _roomController.text.trim();
    final title = _titleController.text.trim();

    if (room.isEmpty || title.isEmpty || _selectedTeacherId == null || _selectedLessonTypeId == null || _selectedGroupId == null || _startDate == null || _endDate == null || _selectedFrequency == null || _selectedTerm == null) {
      _showError('Wypełnij wszystkie pola!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await LessonService.addLesson(
        room: room,
        title: title,
        start: _startDate!,
        end: _endDate!,
        teacherId: _selectedTeacherId!,
        lessonTypeId: _selectedLessonTypeId!,
        groupId: _selectedGroupId!,
        frequency: _selectedFrequency!,
        term: _selectedTerm!,
      );

      if (!mounted) return;
      _showSuccess('Lekcja została dodana!');
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
      builder: (ctx) => AlertDialog(
        title: const Text('Sukces'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Zajęcia'),
      ),
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
              decoration: const InputDecoration(labelText: 'Tytuł zajęć'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedTeacherId,
              items: _teachers.map<DropdownMenuItem<int>>((teacher) {
                return DropdownMenuItem<int>(
                  value: teacher['id'],
                  child: Text(teacher['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTeacherId = value),
              decoration: const InputDecoration(labelText: 'Prowadzący'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedLessonTypeId,
              items: _lessonTypes.map<DropdownMenuItem<int>>((type) {
                return DropdownMenuItem<int>(
                  value: type['id'],
                  child: Text(type['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLessonTypeId = value),
              decoration: const InputDecoration(labelText: 'Typ zajęć'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedGroupId,
              items: _groups.map<DropdownMenuItem<int>>((group) {
                return DropdownMenuItem<int>(
                  value: group['id'],
                  child: Text(group['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGroupId = value),
              decoration: const InputDecoration(labelText: 'Grupa'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: _frequencies.map((freq) {
                return DropdownMenuItem<String>(
                  value: freq,
                  child: Text(freq),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedFrequency = value),
              decoration: const InputDecoration(labelText: 'Częstotliwość'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTerm,
              items: _terms.map((term) {
                return DropdownMenuItem<String>(
                  value: term,
                  child: Text(term),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTerm = value),
              decoration: const InputDecoration(labelText: 'Semestr'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_startDate == null ? 'Wybierz początek zajęć' : 'Start: ${_startDate.toString()}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectStartDate(context),
            ),
            ListTile(
              title: Text(_endDate == null ? 'Wybierz koniec zajęć' : 'Koniec: ${_endDate.toString()}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectEndDate(context),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLesson,
                child: _isLoading
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
