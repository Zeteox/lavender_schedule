import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/task.dart';
import 'package:lavender_schedule/utils/dialog_utils.dart';
import '../model/school_class.dart';
import '../providers/task_provider.dart';
import '../providers/class_provider.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  const EditTaskPage({super.key});
  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = "Rendu", _title = "", _description = "";
  String? _selectedModule;
  SchoolClass? _selectedClass;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Color(0xFFE7CCF5), fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: const Color(0xFFE7CCF5)), filled: true, fillColor: const Color(0xFF282828),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7CCF5), width: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Saisie d'informations")),
      body: classesState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
          error: (e, _) => const Center(child: Text("Erreur de chargement", style: TextStyle(color: Color(0xFFFFEFDC)))),
          data: (allClasses) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: "Rendu", label: Text("Rendu (Devoir)"), icon: Icon(Icons.assignment)),
                              ButtonSegment(value: "Note", label: Text("Note (Info)"), icon: Icon(Icons.edit_note)),
                            ],
                            selected: {_type},
                            onSelectionChanged: (set) => setState(() { _type = set.first; _selectedModule = null; _selectedClass = null; }),
                            style: SegmentedButton.styleFrom(
                                backgroundColor: const Color(0xFF282828), selectedBackgroundColor: const Color(0xFFE7CCF5),
                                selectedForegroundColor: const Color(0xFF282828), foregroundColor: const Color(0xFFE7CCF5),
                                side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5)
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        TextFormField(
                          style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 18),
                          decoration: _customInputDecoration("Titre", Icons.title_rounded),
                          validator: (val) => val == null || val.isEmpty ? "Requis" : null,
                          onSaved: (val) => _title = val!,
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: () => showSearchDialog(context, allClasses, _type == "Rendu", (result) {
                            setState(() {
                              if (_type == "Rendu") _selectedModule = result as String;
                              else _selectedClass = result as SchoolClass;
                            });
                          }),
                          child: InputDecorator(
                            decoration: _customInputDecoration(_type == "Rendu" ? "Lier à un Module" : "Lier à un Cours", _type == "Rendu" ? Icons.school : Icons.class_),
                            child: Text(
                              _type == "Rendu" ? (_selectedModule ?? "Rechercher une matière...") : (_selectedClass == null ? "Rechercher un cours..." : "${_selectedClass!.subject} (${_selectedClass!.start.toLocal().day.toString().padLeft(2, '0')}/${_selectedClass!.start.toLocal().month.toString().padLeft(2, '0')})"),
                              style: TextStyle(color: (_type == "Rendu" ? _selectedModule : _selectedClass) == null ? Colors.grey : const Color(0xFFFFEFDC), fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_type == "Rendu") ...[
                          Row(
                            children: [
                              Expanded(child: InkWell(onTap: _pickDate, child: InputDecorator(decoration: _customInputDecoration("Date limite", Icons.calendar_today), child: Text(_selectedDate == null ? "Date" : "${_selectedDate!.day.toString().padLeft(2,'0')}/${_selectedDate!.month.toString().padLeft(2,'0')}/${_selectedDate!.year}", style: const TextStyle(color: Color(0xFFFFEFDC)))))),
                              const SizedBox(width: 16),
                              Expanded(child: InkWell(onTap: _pickTime, child: InputDecorator(decoration: _customInputDecoration("Heure", Icons.access_time), child: Text(_selectedTime == null ? "Heure" : "${_selectedTime!.hour.toString().padLeft(2,'0')}h${_selectedTime!.minute.toString().padLeft(2,'0')}", style: const TextStyle(color: Color(0xFFFFEFDC)))))),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          maxLines: 4, style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 18),
                          decoration: _customInputDecoration("Description détaillée", Icons.notes_rounded),
                          onSaved: (val) => _description = val ?? "",
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9155AB), foregroundColor: const Color(0xFFFFEFDC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                DateTime? finalDueDate;
                                if (_type == "Rendu" && _selectedDate != null && _selectedTime != null) finalDueDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
                                String? specificId = _selectedClass != null ? '${_selectedClass!.subject}_${_selectedClass!.start.millisecondsSinceEpoch}' : null;

                                ref.read(taskProvider.notifier).addTask(Task(id: DateTime.now().toString(), type: _type, title: _title, description: _description, course: _selectedModule, specificClassId: specificId, dueDate: finalDueDate));
                                _formKey.currentState!.reset();
                                setState(() { _selectedDate = null; _selectedTime = null; _selectedModule = null; _selectedClass = null; });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$_type enregistré !")));
                              }
                            },
                            child: Text("ENREGISTRER ${_type.toUpperCase()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}