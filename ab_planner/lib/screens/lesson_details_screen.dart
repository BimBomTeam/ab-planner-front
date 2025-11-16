import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ab_planner/models/lesson.dart';

class LessonDetailsScreen extends StatelessWidget {
  final dynamic lesson; // Akceptuje zarówno Lesson jak i LessonV1

  const LessonDetailsScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final timeFormat = DateFormat.Hm();

    // Obsługa zarówno starych jak i nowych lekcji
    final DateTime startTime;
    final DateTime endTime;
    final String title;
    final String room;
    final String lecturerName;
    final String lecturerEmail;
    final String lessonType;
    final String groupCode;
    final String programName;
    final String specialization;
    final int capacity;
    final String status;

    if (lesson is LessonV1) {
      final lessonV1 = lesson as LessonV1;
      startTime = lessonV1.startsAt.toLocal();
      endTime = lessonV1.endsAt.toLocal();
      title = lessonV1.subject.name;
      room = '${lessonV1.room.building} ${lessonV1.room.number}';
      lecturerName = lessonV1.lecturer.name;
      lecturerEmail = lessonV1.lecturer.email;
      lessonType = lessonV1.lessonType == 'lecture' ? 'Wykład' : 'Laboratorium';
      groupCode = lessonV1.group.code;
      programName = lessonV1.group.program.name;
      specialization = lessonV1.group.specialization.name;
      capacity = lessonV1.room.capacity;
      status = lessonV1.status == 'scheduled' ? 'Zaplanowane' : lessonV1.status;
    } else {
      final oldLesson = lesson as Lesson;
      startTime = oldLesson.start.toLocal();
      endTime = oldLesson.end.toLocal();
      title = oldLesson.title;
      room = oldLesson.room;
      lecturerName = oldLesson.teacherName ?? 'Nieznany';
      lecturerEmail = 'brak';
      lessonType = oldLesson.lessonTypeName ?? 'Brak';
      groupCode = '${oldLesson.groupName ?? "Brak"} (${oldLesson.groupNumber ?? "-"})';
      programName = 'Brak';
      specialization = 'Brak';
      capacity = 0;
      status = 'Nieznany';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zajęć'),
        backgroundColor: const Color(0xFF1A1F38),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek z tytułem
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.deepPurpleAccent, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lessonType,
                            style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Status
              _buildSectionTitle('Status', context),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Sekcja: Czas i miejsce
              _buildSectionTitle('Czas i miejsce', context),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(Icons.calendar_today, 'Data', dateFormat.format(startTime)),
                _buildInfoRow(Icons.access_time, 'Godziny', '${timeFormat.format(startTime)} – ${timeFormat.format(endTime)}'),
                _buildInfoRow(Icons.meeting_room, 'Sala', room),
                _buildInfoRow(Icons.people, 'Pojemność sali', '$capacity osób'),
              ]),
              const SizedBox(height: 24),
              
              // Sekcja: Prowadzący
              _buildSectionTitle('Prowadzący', context),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(Icons.person, 'Imię i nazwisko', lecturerName),
                _buildInfoRow(Icons.email, 'Email', lecturerEmail),
              ]),
              const SizedBox(height: 24),
              
              // Sekcja: Grupa
              _buildSectionTitle('Grupa', context),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(Icons.groups, 'Kod grupy', groupCode),
                _buildInfoRow(Icons.school_outlined, 'Kierunek', programName),
                _buildInfoRow(Icons.auto_awesome, 'Specjalizacja', specialization),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
