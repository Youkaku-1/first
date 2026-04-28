class RateDetailArgs {
  RateDetailArgs({
    required this.baseCode,
    required this.targetCode,
    required this.rate,
    required this.updatedAt,
  });

  final String baseCode;
  final String targetCode;
  final double rate;
  final String updatedAt;
}
