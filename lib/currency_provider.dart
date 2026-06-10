// lib/providers/currency_provider.dart
import 'package:flutter/material.dart';
import 'currency_service.dart'; // Add this import

class CurrencyProvider with ChangeNotifier {
  final CurrencyService _service = CurrencyService();
  Map<String, double> _rates = {};
  String _baseCurrency = 'USD';

  Map<String, double> get rates => _rates;
  String get baseCurrency => _baseCurrency;

  Future<void> fetchRates() async {
    try {
      final rates = await _service.getExchangeRates(_baseCurrency);
      _rates = rates.map((k, v) => MapEntry(k, v.toDouble()));
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      rethrow;
    }
  }

  void setBaseCurrency(String currency) {
    _baseCurrency = currency;
    fetchRates();
  }

  double convert(double amount, String targetCurrency) {
    if (_rates.isEmpty) return amount;
    return amount * (_rates[targetCurrency] ?? 1.0);
  }
}