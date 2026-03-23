import 'package:flutter/material.dart';
import '../model/school_class.dart';

Future<void> showSearchDialog(BuildContext context, List<SchoolClass> allCours, bool isRendu, Function(Object) onResult) async {
  String searchQuery = '';

  final result = await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Widget listContent;

          if (isRendu) {
            final uniqueModules = allCours
                .map((c) => c.subject)
                .toSet()
                .where((m) => m.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            listContent = ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueModules.length,
              itemBuilder: (context, index) {
                final module = uniqueModules[index];
                return ListTile(
                  title: Text(module, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pop(context, module),
                );
              },
            );
          } else {
            final filteredCours = allCours
                .where((c) => c.subject.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList()
              ..sort((a, b) => a.start.compareTo(b.start));

            listContent = ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCours.length,
              itemBuilder: (context, index) {
                final c = filteredCours[index];
                final startLocal = c.start.toLocal();
                final heureFr = "${startLocal.hour.toString().padLeft(2, '0')}h${startLocal.minute.toString().padLeft(2, '0')}";
                final dateFr = "Le ${startLocal.day.toString().padLeft(2, '0')}/${startLocal.month.toString().padLeft(2, '0')} à $heureFr";

                return ListTile(
                  title: Text(c.subject, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                  subtitle: Text(dateFr, style: const TextStyle(color: Color(0xFFE7CCF5))),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            );
          }

          return Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRendu ? "Rechercher une matière" : "Rechercher un cours",
                    style: const TextStyle(color: Color(0xFFE7CCF5), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Color(0xFFFFEFDC)),
                    decoration: InputDecoration(
                      hintText: "Titre du cours...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFE7CCF5)),
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Flexible(child: listContent),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler", style: TextStyle(color: Color(0xFF9155AB), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result != null) onResult(result);
}