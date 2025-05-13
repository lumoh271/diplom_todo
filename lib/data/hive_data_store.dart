import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

///
import '../models/task.dart';
import '../models/user.dart';

class HiveDataStore {
  static const tasksBoxName = "tasksBox";
  static const usersBoxName = "usersBox";
  static const rememberMeBoxName = "rememberMeBox";

  final Box rememberMeBox = Hive.box(rememberMeBoxName);
  final Box<Task> taskBox = Hive.box<Task>(tasksBoxName);
  final Box<User> userBox = Hive.box<User>(usersBoxName);


  /// Remember Me
  Future<void> saveRememberMe(bool remember, String username) async {
    await rememberMeBox.put('rememberMe', remember);
    if (remember) {
      await rememberMeBox.put('savedUsername', username);
    } else {
      await rememberMeBox.delete('savedUsername');
    }
  }

  Future<Map<String, dynamic>> getRememberMe() async {
    return {
      'rememberMe': rememberMeBox.get('rememberMe', defaultValue: false),
      'username': rememberMeBox.get('savedUsername', defaultValue: ''),
    };
  }


  /// Add new Task
  Future<void> addTask({required Task task}) async {
    await taskBox.put(task.id, task);
  }

  /// Show task
  Future<Task?> getTask({required String id}) async {
    return taskBox.get(id);
  }

  /// Update task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  /// Delete task
  Future<void> dalateTask({required Task task}) async {
    await task.delete();
  }

  ValueListenable<Box<Task>> listenToTask() {
    return taskBox.listenable();
  }

  /// User methods
  Future<void> registerUser({required User user}) async {
    await userBox.put(user.id, user);
  }

  User? getUserByUsername(String username) {
    try {
      return userBox.values.firstWhere(
            (user) => user.username == username,
      );
    } catch (e) {
      return null;
    }
  }

  bool validateUser(String username, String password) {
    final user = getUserByUsername(username);
    return user != null && user.password == password;
  }

  ValueListenable<Box<User>> listenToUsers() {
    return userBox.listenable();
  }

  ///Category
  List<Task> getTasksByCategory(String categoryId) {
    return taskBox.values.where((task) => task.categoryId == categoryId).toList();
  }
}