class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime dateTime;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.dateTime,
  });
}
