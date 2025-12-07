import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/models/program_model.dart';
import 'package:ab_planner/models/group_model.dart';
import 'package:ab_planner/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  ProgramModel? _informaticsProgram;
  List<ProgramYear> _years = [];
  List<Specialization> _specializations = [];
  List<Group> _groups = [];

  ProgramYear? _selectedYear;
  Specialization? _selectedSpecialization;
  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Pobierz wszystkie programy i znajdź Informatykę
      final programs = await UserService.fetchAllPrograms();
      final informatyka = programs.firstWhere(
        (p) =>
            p.name.toLowerCase().contains('informatics') ||
            p.name.toLowerCase().contains('computer science') ||
            p.name.toLowerCase().contains('informatyka'),
        orElse:
            () =>
                programs
                    .first, // Fallback na pierwszy program jeśli nie znajdzie
      );

      setState(() {
        _informaticsProgram = informatyka;
        _years = informatyka.years;
        _specializations = informatyka.specializations;
      });

      // Załaduj zapisane preferencje
      final prefs = await SharedPreferences.getInstance();
      final savedGroupId = prefs.getInt('selected_group_id');

      if (savedGroupId != null) {
        await _loadSavedGroup(savedGroupId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd ładowania danych: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedGroup(int groupId) async {
    try {
      final group = await UserService.fetchGroupById(groupId);

      setState(() {
        _selectedYear = _years.firstWhere(
          (y) => y.id == group.year.id,
          orElse: () => _years.first,
        );

        _selectedSpecialization = _specializations.firstWhere(
          (s) => s.id == group.specialization.id,
          orElse: () => _specializations.first,
        );
      });

      await _loadGroups();

      setState(() {
        _selectedGroup = _groups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => _groups.first,
        );
      });
    } catch (e) {
      debugPrint('Nie udało się załadować zapisanej grupy: $e');
    }
  }

  Future<void> _loadGroups() async {
    if (_informaticsProgram == null ||
        _selectedYear == null ||
        _selectedSpecialization == null) {
      return;
    }

    try {
      final groups = await UserService.fetchProgramGroups(
        programId: _informaticsProgram!.id,
        programYearId: _selectedYear!.id,
        specializationId: _selectedSpecialization!.id,
      );

      setState(() {
        _groups = groups;
        if (_selectedGroup != null &&
            !groups.any((g) => g.id == _selectedGroup!.id)) {
          _selectedGroup = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd ładowania grup: $e')));
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wybierz grupę')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_group_id', _selectedGroup!.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ustawienia zapisane')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz grupę'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Stały kierunek
                    Card(
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: Colors.deepPurple),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kierunek',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  _informaticsProgram?.name ?? 'Ładowanie...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rok naboru
                    DropdownButtonFormField<ProgramYear>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Rok naboru',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items:
                          _years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.year.toString()),
                            );
                          }).toList(),
                      onChanged: (year) {
                        setState(() {
                          _selectedYear = year;
                          _selectedGroup = null;
                        });
                        _loadGroups();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Specjalizacja
                    DropdownButtonFormField<Specialization>(
                      value: _selectedSpecialization,
                      decoration: const InputDecoration(
                        labelText: 'Specjalizacja',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.stars),
                      ),
                      items:
                          _specializations.map((spec) {
                            return DropdownMenuItem(
                              value: spec,
                              child: Text(spec.name),
                            );
                          }).toList(),
                      onChanged: (spec) {
                        setState(() {
                          _selectedSpecialization = spec;
                          _selectedGroup = null;
                        });
                        _loadGroups();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Grupa
                    DropdownButtonFormField<Group>(
                      value: _selectedGroup,
                      decoration: const InputDecoration(
                        labelText: 'Grupa',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      items:
                          _groups.map((group) {
                            return DropdownMenuItem(
                              value: group,
                              child: Text(
                                '${group.code} (${group.groupType.label})',
                              ),
                            );
                          }).toList(),
                      onChanged:
                          _groups.isEmpty
                              ? null
                              : (group) {
                                setState(() {
                                  _selectedGroup = group;
                                });
                              },
                    ),
                    const SizedBox(height: 30),

                    // Podgląd wybranej grupy
                    if (_selectedGroup != null) ...[
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wybrana grupa:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.tag,
                                'Kod',
                                _selectedGroup!.code,
                              ),
                              _buildInfoRow(
                                Icons.school,
                                'Kierunek',
                                _selectedGroup!.program.name,
                              ),
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Rok naboru',
                                _selectedGroup!.year.year.toString(),
                              ),
                              _buildInfoRow(
                                Icons.stars,
                                'Specjalizacja',
                                _selectedGroup!.specialization.name,
                              ),
                              _buildInfoRow(
                                Icons.category,
                                'Typ zajęć',
                                _selectedGroup!.groupType.label,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Zapisz i zastosuj'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
