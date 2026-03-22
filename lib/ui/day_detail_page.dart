import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/providers/class_provider.dart';

class DayDetailPage extends ConsumerWidget {
  const DayDetailPage({super.key});

  String _heure(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    const jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    const mois = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    final l = dt.toLocal();
    return '${jours[l.weekday - 1]} ${l.day} ${mois[l.month - 1]}';
  }

  DateTime _jourAffiche(List<SchoolClass> allCours) {
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      final sorted = allCours
          .where((c) => c.start.toLocal().isAfter(now))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      if (sorted.isNotEmpty) {
        final next = sorted.first.start.toLocal();
        return DateTime(next.year, next.month, next.day);
      }
    }
    return DateTime(now.year, now.month, now.day);
  }

  List<SchoolClass> _coursForDay(List<SchoolClass> allCours, DateTime day) {
    return allCours.where((c) {
      final l = c.start.toLocal();
      return l.year == day.year && l.month == day.month && l.day == day.day;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursState = ref.watch(coursProvider);

    return Scaffold(
      appBar: AppBar(
      title: const Text("Détails du Cours"),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFFE7CCF5)),
          onPressed: () => ref.read(coursProvider.notifier).refresh(),
        ),
      ],
    ),
      body: coursState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(child: Text('Erreur : $e', style: const TextStyle(color: Color(0xFFFFEFDC)))),
        data: (allCours) {
          final jour = _jourAffiche(allCours);
          final coursJour = _coursForDay(allCours, jour);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(jour), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
                const SizedBox(height: 24),
                if (coursJour.isEmpty)
                  const Text('Aucun cours aujourd\'hui 🎉', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                else
                  ...coursJour.map((cours) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Hero(
                      tag: 'cours_${cours.subject}_${cours.start.millisecondsSinceEpoch}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF282828),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE7CCF5), width: 2),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_heure(cours.start)} - ${_heure(cours.end)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                                  Text(cours.type, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9155AB), fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(cours.subject, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
                              const SizedBox(height: 20),
                              ...cours.teachers.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(children: [const Icon(Icons.person, size: 24, color: Color(0xFFE7CCF5)), const SizedBox(width: 12), Text(t, style: const TextStyle(fontSize: 18, color: Color(0xFFFFEFDC)))]),
                              )),
                              ...cours.rooms.map((r) => Row(children: [const Icon(Icons.room, size: 24, color: Color(0xFFE7CCF5)), const SizedBox(width: 12), Text(r, style: const TextStyle(fontSize: 18, color: Color(0xFFFFEFDC)))])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}