import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/group_model.dart';
import 'package:ab_planner/screens/main_screen.dart';
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

  List<GroupModel> _allGroups = [];
  List<String> _years = [];
  List<String> _majors = [];
  List<GroupModel> _filteredGroups = [];

  String? _selectedYear;
  String? _selectedMajor;
  GroupModel? _selectedGroup;
  int? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    try {
      await _loadAllGroups();
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd ładowania danych')),
        );
      }
    }
  }

  Future<void> _loadAllGroups() async {
    final groups = await UserService.fetchAllGroups();
    setState(() {
      _allGroups = groups;
      _years = groups
          .map((g) => g.startYear)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
    });
  }

  Future<void> _loadUserData() async {
    if (_allGroups.isEmpty) return;

    final userData = await UserService.fetchCurrentUser();
    final groupData = userData['Group'];

    setState(() {
      _userId = userData['id'];
      _firstNameController.text = userData['first_name'] ?? '';
      _lastNameController.text = userData['last_name'] ?? '';
      _emailController.text = userData['email'] ?? '';

      if (groupData != null) {
        _selectedYear = groupData['start_year'];
        _selectedMajor = groupData['Major'] != null ? groupData['Major']['name'] : null;
        _selectedGroup = _allGroups.any((g) => g.id == groupData['id'])
            ? _allGroups.firstWhere((g) => g.id == groupData['id'])
            : null;

        _updateMajors();
        _updateGroups();
      } else {
        _selectedYear = null;
        _selectedMajor = null;
        _selectedGroup = null;
      }
    });
  }

  void _updateMajors() {
    if (_selectedYear != null) {
      final majors = _allGroups
          .where((g) => g.startYear == _selectedYear)
          .map((g) => g.majorName ?? '')
          .toSet()
          .where((name) => name.isNotEmpty)
          .toList();
      setState(() {
        _majors = majors;
        if (!_majors.contains(_selectedMajor)) {
          _selectedMajor = null;
          _selectedGroup = null;
        }
      });
    }
  }

  void _updateGroups() {
    if (_selectedYear != null && _selectedMajor != null) {
      setState(() {
        _filteredGroups = _allGroups
            .where((g) =>
                g.startYear == _selectedYear &&
                g.majorName == _selectedMajor)
            .toList();
        if (!_filteredGroups.contains(_selectedGroup)) {
          _selectedGroup = null;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_selectedGroup == null || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie dane')),
      );
      return;
    }

    try {
      await UserService.saveProfile(
        userId: _userId!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        groupId: _selectedGroup!.id,
      );

      await _initData(); // ✅ po zapisie od razu wczytaj z serwera

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dane zapisane pomyślnie')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd zapisu danych')),
        );
      }
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
              enabled: false,
              decoration: const InputDecoration(labelText: 'Adres e-mail'),
            ),
            const Divider(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              items: _years
                  .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                  .toList(),
              onChanged: (year) {
                setState(() {
                  _selectedYear = year;
                  _selectedMajor = null;
                  _selectedGroup = null;
                });
                _updateMajors();
              },
              decoration: const InputDecoration(labelText: 'Rocznik'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedMajor,
              items: _majors
                  .map((major) => DropdownMenuItem(value: major, child: Text(major)))
                  .toList(),
              onChanged: _selectedYear == null
                  ? null
                  : (major) {
                      setState(() {
                        _selectedMajor = major;
                        _selectedGroup = null;
                      });
                      _updateGroups();
                    },
              decoration: const InputDecoration(labelText: 'Kierunek'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<GroupModel>(
              value: _selectedGroup,
              items: _filteredGroups
                  .map((group) => DropdownMenuItem(
                        value: group,
                        child: Text(group.groupName),
                      ))
                  .toList(),
              onChanged: _selectedMajor == null
                  ? null
                  : (group) {
                      setState(() {
                        _selectedGroup = group;
                      });
                    },
              decoration: const InputDecoration(labelText: 'Grupa'),
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
