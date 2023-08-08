import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hostel_expense_tracker/models/expense.dart';
import 'package:hostel_expense_tracker/widgets/chart/chart.dart';
import 'package:hostel_expense_tracker/widgets/expenses_data/expense_list.dart';
import 'package:hostel_expense_tracker/widgets/expenses_data/new_expense.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Expense List where the new expense items will be stored
  List<Expense> _registeredExpenses = [];

  // To Load Expense Items on the Screen when we open app
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Gets Data from the database
  void _loadItems() async {
    final url = Uri.https(
      'hostel-expense-tracker-default-rtdb.firebaseio.com',
      'expense-list.json',
    );

    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<Expense> loadedItems = [];

    // Converting Map of Expense item to list
    for (final item in listData.entries) {
      final category = Category.values.firstWhere(
        (catItem) => catItem.name == item.value['category'],
      );
      loadedItems.add(
        Expense(
          title: item.value['title'],
          amount: item.value['amount'],
          category: category,
          date: DateTime.parse(item.value['date']),
        ),
      );
    }
    // For updating UI each time new expense is added
    setState(() {
      _registeredExpenses = loadedItems;
    });
  }

  // Shows a ModalBottomSheet when we press the add button in AppBar
  void _showAddExpenseOverlay() async {
    final newItem = await showModalBottomSheet(
      useSafeArea: true, //for basice device settings like camera
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return const NewExpense(); //connected with NewExpense file
      },
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _registeredExpenses.add(newItem);
    });
  }

  // Remove Expense Method
  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense Deleted'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expense found. Start adding some!'),
    );

    // Connected With expense_list file
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpenseList(
          expenses: _registeredExpenses, onRemoveExpense: _removeExpense);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _showAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                Expanded(
                  child: mainContent,
                )
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  child: mainContent,
                )
              ],
            ),
    );
  }
}
