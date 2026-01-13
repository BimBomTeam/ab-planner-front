import 'package:ab_planner/models/group_model.dart';
import 'package:ab_planner/models/program_model.dart';
import 'package:ab_planner/services/user_service.dart';
import 'package:flutter/material.dart';

class GroupSelectionDialog extends StatefulWidget {
  const GroupSelectionDialog({super.key});

  @override
  State<GroupSelectionDialog> createState() => _GroupSelectionDialogState();
}

class _GroupSelectionDialogState extends State<GroupSelectionDialog> {
  bool _isLoading = true;
  List<ProgramModel> _programs = [];
  List<Group> _groups = [];

  ProgramModel? _selectedProgram;
  ProgramYear? _selectedYear;
  Specialization? _selectedSpecialization;
  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final programs = await UserService.fetchAllPrograms();
      if (mounted) {
        setState(() {
          _programs = programs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading programs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd ładowania kierunków')),
        );
      }
    }
  }

  Future<void> _loadGroups() async {
    if (_selectedProgram == null || _selectedYear == null) return;

    setState(() {
      _isLoading = true;
      _groups = [];
      _selectedGroup = null;
    });

    try {
      final groups = await UserService.fetchProgramGroups(
        programId: _selectedProgram!.id,
        programYearId: _selectedYear!.id,
        specializationId: _selectedSpecialization?.id,
      );

      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Błąd ładowania grup')));
      }
    }
  }

  Future<void> _saveSelection() async {
    if (_selectedGroup == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.createStudentGroupSelection(
        groupId: _selectedGroup!.id,
      );
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('Error saving selection: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd zapisywania wyboru: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wybierz grupę'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const LinearProgressIndicator()
              else ...[
                // Program Selection
                DropdownButtonFormField<ProgramModel>(
                  decoration: const InputDecoration(labelText: 'Kierunek'),
                  isExpanded: true,
                  value: _selectedProgram,
                  items:
                      _programs.map((program) {
                        return DropdownMenuItem(
                          value: program,
                          child: Text(
                            program.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProgram = value;
                      _selectedYear = null;
                      _selectedSpecialization = null;
                      _groups = [];
                      _selectedGroup = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Year Selection
                DropdownButtonFormField<ProgramYear>(
                  decoration: const InputDecoration(labelText: 'Rocznik'),
                  isExpanded: true,
                  value: _selectedYear,
                  items:
                      _selectedProgram?.years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.year.toString()),
                        );
                      }).toList() ??
                      [],
                  onChanged:
                      _selectedProgram == null
                          ? null
                          : (value) {
                            setState(() {
                              _selectedYear = value;
                              _groups = [];
                              _selectedGroup = null;
                            });
                            if (_selectedProgram?.specializations.isEmpty ??
                                true) {
                              _loadGroups();
                            }
                          },
                ),
                const SizedBox(height: 16),

                // Specialization Selection (only if available)
                if (_selectedProgram?.specializations.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<Specialization>(
                      decoration: const InputDecoration(
                        labelText: 'Specjalizacja',
                      ),
                      isExpanded: true,
                      value: _selectedSpecialization,
                      items:
                          _selectedProgram!.specializations.map((spec) {
                            return DropdownMenuItem(
                              value: spec,
                              child: Text(
                                spec.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialization = value;
                          _groups = [];
                          _selectedGroup = null;
                        });
                        if (_selectedYear != null) {
                          _loadGroups();
                        }
                      },
                    ),
                  ),

                // Group Selection
                DropdownButtonFormField<Group>(
                  decoration: const InputDecoration(labelText: 'Grupa'),
                  isExpanded: true,
                  value: _selectedGroup,
                  items:
                      _groups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(
                            '${group.code} (${group.groupType.label})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged:
                      _groups.isEmpty
                          ? null
                          : (value) {
                            setState(() {
                              _selectedGroup = value;
                            });
                          },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed:
              _selectedGroup != null && !_isLoading ? _saveSelection : null,
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
