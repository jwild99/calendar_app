import '../models/todo_model.dart';
import 'package:flutter/material.dart';
import '../const/constant.dart';
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
      body: Stack(
        children: [
        // Main content (to-do list)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  searchBox(),
                  Expanded(
                    child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 50, bottom: 20),
                          child: Text(
                            'All ToDos',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 97, 94, 94),
                            ),
                          ),
                        ),
                        for (ToDo item in _foundToDo)
                          TodoItem(
                            todo: item,
                            onToDoChanged: _handleToDoChange,
                            onDeleteItem: _deleteToDoItem,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer container with the text field and add button
            Align(
              alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 228, 241, 144),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo item',
                      hintStyle: TextStyle
                      (
                        color: const Color.fromARGB(255, 97, 94, 94),
                      ),
                      border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    // Add button with plus icon
                    Container(
                      margin: EdgeInsets.only(bottom: 20, right: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          _addToDoItem(_todoController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          minimumSize: Size(60, 60),
                          elevation: 10,
                        ),
                        child: Text(
                          '+',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 40, color: const Color.fromARGB(255, 97, 94, 94),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
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
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });
    _saveToDoList();
    _foundToDo = List.from(todoList);
  }

  void _addToDoItem(String todo) {
    print("Adding to do item: $todo");
    setState(() {
      todoList.add(ToDo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        todoText: todo
      ));
      _sortToDoList();
      _foundToDo = List.from(todoList);
    });
    _todoController.clear();
    _saveToDoList();
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

      ),
    );
  }
}
