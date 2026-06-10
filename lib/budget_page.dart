import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  // Simulating a basic budget and expenses list
  double totalBudget = 1000.0;  // Total budget
  List<Map<String, dynamic>> expenses = [
    {'name': 'Groceries', 'amount': 50.0},
    {'name': 'Utilities', 'amount': 100.0},
    {'name': 'Transportation', 'amount': 30.0},
  ];

  // Method to add a new expense
  void _addExpense(String name, double amount) {
    setState(() {
      expenses.add({'name': name, 'amount': amount});
    });
  }

  // Method to calculate total expenses
  double _calculateTotalExpenses() {
    double total = 0.0;
    for (var expense in expenses) {
      total += expense['amount'];
    }
    return total;
  }

  // Method to show the expense addition dialog
  void _showAddExpenseDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Expense'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Expense Name'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle adding expense
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  _addExpense(nameController.text,
                      double.parse(amountController.text));
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = _calculateTotalExpenses();
    double remainingBudget = totalBudget - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Budget Section
            Text(
              'Total Budget: \$${totalBudget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            Divider(),

            // Expense List
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(expenses[index]['name']),
                    subtitle: Text(
                        '\$${expenses[index]['amount'].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),

            // Add Expense Button
            ElevatedButton(
              onPressed: _showAddExpenseDialog,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
