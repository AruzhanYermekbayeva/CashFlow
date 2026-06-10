import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      ExpenseData('Income', 5000),
      ExpenseData('Expenses', 3000),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Total Income'),
                          const SizedBox(height: 8),
                          const Text('\$5000', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.red[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Total Expenses'),
                          const SizedBox(height: 8),
                          const Text('\$3000', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Net Balance: \$2000',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),
            // Filter Section
            const Text(
              'Filter by Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Today'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Last Week'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Last Month'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Income vs Expenses Chart using fl_chart
            const Text(
              'Income vs Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _generateChartSections(data),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Detailed Reports Section
            const Text(
              'Expense Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryReport('Rent', 1200),
                _buildCategoryReport('Groceries', 500),
                _buildCategoryReport('Utilities', 200),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to generate PieChart sections
  List<PieChartSectionData> _generateChartSections(List<ExpenseData> data) {
    final total = data.fold(0.0, (sum, item) => sum + item.amount);

    return data.map((e) {
      final percentage = ((e.amount / total) * 100).toStringAsFixed(1);
      final isIncome = e.category == 'Income';
      final color = isIncome ? Colors.green : Colors.red;

      return PieChartSectionData(
        color: color,
        value: e.amount,
        title: '${e.category}\n\$$percentage%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // Helper to build category reports
  Widget _buildCategoryReport(String category, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(category, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ExpenseData {
  final String category;
  final double amount;

  ExpenseData(this.category, this.amount);
}
