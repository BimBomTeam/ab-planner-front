import 'package:flutter/material.dart';
import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/services/lesson_service.dart';
import 'package:ab_planner/services/lesson_form_service.dart';

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

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _lessonTypes = [];
  List<Map<String, dynamic>> _groups = [];

  final List<String> _frequencies = [ 'weekly', 'biweekly'];
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
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final teachers = await LessonFormService.fetchTeachers();
      final types = await LessonFormService.fetchLessonTypes();
      final groups = await LessonFormService.fetchGroups();

      setState(() {
        _teachers = teachers;
        _lessonTypes = types;
        _groups = groups;
      });
    } catch (e) {
      _showError('Błąd ładowania danych formularza');
    }
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
      body: _teachers.isEmpty || _lessonTypes.isEmpty || _groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(controller: _roomController, decoration: const InputDecoration(labelText: 'Sala')),
                  const SizedBox(height: 16),
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tytuł')),
                  const SizedBox(height: 16),

                  // Prowadzący
                  DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    isExpanded: true,
                    items: _teachers.map<DropdownMenuItem<int>>((t) {
                      return DropdownMenuItem<int>(
                        value: t['id'],
                        child: Text(t['name'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTeacherId = val!),
                    decoration: const InputDecoration(labelText: 'Prowadzący'),
                  ),
                  const SizedBox(height: 16),

                  // Typ zajęć
                  DropdownButtonFormField<int>(
                    value: _selectedLessonTypeId,
                    isExpanded: true,
                    items: _lessonTypes.map<DropdownMenuItem<int>>((t) {
                      return DropdownMenuItem<int>(
                        value: t['id'],
                        child: Text(t['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedLessonTypeId = val!),
                    decoration: const InputDecoration(labelText: 'Typ zajęć'),
                  ),
                  const SizedBox(height: 16),

                  // Grupa
                  DropdownButtonFormField<int>(
                    value: _selectedGroupId,
                    isExpanded: true,
                    items: _groups.map<DropdownMenuItem<int>>((g) {
                      return DropdownMenuItem<int>(
                        value: g['id'],
                        child: Text(g['group_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGroupId = val!),
                    decoration: const InputDecoration(labelText: 'Grupa'),
                  ),
                  const SizedBox(height: 16),

                  // Częstotliwość
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    isExpanded: true,
                    items: _frequencies.map<DropdownMenuItem<String>>((f) {
                      return DropdownMenuItem<String>(
                        value: f,
                        child: Text(f),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFrequency = val!),
                    decoration: const InputDecoration(labelText: 'Częstotliwość'),
                  ),
                  const SizedBox(height: 16),

                  // Semestr
                  DropdownButtonFormField<String>(
                    value: _selectedTerm,
                    isExpanded: true,
                    items: _terms.map<DropdownMenuItem<String>>((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(t),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTerm = val!),
                    decoration: const InputDecoration(labelText: 'Semestr'),
                  ),
                  const SizedBox(height: 16),

                  // Daty
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

                  // Przycisk zapisu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateLesson,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Zapisz zmiany'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
