import 'package:flutter/material.dart';

import '../models/rate_detail_args.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class RateDetailScreen extends StatelessWidget {
  const RateDetailScreen({super.key, required this.args});

  static const routeName = '/rate-detail';

  final RateDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${args.baseCode} â†’ ${args.targetCode}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GlassCard(
                dark: true,
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exchange rate',
                      style: TextStyle(
                        color: AppTheme.lime,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '1 ${args.baseCode}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${args.rate.toStringAsFixed(5)} ${args.targetCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppTheme.cyan,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Updated: ${args.updatedAt}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.76),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick examples',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ExampleRow(
                      amount: 10,
                      code: args.targetCode,
                      result: 10 * args.rate,
                    ),
                    _ExampleRow(
                      amount: 50,
                      code: args.targetCode,
                      result: 50 * args.rate,
                    ),
                    _ExampleRow(
                      amount: 100,
                      code: args.targetCode,
                      result: 100 * args.rate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.amount,
    required this.code,
    required this.result,
  });

  final int amount;
  final String code;
  final double result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$amount USD',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '${result.toStringAsFixed(2)} $code',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTheme.violet,
            ),
          ),
        ],
      ),
    );
  }
}
