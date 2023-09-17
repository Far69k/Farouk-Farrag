import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mainscreen.dart';
import 'user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final todoList = TodoList(prefs);
  runApp(
    ChangeNotifierProvider(
      create: (context) => todoList,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: mainScreen(),
      ),
    ),
  );
}
