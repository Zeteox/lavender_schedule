class Task {
  final String id;
  final String type;
  final String title;
  final String description;
  final String? course;
  final String? specificClassId;
  final DateTime? dueDate;

  Task({
    required this.id, required this.type, required this.title,
    required this.description, this.course, this.specificClassId, this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'title': title, 'description': description,
    'course': course, 'specificClassId': specificClassId,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'], type: json['type'], title: json['title'],
    description: json['description'], course: json['course'],
    specificClassId: json['specificClassId'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );
}