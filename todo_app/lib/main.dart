import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/firebase_options.dart';
import 'mainscreen.dart';
import 'user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final todoList = TodoList(prefs);
  runApp(
    ChangeNotifierProvider(
      create: (context) => todoList,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: auth(),
      ),
    ),
  );
}
