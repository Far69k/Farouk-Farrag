import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoItem {
  String title;
  bool isCompleted;
  String details;
  DateTime deadline;

  TodoItem({
    required this.title,
    this.isCompleted = false,
    this.details = '',
    required this.deadline,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'details': details,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isCompleted: json['isCompleted'],
      details: json['details'],
      deadline: DateTime.parse(json['deadline']),
    );
  }
}

class TodoList extends ChangeNotifier {
  SharedPreferences _prefs;
  List<TodoItem> _items = [];

  TodoList(SharedPreferences prefs) : _prefs = prefs {
    _loadData();
  }

  List<TodoItem> get items => _items;

  void _loadData() {
    final List<String>? jsonStringList = _prefs.getStringList('todos');
    if (jsonStringList != null) {
      _items = jsonStringList.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return TodoItem.fromJson(json);
      }).toList();
      notifyListeners();
    }
  }

  void _saveData() {
    final List<String> jsonStringList = _items.map((todoItem) {
      final Map<String, dynamic> json = todoItem.toJson();
      return jsonEncode(json);
    }).toList();
    _prefs.setStringList('todos', jsonStringList);
  }

  void addTodoItem(TodoItem item) {
    _items.add(item);
    _saveData();
    notifyListeners();
  }

  void updateTodoItem(int index, TodoItem item) {
    _items[index] = item;
    _saveData();
    notifyListeners();
  }

  void removeTodoItem(int index) {
    _items.removeAt(index);
    _saveData();
    notifyListeners();
  }
}
