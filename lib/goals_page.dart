import 'package:flutter/material.dart';
import '../helper/db_helper.dart';
import '../models/goals_model.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<GoalModel> _goals = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _dbHelper.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _addGoal() async {
    final title = _titleController.text.trim();
    final targetAmount = double.tryParse(_amountController.text.trim());

    if (title.isNotEmpty && targetAmount != null) {
      final newGoal = GoalModel(
        title: title,
        targetAmount: targetAmount,
        currentAmount: 0.0,
      );
      await _dbHelper.insertGoal(newGoal);
      _titleController.clear();
      _amountController.clear();
      Navigator.of(context).pop();
      _loadGoals();
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Goal Title'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addGoal,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(GoalModel goal) {
    double progress = goal.currentAmount / goal.targetAmount;
    progress = progress.clamp(0.0, 1.0); // Prevent overflow

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${goal.currentAmount.toStringAsFixed(2)} ₸ / ${goal.targetAmount.toStringAsFixed(2)} ₸',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: const [Icon(Icons.flag)],
      ),
      body: _goals.isEmpty
          ? const Center(child: Text('No goals yet. Add one!'))
          : ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          return _buildGoalItem(_goals[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
