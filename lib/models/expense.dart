import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

enum Category {
  travel,
  rent,
  breakfast,
  mess,
  fastfood,
  prints,
  shopping,
  cigrattes,
  gym,
  others
}

const categoryIcons = {
  Category.travel: Icons.airport_shuttle,
  Category.rent: Icons.house,
  Category.mess: Icons.dinner_dining,
  Category.prints: Icons.print,
  Category.shopping: Icons.shopping_cart,
  Category.cigrattes: Icons.smoking_rooms,
  Category.gym: Icons.fitness_center,
  Category.fastfood: Icons.fastfood,
  Category.breakfast: Icons.dining,
  Category.others: Icons.search,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = uuid.v4();
  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;

  String get formattedDate => formatter.format(date);
}

class ExpenseBucket {
  ExpenseBucket({
    required this.category,
    required this.expenses,
  });
  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();
  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
