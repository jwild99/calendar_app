import '../models/todo_model.dart';
import 'package:flutter/material.dart';
import '../widgets/todo_item_widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _HomeState();
}

class _HomeState extends State<TodoScreen> {
  final todoList = ToDo.todoList();
  final _todoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ToDo> _foundToDo = [];

  void _debugPrintFilePath() async {
    final file = await _getFile();
    print("To-Do List saved at: ${file.path}");
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final userDataPath = Directory('${directory.path}/user_data');

    if (!await userDataPath.exists()) {
      await userDataPath.create(recursive: true);
    }

    return File('${userDataPath.path}/todo_list.json');
  }

  Future<void> _saveToDoList() async {
    final file = await _getFile();
    final jsonList = jsonEncode(todoList.map((todo) => todo.toJson()).toList());
    await file.writeAsString(jsonList);
  }

  Future<void> _loadToDoList() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonData);
        setState(() {
          todoList.clear();
          todoList.addAll(jsonList.map((json) => ToDo.fromJson(json)).toList());
          _sortToDoList();
          _foundToDo = List.from(todoList);
        });
      }
    } catch (e) {
      print("Error loading to-do list: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToDoList();
    _debugPrintFilePath();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(233, 240, 252, 184),
      appBar: _buildAppBar(),
      body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: searchBox(),
    ),
    Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(150, 255, 255, 255),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.grey),
              thickness: WidgetStateProperty.all(6),
              radius: Radius.circular(8),
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _foundToDo.length,
              itemBuilder: (context, index) {
                final item = _foundToDo[index];
                  return TodoItem(
                    todo: item,
                    onToDoChanged: _handleToDoChange,
                    onDeleteItem: _deleteToDoItem,
                  );
              },
            ),
          ),
        ),
      ),
    ),
  ),
),
    Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 241, 144),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  hintText: 'Add a new todo item',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 97, 94, 94),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _addToDoItem(_todoController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(60, 60),
              elevation: 10,
            ),
            child: const Text(
              '+',
              style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 97, 94, 94)),
            ),
          ),
        ],
      ),
    ),
  ],
),
      );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      _sortToDoList();
      _foundToDo = List.from(todoList);
    });
    _saveToDoList();
  }

  void _deleteToDoItem(String id) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Item"),
        content: Text("Are you sure you want to delete this to-do item?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                todoList.removeWhere((item) => item.id == id);
                _saveToDoList();
                _foundToDo = List.from(todoList);
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
            child: Text("No"),
          ),
        ],
      );
    },
    );
  }

  void _addToDoItem(String todo) async {
    print("Adding to do item: $todo");

    DateTime? selectedDate = await _selectDueDate(context);

    setState(() {
        todoList.add(ToDo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        todoText: todo,
        dueDate: selectedDate,
        ));
        _sortToDoList();
        _foundToDo = List.from(todoList);
    });
    _todoController.clear();
    _saveToDoList();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "$todo" to your to-do list!'), duration: Durations.long3,),
    );
  }

  Future<DateTime?> _selectDueDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        );
        return picked;
  }

  void _sortToDoList() {
    todoList.sort((a, b) => a.isDone ? 1 : -1);
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList;
    }
    else {
      results = todoList.where((item) => item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }

    setState(() {
      _foundToDo = results;
    });

  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 205),
        borderRadius: BorderRadius.circular(20)
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
              maxHeight: 20,
              minWidth: 25
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(254, 255, 233, 1),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text("To-Do List"), // Or your custom title
        ],
      ),
    );
  }
}
