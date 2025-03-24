import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/screens/log_in_screen.dart';
import 'package:ab_planner/widgets/lesson_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL', null); // załaduj dane PL
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE, d MMMM',
      'pl_PL',
    ).format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen(),));
          },
        ),
        title: Text('Zajęcia ($formattedDate)', style: TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder:
            (context, index) => LessonItem(
              lesson: Lesson(
                id: 'id',
                title: 'title',
                description: 'description',
                content: 'content',
              ),
            ),
      ),
    );
  }
}
