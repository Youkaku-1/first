import 'package:flutter/material.dart';

import '../models/currency_rates.dart';
import '../models/rate_detail_args.dart';
import '../services/currency_api_service.dart';
import 'rate_detail_screen.dart';

class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  final _apiService = CurrencyApiService();
  String _baseCode = 'USD';
  late Future<CurrencyRates> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _ratesFuture = _apiService.fetchLatestRates(_baseCode);
  }

  void _reloadRates() {
    setState(() {
      _ratesFuture = _apiService.fetchLatestRates(_baseCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _baseCode,
                        decoration: const InputDecoration(
                          labelText: 'Base currency',
                          prefixIcon: Icon(Icons.flag_circle_outlined),
                        ),
                        items: const ['USD', 'EUR', 'EGP', 'GBP', 'JPY', 'SAR']
                            .map(
                              (code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(code),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _baseCode = value;
                            _ratesFuture = _apiService.fetchLatestRates(_baseCode);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: _reloadRates,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<CurrencyRates>(
            future: _ratesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'Could not load rates.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _reloadRates,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final rates = snapshot.data;
              if (rates == null) {
                return const Center(child: Text('No data available.'));
              }

              final entries = rates.rates.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              if (entries.isEmpty) {
                return const Center(child: Text('No currencies available.'));
              }

              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(entry.key.substring(0, 1))),
                        title: Text(entry.key),
                        subtitle: Text('1 ${rates.baseCode} = ${entry.value.toStringAsFixed(4)} ${entry.key}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RateDetailScreen.routeName,
                            arguments: RateDetailArgs(
                              baseCode: rates.baseCode,
                              targetCode: entry.key,
                              rate: entry.value,
                              updatedAt: rates.timeLastUpdateUtc,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
