class SavedConversion {
  SavedConversion({
    required this.id,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.convertedAmount,
    required this.createdAtIso,
  });

  final String id;
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;
  final String createdAtIso;

  factory SavedConversion.fromJson(Map<String, dynamic> json) {
    return SavedConversion(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      fromCurrency: json['fromCurrency'].toString(),
      toCurrency: json['toCurrency'].toString(),
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
      createdAtIso: json['createdAtIso'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'convertedAmount': convertedAmount,
      'createdAtIso': createdAtIso,
    };
  }

  SavedConversion copyWith({
    String? id,
    double? amount,
    String? fromCurrency,
    String? toCurrency,
    double? convertedAmount,
    String? createdAtIso,
  }) {
    return SavedConversion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      createdAtIso: createdAtIso ?? this.createdAtIso,
    );
  }
}
