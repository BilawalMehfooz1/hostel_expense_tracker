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
  // Shows a ModalBottomSheet when we press the add button in AppBar
  void _showAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true, //for basice device settings like camera
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(
            onAddExpense: _addExpenses); //connected with NewExpense file
      },
    );
  }

  // Expense List where the new expense items will be stored
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Mirpur',
      amount: 450,
      category: Category.travel,
      date: DateTime.now(),
    ),
    Expense(
      title: 'Hostel Rent',
      amount: 3500,
      category: Category.rent,
      date: DateTime.now(),
    ),
  ];

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

  // Add Expense Method
  void _addExpenses(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
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
