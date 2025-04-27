import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/group_model.dart';
import 'package:ab_planner/screens/main_screen.dart';
import 'package:ab_planner/utils/jwt_decoder.dart';
import 'package:ab_planner/services/user_service.dart'; // <--- nasz nowy serwis
import 'dart:convert';
import 'package:ab_planner/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _fieldsOfStudy = ['Informatyka', 'Zarządzanie', 'Ekonomia'];
  String? _selectedFieldOfStudy;
  String? _selectedYear;
  GroupModel? _selectedGroup;

  List<String> _years = ["2023/24", "2022/23", "2021/22"];
  List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final payload = parseJwt(token);
      setState(() {
        _firstNameController.text = payload['first_name'] ?? '';
        _lastNameController.text = payload['last_name'] ?? '';
        _emailController.text = payload['email'] ?? '';
      });
    }
  }

  Future<void> _fetchGroups(String startYear) async {
    try {
      final groups = await UserService.fetchGroups(startYear);
      setState(() {
        _groups = groups;
        _selectedGroup = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd ładowania grup')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_selectedFieldOfStudy == null || _selectedYear == null || _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie dane')),
      );
      return;
    }

    try {
      await UserService.saveProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        fieldOfStudy: _selectedFieldOfStudy!,
        startYear: _selectedYear!,
        groupId: _selectedGroup!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dane zapisane pomyślnie')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd zapisu danych')),
      );
    }
  }

  Future<void> _logout() async {
    await UserService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Imię'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Nazwisko'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Adres e-mail'),
              enabled: false,
            ),
            const Divider(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedFieldOfStudy,
              hint: const Text('Wybierz kierunek'),
              items: _fieldsOfStudy
                  .map((field) => DropdownMenuItem(
                        value: field,
                        child: Text(field),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFieldOfStudy = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Kierunek studiów',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              hint: const Text('Wybierz rocznik'),
              items: _years
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      ))
                  .toList(),
              onChanged: (year) {
                if (year != null) {
                  setState(() {
                    _selectedYear = year;
                  });
                  _fetchGroups(year);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Rocznik',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<GroupModel>(
              value: _selectedGroup,
              hint: const Text('Wybierz grupę'),
              items: _groups.map((group) {
                return DropdownMenuItem<GroupModel>(
                  value: group,
                  child: Text(group.groupName),
                );
              }).toList(),
              onChanged: (group) {
                setState(() {
                  _selectedGroup = group;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Grupa',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Zapisz zmiany'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                'Wyloguj się',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
