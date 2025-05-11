import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/screens/log_in_screen.dart';
import 'package:ab_planner/screens/profile_screen.dart';
import 'package:ab_planner/screens/add_lesson_screen.dart';
import 'package:ab_planner/screens/edit_lesson_screen.dart';
import 'package:ab_planner/services/lesson_service.dart';
import 'package:ab_planner/widgets/lesson_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/utils/jwt_decoder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoggedIn = false;
  bool _isLoadingLessons = false;
  List<Lesson> _lessons = [];
  String? _userRole;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL', null);
    _checkLoginStatus();
    _loadLessons();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final payload = parseJwt(token);
        setState(() {
          _isLoggedIn = true;
          _userRole = payload['role'];
        });
      } catch (e) {
        setState(() {
          _isLoggedIn = false;
          _userRole = null;
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
        _userRole = null;
      });
    }
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoadingLessons = true;
      _lessons = [];
    });

    try {
      final lessons = await LessonService.getLessonsByDate(_selectedDate);
      setState(() {
        _lessons = lessons;
      });
    } catch (e) {
      print('Błąd podczas pobierania lekcji: $e');
      setState(() {
        _lessons = [];
      });
    } finally {
      setState(() {
        _isLoadingLessons = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pl', 'PL'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadLessons();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM', 'pl_PL').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: _isLoggedIn
            ? IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              )
            : IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogInScreen()),
                  );
                },
              ),
        title: Text(
          'Zajęcia (${_lessons.length}) – $formattedDate',
          style: const TextStyle(fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: _isLoadingLessons
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Brak zajęć tego dnia.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            elevation: 3,
                          ),
                          onPressed: _loadLessons,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Odśwież'),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    return Slidable(
                      key: ValueKey(lesson.id),
                      endActionPane: _userRole == 'admin'
                          ? ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditLessonScreen(lesson: lesson),
                                      ),
                                    );
                                    _loadLessons();
                                  },
                                  backgroundColor: Colors.orange,
                                  icon: Icons.edit,
                                  label: 'Edytuj',
                                ),
                              ],
                            )
                          : null,
                      child: LessonItem(lesson: lesson),
                    );
                  },
                ),
      floatingActionButton: (_isLoggedIn && _userRole == 'admin')
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddLessonScreen()),
                );
                _loadLessons();
              },
              backgroundColor: Colors.deepPurpleAccent,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
    );
  }
}
