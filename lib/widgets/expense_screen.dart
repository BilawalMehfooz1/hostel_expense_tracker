import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
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
  var _isLoading = true;
  String? _error;

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
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
      }

      if (response.body == 'null'||response.body=='{}') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
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
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
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
      _error = null; //resets error when a new item is added
    });
  }

  // Remove Expense Method
  void _removeExpense(Expense expense) async {
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
          onPressed: () async {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );

    // wait for 3 seconds and then delete the item from the backend
    await Future.delayed(const Duration(seconds: 3));

    // if the expense is still removed (i.e., user did not press Undo), then delete from backend
    if (!_registeredExpenses.contains(expense)) {
      final url = Uri.https(
        'hostel-expense-tracker-default-rtdb.firebaseio.com',
        'expense-list/${expense.id}.json',
      );
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deletion failed!'),
            ),
          );
          setState(() {
            _registeredExpenses.insert(expenseIndex, expense);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expense found. Start adding some!'),
    );

    if (_isLoading == true) {
      mainContent = const Center(
        child: CircularProgressIndicator(),
      );
    }
    // Connected With expense_list file
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpenseList(
          expenses: _registeredExpenses, onRemoveExpense: _removeExpense);
    }
    // Checking if anything goes wrong while sending post request to database
    if (_error != null) {
      mainContent = Center(
        child: Text(_error!),
      );
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
