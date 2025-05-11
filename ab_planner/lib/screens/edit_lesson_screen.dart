import 'package:flutter/material.dart';
import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/services/lesson_service.dart';

class EditLessonScreen extends StatefulWidget {
  final Lesson lesson;
  const EditLessonScreen({super.key, required this.lesson});

  @override
  State<EditLessonScreen> createState() => _EditLessonScreenState();
}

class _EditLessonScreenState extends State<EditLessonScreen> {
  late TextEditingController _roomController;
  late TextEditingController _titleController;

  late int _selectedTeacherId;
  late int _selectedLessonTypeId;
  late int _selectedGroupId;
  late String _selectedFrequency;
  late String _selectedTerm;
  late DateTime _startDate;
  late DateTime _endDate;
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
    {'id': 4, 'name': 'Grupa 4'},
  ];

  final List<String> _frequencies = ['once', 'weekly', 'biweekly'];
  final List<String> _terms = ['winter', 'summer'];

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    _roomController = TextEditingController(text: lesson.room);
    _titleController = TextEditingController(text: lesson.title);
    _selectedTeacherId = lesson.teacherId;
    _selectedLessonTypeId = lesson.lessonTypeId;
    _selectedGroupId = lesson.groupId;
    _selectedFrequency = lesson.frequency ?? 'once';
    _selectedTerm = lesson.term ?? 'winter';
    _startDate = lesson.start;
    _endDate = lesson.end;
  }

  Future<void> _updateLesson() async {
    if (_roomController.text.isEmpty || _titleController.text.isEmpty) {
      _showError('Wypełnij wszystkie pola!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await LessonService.updateLesson(
        id: widget.lesson.id,
        room: _roomController.text,
        title: _titleController.text,
        start: _startDate,
        end: _endDate,
        teacherId: _selectedTeacherId,
        lessonTypeId: _selectedLessonTypeId,
        groupId: _selectedGroupId,
        frequency: _selectedFrequency,
        term: _selectedTerm,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showError('Nie udało się zaktualizować lekcji.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Błąd'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
    );
    if (pickedTime == null) return;

    setState(() {
      final dt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (isStart) {
        _startDate = dt;
      } else {
        _endDate = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj Zajęcia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _roomController, decoration: const InputDecoration(labelText: 'Sala')),
            const SizedBox(height: 16),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tytuł')),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedTeacherId,
              items: _teachers.map((t) => DropdownMenuItem(value: t['id'], child: Text(t['name']))).toList(),
              onChanged: (val) => setState(() => _selectedTeacherId = val as int),
              decoration: const InputDecoration(labelText: 'Prowadzący'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedLessonTypeId,
              items: _lessonTypes.map((t) => DropdownMenuItem(value: t['id'], child: Text(t['name']))).toList(),
              onChanged: (val) => setState(() => _selectedLessonTypeId = val as int),
              decoration: const InputDecoration(labelText: 'Typ zajęć'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedGroupId,
              items: _groups.map((g) => DropdownMenuItem(value: g['id'], child: Text(g['name']))).toList(),
              onChanged: (val) => setState(() => _selectedGroupId = val as int),
              decoration: const InputDecoration(labelText: 'Grupa'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedFrequency,
              items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => _selectedFrequency = val as String),
              decoration: const InputDecoration(labelText: 'Częstotliwość'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedTerm,
              items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedTerm = val as String),
              decoration: const InputDecoration(labelText: 'Semestr'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Początek: $_startDate'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(true),
            ),
            ListTile(
              title: Text('Koniec: $_endDate'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateLesson,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Zapisz zmiany'),
            ),
          ],
        ),
      ),
    );
  }
}
