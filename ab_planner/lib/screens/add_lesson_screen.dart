import 'package:flutter/material.dart';
import 'package:ab_planner/services/lesson_service.dart';
import 'package:ab_planner/services/lesson_form_service.dart';

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

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _lessonTypes = [];
  List<Map<String, dynamic>> _groups = [];

  final List<String> _frequencies = [ 'weekly', 'biweekly'];
  final List<String> _terms = ['winter', 'summer'];

  @override
  void initState() {
    super.initState();
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

        _selectedTeacherId = teachers.isNotEmpty ? teachers.first['id'] : null;
        _selectedLessonTypeId = types.isNotEmpty ? types.first['id'] : null;
        _selectedGroupId = groups.isNotEmpty ? groups.first['id'] : null;
        _selectedFrequency = _frequencies.first;
        _selectedTerm = _terms.first;
      });
    } catch (e) {
      _showError('Błąd ładowania danych formularza');
    }
  }

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

  Future<void> _saveLesson() async {
    final room = _roomController.text.trim();
    final title = _titleController.text.trim();

    if (room.isEmpty ||
        title.isEmpty ||
        _selectedTeacherId == null ||
        _selectedLessonTypeId == null ||
        _selectedGroupId == null ||
        _startDate == null ||
        _endDate == null ||
        _selectedFrequency == null ||
        _selectedTerm == null) {
      _showError('Wypełnij wszystkie pola!');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('Data końcowa nie może być przed początkową!');
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

  Widget buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(labelText: label),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFormReady = _teachers.isNotEmpty &&
        _lessonTypes.isNotEmpty &&
        _groups.isNotEmpty &&
        _selectedFrequency != null &&
        _selectedTerm != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj Zajęcia')),
      body: !isFormReady
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  buildDropdown<int>(
                    label: 'Prowadzący',
                    value: _selectedTeacherId,
                    items: _teachers.map((teacher) {
                      return DropdownMenuItem<int>(
                        value: teacher['id'],
                        child: Text(
                          teacher['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTeacherId = val),
                  ),
                  const SizedBox(height: 16),
                  buildDropdown<int>(
                    label: 'Typ zajęć',
                    value: _selectedLessonTypeId,
                    items: _lessonTypes.map((type) {
                      return DropdownMenuItem<int>(
                        value: type['id'],
                        child: Text(type['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedLessonTypeId = val),
                  ),
                  const SizedBox(height: 16),
                  buildDropdown<int>(
                    label: 'Grupa',
                    value: _selectedGroupId,
                    items: _groups.map((group) {
                      return DropdownMenuItem<int>(
                        value: group['id'],
                        child: Text(group['group_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGroupId = val),
                  ),
                  const SizedBox(height: 16),
                  buildDropdown<String>(
                    label: 'Częstotliwość',
                    value: _selectedFrequency,
                    items: _frequencies.map((f) {
                      return DropdownMenuItem<String>(
                        value: f,
                        child: Text(f),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFrequency = val),
                  ),
                  const SizedBox(height: 16),
                  buildDropdown<String>(
                    label: 'Semestr',
                    value: _selectedTerm,
                    items: _terms.map((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(t),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTerm = val),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_startDate == null ? 'Wybierz początek zajęć' : 'Start: $_startDate'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectStartDate(context),
                  ),
                  ListTile(
                    title: Text(_endDate == null ? 'Wybierz koniec zajęć' : 'Koniec: $_endDate'),
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
