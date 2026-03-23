import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';
import 'widgets/course_card.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final PageController _pageController = PageController(initialPage: 50);
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  Future<void> _openMonthPicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context, initialDate: _currentWeekStart, firstDate: DateTime(2025), lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFE7CCF5), onPrimary: Color(0xFF282828), surface: Color(0xFF282828), onSurface: Color(0xFFFFEFDC))),
        child: child!,
      ),
    );
    if (selectedDate != null) setState(() => _currentWeekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1)));
  }

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesProvider);
    final currentMonthLabel = "${_currentWeekStart.month.toString().padLeft(2, '0')}/${_currentWeekStart.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Planning - $currentMonthLabel", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.calendar_month, color: Color(0xFFE7CCF5)), onPressed: _openMonthPicker)],
      ),
      body: classesState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(child: Text("Erreur: $e", style: const TextStyle(color: Color(0xFFFFEFDC)))),
        data: (allClasses) {
          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentWeekStart = index > 50 ? _currentWeekStart.add(const Duration(days: 7)) : _currentWeekStart.subtract(const Duration(days: 7));
                _pageController.jumpToPage(50);
              });
            },
            itemBuilder: (context, index) {
              final weekdays = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"];

              return LayoutBuilder(
                builder: (context, constraints) {
                  int cols = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 2 : 1;
                  double itemWidth = (constraints.maxWidth / cols) - 24;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16, runSpacing: 0,
                      children: List.generate(weekdays.length, (dayIndex) {
                        final currentDate = _currentWeekStart.add(Duration(days: dayIndex));
                        final classesOfDay = allClasses.where((c) =>
                        c.start.toLocal().year == currentDate.year && c.start.toLocal().month == currentDate.month && c.start.toLocal().day == currentDate.day
                        ).toList()..sort((a, b) => a.start.compareTo(b.start));

                        return SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                                child: Text("${weekdays[dayIndex]} ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}".toUpperCase(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFE7CCF5))),
                              ),
                              if (classesOfDay.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text("Aucun cours", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                              else ...classesOfDay.map((schoolClass) => CourseCard(schoolClass: schoolClass)),
                            ],
                          ),
                        );
                      }),
                    ),
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