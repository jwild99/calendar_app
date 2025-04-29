class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  DateTime? dueDate;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // Parse the string back into DateTime
          : null,
    );
  }

  static List<ToDo> todoList() {
    return [];
  }
}
