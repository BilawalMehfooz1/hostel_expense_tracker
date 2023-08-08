import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hostel_expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});
  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.breakfast;
  var _isSending = false;

  // Displays Date Picker
  void _showDateOverlay() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // Displays Error Messages if any one Input fields is empty While Adding Expense Item
  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            title: const Text('Invalid Input'),
            content: const Text(
              'Please make sure a valid title, amount, date and category was entered.',
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            title: const Text('Invalid Input'),
            content: const Text(
                'Please make sure a valid title, amount, date and category was entered.'),
          );
        },
      );
    }
  }

  // Submitting Expense Method
  void _submitExpense() async {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }
    setState(() {
      _isSending = true;
    });
    // Sending Post Request to DataBase for saving expense item
    final url = Uri.https(
      'hostel-expense-tracker-default-rtdb.firebaseio.com',
      'expense-list.json',
    );
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'amount': enteredAmount,
          'category': _selectedCategory.name,
          'date': _selectedDate!.toIso8601String(),
        }));

    final Map<String, dynamic> resData = json.decode(response.body);

    if (context.mounted) {
      final newExpense = Expense(
        id: resData['name'],
        title: _titleController.text,
        amount: enteredAmount,
        category: _selectedCategory,
        date: _selectedDate!,
      );

      // sends data back to expense screen after submitting expense
  
      Navigator.of(context).pop(newExpense);
    }
    return;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Title', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text(
                              'Amount',
                              style: TextStyle(fontSize: 16),
                            ),
                            prefixText: 'Rs. ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'No Date Selected'
                                : formatter.format(_selectedDate!),
                          ),
                          IconButton(
                            onPressed: _showDateOverlay,
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DropdownButton(
                        value: _selectedCategory,
                        items: Category.values
                            .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase())))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(
                            () {
                              _selectedCategory = value;
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: _isSending
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: _isSending ? null : _submitExpense,
                          child: _isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Save Expense')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
