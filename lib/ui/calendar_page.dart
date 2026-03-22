import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/providers/class_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late PageController _pageController;
  late DateTime _currentWeekStart;
  int _currentPage = 500;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = _getWeekStart(DateTime(now.year, now.month, now.day));
    _pageController = PageController(initialPage: 500);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final shifted = d.subtract(Duration(days: d.weekday - 1));
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  DateTime _weekStartForPage(int page) {
    return _currentWeekStart.add(Duration(days: (page - 500) * 7));
  }

  DateTime get _displayedWeekStart => _weekStartForPage(_currentPage);

  String _formatMois(DateTime date) {
    const mois = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    return '${mois[date.month - 1]} ${date.year}';
  }

  String _formatJour(DateTime date) {
    const jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    return '${jours[date.weekday - 1]} ${date.day}';
  }

  Future<void> _ouvrirChoixSemaine() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2027, 12, 31),
      currentDate: _displayedWeekStart,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE7CCF5),
            onPrimary: Color(0xFF282828),
            surface: Color(0xFF282828),
            onSurface: Color(0xFFFFEFDC),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final pickedClean = DateTime(picked.year, picked.month, picked.day);
      final newWeekStart = _getWeekStart(pickedClean);
      final diff = (newWeekStart.difference(_currentWeekStart).inDays / 7).round();
      final targetPage = 500 + diff;
      setState(() => _currentPage = targetPage);
      _pageController.jumpToPage(targetPage);
    }
  }

  List<SchoolClass> _coursForDay(List<SchoolClass> allCours, DateTime day) {
    return allCours.where((c) {
      final local = c.start.toLocal();
      return local.year == day.year &&
             local.month == day.month &&
             local.day == day.day;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  String _heure(DateTime dt) {
    final l = dt.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final coursState = ref.watch(coursProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatMois(_displayedWeekStart),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE7CCF5)),
            onPressed: () => ref.read(coursProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFFE7CCF5)),
            onPressed: _ouvrirChoixSemaine,
          ),
        ],
      ),
      body: coursState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFF9155AB), size: 48),
              const SizedBox(height: 12),
              Text('Erreur : $e', style: const TextStyle(color: Color(0xFFFFEFDC))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(coursProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (allCours) => PageView.builder(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() => _currentPage = page);
          },
          itemBuilder: (context, pageIndex) {
            final weekStart = _weekStartForPage(pageIndex);
            return _buildWeekView(allCours, weekStart);
          },
        ),
      ),
    );
  }

  Widget _buildWeekView(List<SchoolClass> allCours, DateTime weekStart) {
    final jours = List.generate(5, (i) => weekStart.add(Duration(days: i)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: jours.length,
      itemBuilder: (context, dayIndex) {
        final jour = jours[dayIndex];
        final coursJour = _coursForDay(allCours, jour);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              child: Text(
                _formatJour(jour).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE7CCF5),
                ),
              ),
            ),
            if (coursJour.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Aucun cours', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              )
            else
              ...coursJour.map((cours) => _buildCoursCard(cours)),
          ],
        );
      },
    );
  }

  Widget _buildCoursCard(SchoolClass cours) {
    final heureDebut = _heure(cours.start);
    final heureFin = _heure(cours.end);
    final tag = 'cours_${cours.subject}_${cours.start.millisecondsSinceEpoch}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$heureDebut\n$heureFin',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFEFDC),
              height: 1.5,
              fontSize: 16,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                border: Border.all(color: const Color(0xFFE7CCF5), width: 3),
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 90, color: const Color(0xFFE7CCF5).withOpacity(0.5)),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF9155AB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cours.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFFEFDC)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cours.type,
                        style: const TextStyle(color: Color(0xFFE7CCF5), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      if (cours.rooms.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFFFEFDC)),
                            const SizedBox(width: 6),
                            Text(
                              cours.rooms.join(', '),
                              style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                      if (cours.teachers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Color(0xFFFFEFDC)),
                            const SizedBox(width: 6),
                            Text(
                              cours.teachers.join(', '),
                              style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14),
                            ),
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
      ],
    );
  }
}