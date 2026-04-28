class CurrencyRates {
  CurrencyRates({
    required this.baseCode,
    required this.timeLastUpdateUtc,
    required this.rates,
  });

  final String baseCode;
  final String timeLastUpdateUtc;
  final Map<String, double> rates;

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final rawRates =
        (json['conversion_rates'] ?? json['rates']) as Map<String, dynamic>? ?? {};

    return CurrencyRates(
      baseCode: (json['base_code'] ?? 'USD').toString(),
      timeLastUpdateUtc: (json['time_last_update_utc'] ?? 'Unknown').toString(),
      rates: rawRates.map(
        (key, value) => MapEntry(
          key,
          (value as num).toDouble(),
        ),
      ),
    );
  }

  List<String> sortedCodes() {
    final codes = rates.keys.toList()..sort();
    return codes;
  }
}
