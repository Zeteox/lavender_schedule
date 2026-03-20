import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final PageController _pageController = PageController(initialPage: 50);
  final String _moisActuel = "Mars 2026";

  Future<void> _ouvrirChoixMois() async {
    DateTime? dateChoisie = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mois changé avec succès !")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_moisActuel, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month, color: Color(0xFFE7CCF5)), onPressed: _ouvrirChoixMois)
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) => _buildWeekView(),
      ),
    );
  }

  Widget _buildWeekView() {
    final List<String> jours = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: jours.length,
      itemBuilder: (context, dayIndex) {
        bool isCoursImportant = dayIndex == 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              child: Text("${jours[dayIndex]} ${16 + dayIndex}".toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFE7CCF5))),
            ),
            if (isCoursImportant) Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 60, child: Text("09:00\n10:30", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFFEFDC), height: 1.5, fontSize: 16))),
                Column(
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF282828), border: Border.all(color: const Color(0xFFE7CCF5), width: 3), shape: BoxShape.circle)),
                    Container(width: 2, height: 90, color: const Color(0xFFE7CCF5).withOpacity(0.5)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/details'),
                    child: Hero(
                      tag: 'cours_dev_mobile',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Développement Mobile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFFEFDC))),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFFFEFDC)),
                                  SizedBox(width: 6),
                                  Text("Salle B2 - CM", style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ) else const Text("Aucun cours", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        );
      },
    );
  }
}