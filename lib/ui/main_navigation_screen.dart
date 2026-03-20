import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'calendar_page.dart';
import 'day_detail_page.dart';
import 'edit_task_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const CalendarPage(),
    const DayDetailPage(),
    const EditTaskPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF282828),
        selectedItemColor: const Color(0xFFE7CCF5),
        unselectedItemColor: const Color(0xFFFFEFDC).withOpacity(0.6),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
          BottomNavigationBarItem(icon: Icon(Icons.view_day), label: 'Aujourd\'hui'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Saisie'),
        ],
      ),
    );
  }
}