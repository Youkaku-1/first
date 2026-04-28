import 'package:flutter/material.dart';

import '../models/rate_detail_args.dart';

class RateDetailScreen extends StatelessWidget {
  const RateDetailScreen({super.key, required this.args});

  static const routeName = '/rate-detail';

  final RateDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${args.baseCode} to ${args.targetCode}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        args.targetCode,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1 ${args.baseCode} = ${args.rate.toStringAsFixed(4)} ${args.targetCode}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text('Last updated: ${args.updatedAt}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'This detail page exists to demonstrate argument passing between routes, which is one of the course requirements.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
