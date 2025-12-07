import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ab_planner/models/user_model.dart';
import 'package:ab_planner/screens/main_screen.dart';
import 'package:ab_planner/services/user_service.dart';
import 'package:ab_planner/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _createdStartController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _createdStartController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await UserService.fetchCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _roleController.text = user.role.label;
          _createdStartController.text = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).format(user.createdAt);
        });

        // Pobierz grupę użytkownika
        try {
          final selections = await UserService.fetchStudentGroupSelections(
            userId: user.id,
          );
          if (selections.isNotEmpty && mounted) {
            final groupId = selections.first.groupId;
            final group = await UserService.fetchGroupById(groupId);
            if (mounted) {
              setState(() {
                _groupController.text =
                    '${group.code} (${group.groupType.label})';
              });
            }
          } else if (mounted) {
            setState(() {
              _groupController.text = 'Brak przypisanej grupy';
            });
          }
        } catch (e) {
          debugPrint('Błąd pobierania grupy: $e');
          if (mounted) {
            setState(() {
              _groupController.text = 'Błąd pobierania grupy';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Basic check if error suggests auth failure (implementation dependent,
        // assuming standard exception message or type could be improved in service)
        if (e.toString().contains('401')) {
          _logout();
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Błąd ładowania danych')));
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
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
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _user == null
                ? ListView(
                  children: const [
                    SizedBox(height: 50),
                    Center(
                      child: Text("Nie udało się pobrać danych użytkownika."),
                    ),
                  ],
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Imię i Nazwisko',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Adres e-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _groupController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Grupa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roleController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Rola',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _createdStartController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Dołączono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Wyloguj się',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
