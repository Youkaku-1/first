import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency_rates.dart';

class CurrencyApiService {
  static const _apiKey = 'fd1c2443b259f532d2b08232';

  CurrencyApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CurrencyRates> fetchLatestRates(String baseCode) async {
    final normalizedBase = baseCode.toUpperCase();
    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/$normalizedBase',
    );
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load exchange rates (${response.statusCode}).');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['result'] != 'success') {
      final errorType = json['error-type'] ?? 'unknown error';
      throw Exception('API error: $errorType');
    }

    return CurrencyRates.fromJson(json);
  }
}
