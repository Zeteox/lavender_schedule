import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  const EditTaskPage({super.key});
  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = "Rendu";
  String _titre = "";
  String _description = "";
  String? _coursAssocie;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _mesCours = ["Développement Mobile", "Bases de Données", "Anglais"];

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    setState(() => _selectedDate = picked);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Saisie d'informations")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: "Rendu", label: Text("Rendu (Devoir)"), icon: Icon(Icons.assignment)),
                  ButtonSegment(value: "Note", label: Text("Note (Info)"), icon: Icon(Icons.edit_note)),
                ],
                selected: {_type},
                onSelectionChanged: (set) => setState(() => _type = set.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: const Color(0xFF282828), selectedBackgroundColor: const Color(0xFFE7CCF5),
                  selectedForegroundColor: const Color(0xFF282828), foregroundColor: const Color(0xFFE7CCF5),
                  side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 18),
                decoration: _customInputDecoration("Titre", Icons.title_rounded),
                validator: (val) => val == null || val.isEmpty ? "Requis" : null,
                onSaved: (val) => _titre = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF282828),
                style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 18),
                decoration: _customInputDecoration("Lier à un cours", Icons.school),
                items: _mesCours.map((cours) => DropdownMenuItem(value: cours, child: Text(cours))).toList(),
                onChanged: (val) => setState(() => _coursAssocie = val),
              ),
              const SizedBox(height: 16),
              if (_type == "Rendu") ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _customInputDecoration("Date limite", Icons.calendar_today),
                          child: Text(_selectedDate == null ? "Sélectionner" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", style: const TextStyle(color: Color(0xFFFFEFDC))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                maxLines: 4, style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 18),
                decoration: _customInputDecoration("Description / Notes détaillées", Icons.notes_rounded),
                onSaved: (val) => _description = val ?? "",
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9155AB), foregroundColor: const Color(0xFFFFEFDC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ref.read(taskProvider.notifier).addTask(Task(
                        id: DateTime.now().toString(), type: _type, title: _titre,
                        description: _description, course: _coursAssocie, dueDate: _type == "Rendu" ? _selectedDate : null,
                      ));
                      _formKey.currentState!.reset();
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
    );
  }
}