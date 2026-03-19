class SchoolClass {
  final String subject;
  final List<String> teachers;
  final List<String> rooms;
  final String type;
  final DateTime start;
  final DateTime end;

  SchoolClass({
    required this.subject,
    required this.teachers,
    required this.rooms,
    required this.type,
    required this.start,
    required this.end,
  });

  @override
  String toString() {
    return '$subject | $type | ${teachers.join(', ')} | ${rooms.join(', ')} | $start → $end';
  }
}