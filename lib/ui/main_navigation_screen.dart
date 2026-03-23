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
  final List<Widget> _pages = [const DashboardPage(), const CalendarPage(), const DayDetailPage(), const EditTaskPage()];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: const Color(0xFF1E1E1E), selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  selectedIconTheme: const IconThemeData(color: Color(0xFF282828)),
                  unselectedIconTheme: IconThemeData(color: const Color(0xFFFFEFDC).withValues(alpha: 0.6)),
                  selectedLabelTextStyle: const TextStyle(color: Color(0xFFE7CCF5), fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: TextStyle(color: const Color(0xFFFFEFDC).withValues(alpha: 0.6)),
                  indicatorColor: const Color(0xFFE7CCF5), labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Accueil')),
                    NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text('Planning')),
                    NavigationRailDestination(icon: Icon(Icons.view_day), label: Text('Aujourd\'hui')),
                    NavigationRailDestination(icon: Icon(Icons.add_circle), label: Text('Saisie')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF3A3A3A)),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          );
        }
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex, type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF282828), selectedItemColor: const Color(0xFFE7CCF5),
            unselectedItemColor: const Color(0xFFFFEFDC).withValues(alpha: 0.6),
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
              BottomNavigationBarItem(icon: Icon(Icons.view_day), label: 'Aujourd\'hui'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Saisie'),
            ],
          ),
        );
      },
    );
  }
}