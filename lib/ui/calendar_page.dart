import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/school_class.dart';
import '../providers/class_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final PageController _pageController = PageController(initialPage: 50);
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  Future<void> _ouvrirChoixMois() async {
    DateTime? dateChoisie = await showDatePicker(
      context: context,
      initialDate: _currentWeekStart,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE7CCF5),
              onPrimary: Color(0xFF282828),
              surface: Color(0xFF282828),
              onSurface: Color(0xFFFFEFDC),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateChoisie != null) {
      setState(() {
        _currentWeekStart = dateChoisie.subtract(Duration(days: dateChoisie.weekday - 1));
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semaine changée avec succès !")));
    }
  }

  Widget _buildCoursCard(SchoolClass cours) {
    final startLocal = cours.start.toLocal();
    final endLocal = cours.end.toLocal();
    final tag = 'cours_${cours.subject}_${cours.start.millisecondsSinceEpoch}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '${startLocal.hour.toString().padLeft(2, '0')}h${startLocal.minute.toString().padLeft(2, '0')}\n${endLocal.hour.toString().padLeft(2, '0')}h${endLocal.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFFEFDC), height: 1.5, fontSize: 16),
          ),
        ),
        Column(
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF282828), border: Border.all(color: const Color(0xFFE7CCF5), width: 3), shape: BoxShape.circle)),
            Container(width: 2, height: 90, color: const Color(0xFFE7CCF5).withValues(alpha: 0.5)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/details', extra: cours),
            child: Hero(
              tag: tag,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),

                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cours.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFFEFDC))),
                        const SizedBox(height: 4),
                        Text(cours.type, style: const TextStyle(color: Color(0xFFE7CCF5), fontSize: 13, fontWeight: FontWeight.w500)),
                        if (cours.rooms.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFFFEFDC)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(cours.rooms.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14, fontWeight: FontWeight.w500), softWrap: true)),
                            ],
                          ),
                        ],
                        if (cours.teachers.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Color(0xFFFFEFDC)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(cours.teachers.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14), softWrap: true)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursState = ref.watch(coursProvider);
    final moisActuel = "${_currentWeekStart.month.toString().padLeft(2, '0')}/${_currentWeekStart.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Planning - $moisActuel", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month, color: Color(0xFFE7CCF5)), onPressed: _ouvrirChoixMois)
        ],
      ),
      body: coursState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(child: Text("Erreur: $e", style: const TextStyle(color: Color(0xFFFFEFDC)))),
        data: (allCours) {
          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                if (index > 50) {
                  _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                } else if (index < 50) {
                  _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                }
                _pageController.jumpToPage(50);
              });
            },
            itemBuilder: (context, index) {
              final List<String> jours = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: jours.length,
                itemBuilder: (context, dayIndex) {
                  final currentDate = _currentWeekStart.add(Duration(days: dayIndex));

                  final coursDuJour = allCours.where((c) {
                    final start = c.start.toLocal();
                    return start.year == currentDate.year && start.month == currentDate.month && start.day == currentDate.day;
                  }).toList()..sort((a, b) => a.start.compareTo(b.start));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                        child: Text(
                            "${jours[dayIndex]} ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}".toUpperCase(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFE7CCF5))
                        ),
                      ),
                      if (coursDuJour.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text("Aucun cours", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      else
                        ...coursDuJour.map((cours) => _buildCoursCard(cours)),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}