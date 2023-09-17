import 'TODO.dart';
import 'notes.dart';
import 'mainscreen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static const String todo = '/';
  static const String NotesPage = '/notes';
  static const String draft = '/draft';

  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case draft:
        return MaterialPageRoute(
          builder: (_) => const Todo(),
        );
      case todo:
        return MaterialPageRoute(
          builder: (_) => const mainScreen(),
        );

      case NotesPage:
        return MaterialPageRoute(
          builder: (_) => const Notes(),
        );

      default:
        throw const FormatException("Route not found");
    }
  }
}

class RouteException implements Exception {
  final String message;
  const RouteException(this.message);
}
