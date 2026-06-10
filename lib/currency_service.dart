// lib/services/currency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiKey = 'YOUR_API_KEY'; // Get from exchangerate-api.com
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/';

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl$baseCurrency'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['rates'];
    }
    throw Exception('Failed to load exchange rates');
  }
}