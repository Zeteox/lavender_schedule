import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../model/school_class.dart';

class CourseCard extends StatelessWidget {
  final SchoolClass schoolClass;

  const CourseCard({super.key, required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    final startLocal = schoolClass.start.toLocal();
    final endLocal = schoolClass.end.toLocal();
    final tag = 'class_${schoolClass.subject}_${schoolClass.start.millisecondsSinceEpoch}';

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
            onTap: () => context.push('/details', extra: schoolClass),
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
                        Text(schoolClass.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFFEFDC))),
                        const SizedBox(height: 4),
                        Text(schoolClass.type, style: const TextStyle(color: Color(0xFFE7CCF5), fontSize: 13, fontWeight: FontWeight.w500)),
                        if (schoolClass.rooms.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFFFEFDC)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(schoolClass.rooms.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14, fontWeight: FontWeight.w500), softWrap: true)),
                            ],
                          ),
                        ],
                        if (schoolClass.teachers.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Color(0xFFFFEFDC)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(schoolClass.teachers.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 14), softWrap: true)),
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
}