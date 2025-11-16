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
  List<LessonV1> _lessons = [];
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
      // group_id=1 na sztywno, dzisiejsza data
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
      
      print('📅 Pobieranie lekcji dla grupy 1, data: ${_selectedDate.toLocal()}');
      print('📅 Od: $startOfDay');
      print('📅 Do: $endOfDay');
      
      final lessons = await LessonService.fetchLessons(
        groupId: 1,
        dateFrom: startOfDay,
        dateTo: endOfDay,
      );
      
      setState(() {
        _lessons = lessons;
      });
      
      print('✅ Załadowano ${lessons.length} lekcji');
    } catch (e) {
      print('❌ Błąd podczas pobierania lekcji: $e');
      setState(() {
        _lessons = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd ładowania lekcji: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
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

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadLessons();
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadLessons();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadLessons();
  }

  String _getTotalDuration() {
    if (_lessons.isEmpty) return '0h 0min';
    
    int totalMinutes = 0;
    for (var lesson in _lessons) {
      final duration = lesson.endsAt.difference(lesson.startsAt);
      totalMinutes += duration.inMinutes;
    }
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'pl_PL').format(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.day == DateTime.now().day;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F38),
        elevation: 0,
        leading: _isLoggedIn
            ? IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              )
            : IconButton(
                icon: const Icon(Icons.login, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogInScreen()),
                  );
                },
              ),
        title: const Text(
          'Plan zajęć',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (!isToday)
            IconButton(
              icon: const Icon(Icons.today, color: Colors.deepPurpleAccent),
              tooltip: 'Dzisiaj',
              onPressed: _goToToday,
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: 'Wybierz datę',
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header z datą i nawigacją
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1F38),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Nawigacja dat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                        onPressed: _goToPreviousDay,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'DZISIAJ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                        onPressed: _goToNextDay,
                      ),
                    ],
                  ),
                ),
                // Statystyki
                if (_lessons.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          icon: Icons.event_note,
                          label: 'Zajęcia',
                          value: '${_lessons.length}',
                        ),
                        _buildStatCard(
                          icon: Icons.schedule,
                          label: 'Czas',
                          value: _getTotalDuration(),
                        ),
                        _buildStatCard(
                          icon: Icons.school,
                          label: 'Wykłady',
                          value: '${_lessons.where((l) => l.lessonType == 'lecture').length}',
                        ),
                        _buildStatCard(
                          icon: Icons.science,
                          label: 'Laby',
                          value: '${_lessons.where((l) => l.lessonType == 'lab').length}',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Lista zajęć
          Expanded(
            child: _isLoadingLessons
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.deepPurpleAccent),
                        SizedBox(height: 16),
                        Text('Ładowanie zajęć...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                : _lessons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Brak zajęć tego dnia',
                              style: TextStyle(fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ciesz się wolnym dniem!',
                              style: TextStyle(fontSize: 14, color: Colors.white38),
                            ),
                            const SizedBox(height: 24),
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
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: _lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = _lessons[index];
                          
                          // Tylko stare lekcje można edytować (bo EditLessonScreen używa starego API)
                          final canEdit = lesson is Lesson && _userRole == 'admin';
                          
                          return Slidable(
                            key: ValueKey(lesson.id),
                            endActionPane: canEdit
                                ? ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditLessonScreen(lesson: lesson as Lesson),
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
          ),
        ],
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

  Widget _buildStatCard({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
