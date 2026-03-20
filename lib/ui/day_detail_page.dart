import 'package:flutter/material.dart';

class DayDetailPage extends StatelessWidget {
  const DayDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails du Cours")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mercredi 18 Mars", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
            const SizedBox(height: 24),

            Hero(
              tag: 'cours_dev_mobile',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7CCF5), width: 2),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("09:00 - 12:30", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                          Text("CM", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9155AB), fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Développement Mobile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.person, size: 24, color: Color(0xFFE7CCF5)),
                          SizedBox(width: 12),
                          Text("Prof. Arthur MARTY", style: TextStyle(fontSize: 18, color: Color(0xFFFFEFDC))),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.room, size: 24, color: Color(0xFFE7CCF5)),
                          SizedBox(width: 12),
                          Text("Salle Labo B2", style: TextStyle(fontSize: 18, color: Color(0xFFFFEFDC))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}