import 'package:flutter/material.dart';
import 'package:hostel_expense_tracker/widgets/expense_screen.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromRGBO(24, 119, 242, 1),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: kColorScheme,
        // AppBar Theme
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        // Card Theme
        cardTheme: const CardTheme().copyWith(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          color: const Color.fromARGB(255, 237, 247, 255),
        ),
        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primary,
            foregroundColor: kColorScheme.onPrimary,
          ),
        ),
      ),
      // Dark Theme
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        // Card Theme Dark
        cardTheme: const CardTheme().copyWith(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          color: kDarkColorScheme.primaryContainer,
        ),
        // Elevated Button Theme Dark
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.primaryContainer,
            foregroundColor: kDarkColorScheme.onPrimaryContainer,
          ),
        ),
        // Text Theme Dark
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: kColorScheme.secondaryContainer,
          ),
        ),
      ),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpenseScreen();
  }
}