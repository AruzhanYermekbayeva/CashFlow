import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/transactions_model.dart';
import '../helper/database_service.dart';
import 'package:cashflow/currency_service.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final CurrencyService _currencyService = CurrencyService();
  Map<String, double> _exchangeRates = {};
  String _baseCurrency = 'USD';

  List<TransactionModel> get transactions => _transactions;
  Map<String, double> get exchangeRates => _exchangeRates;
  String get baseCurrency => _baseCurrency;

  TransactionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await DatabaseService.init();
    await fetchTransactions();
    await fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    try {
      final rates = await _currencyService.getExchangeRates(_baseCurrency);
      _exchangeRates = Map<String, double>.from(rates);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
    }
  }

  Future<void> setBaseCurrency(String currency) async {
    _baseCurrency = currency;
    await fetchExchangeRates();
  }

  double convertAmount(double amount, String targetCurrency) {
    if (_exchangeRates.isEmpty) return amount;
    return amount * (_exchangeRates[targetCurrency] ?? 1.0);
  }

  Future<void> fetchTransactions() async {
    try {
      final maps = await DatabaseService.getTransactions();
      _transactions.clear();
      _transactions.addAll(
          maps.map((map) => TransactionModel.fromMap(map)).toList()
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await DatabaseService.insertTransaction(transaction.toMap());
      _transactions.add(transaction.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await DatabaseService.updateTransaction(transaction.toMap());
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }
}