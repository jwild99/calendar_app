class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
      };
}
