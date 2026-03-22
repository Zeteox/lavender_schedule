import 'package:http/http.dart' as http;
import 'package:lavender_schedule/model/school_class.dart';

class Scrapper {
  static Scrapper? _instance;
  String _apiUrl = "";

  static void init(String apiUrl) {
    if (_instance == null) {
      _instance = Scrapper();
      _instance!.setApiUrl(apiUrl);
    }
  }

  static Scrapper getInstance() {
    if (_instance == null) {
      throw Exception("You need to initialise the instance with the init method first");
    }
    return _instance!;
  }

  String getApiUrl() {
    return _apiUrl;
  }

  void setApiUrl(String url) {
    _apiUrl = url;
  }

  Future<List<SchoolClass>> getClasses() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }

    return _parseIcs(response.body);
  }

  List<SchoolClass> _parseIcs(String icsContent) {
    final classes = <SchoolClass>[];

    final unfolded = icsContent
        .replaceAll('\r\n ', '')
        .replaceAll('\r\n\t', '');

    final lines = unfolded.split('\r\n');

    String? description;
    DateTime? start, end;
    bool inEvent = false;

    for (final line in lines) {
      if (line == 'BEGIN:VEVENT') {
        inEvent = true;
        description = null;
        start = end = null;
      } else if (line == 'END:VEVENT' && inEvent) {
        if (description != null && start != null && end != null) {
          final parsed = _parseDescription(description, start, end);
          if (parsed != null) classes.add(parsed);
        }
        inEvent = false;
      } else if (inEvent) {
        if (line.startsWith('DTSTART')) {
          start = _parseIcsDate(line);
        } else if (line.startsWith('DTEND')) {
          end = _parseIcsDate(line);
        } else if (line.startsWith('DESCRIPTION;LANGUAGE=fr:')) {
          description = line.substring('DESCRIPTION;LANGUAGE=fr:'.length);
        }
      }
    }

    return classes;
  }

  SchoolClass? _parseDescription(String desc, DateTime start, DateTime end) {
    final parts = <String, String>{};

    for (final segment in desc.split(r'\n')) {
      final colonIndex = segment.indexOf(' : ');
      if (colonIndex == -1) continue;
      final key = segment.substring(0, colonIndex).trim();
      final value = segment.substring(colonIndex + 3).trim();
      parts[key] = value;
    }

    final subject = parts['Matière'];
    final type = parts['Type'];
    final roomsRaw = parts['Salles'];
    final teachersRaw = parts['Intervenants'] ?? parts['Intervenant'];

    if (subject == null || type == null) return null;

    final teachers = teachersRaw
            ?.split(r'\,')
            .map((t) => t.trim())
            .toList() ??
        [];

    final rooms = roomsRaw
            ?.split(r'\,')
            .map((r) => r.trim())
            .toList() ??
        [];

    return SchoolClass(
      subject: subject,
      teachers: teachers,
      rooms: rooms,
      type: type,
      start: start,
      end: end,
    );
  }

  DateTime _parseIcsDate(String line) {
    final value = line.split(':').last;
    final clean = value.replaceAll('Z', '');

    if (clean.length == 8) {
      return DateTime.utc(
        int.parse(clean.substring(0, 4)),
        int.parse(clean.substring(4, 6)),
        int.parse(clean.substring(6, 8)),
      );
    }

    return DateTime.utc(
      int.parse(clean.substring(0, 4)),
      int.parse(clean.substring(4, 6)),
      int.parse(clean.substring(6, 8)),
      int.parse(clean.substring(9, 11)),
      int.parse(clean.substring(11, 13)),
    );
  }
}