import 'package:flutter/material.dart';

import '../models/currency_rates.dart';
import '../models/rate_detail_args.dart';
import '../services/currency_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'rate_detail_screen.dart';

class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  final _apiService = CurrencyApiService();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  CurrencyRates? _rates;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rates = await _apiService.fetchLatestRates('USD');
      if (!mounted) return;
      setState(() => _rates = rates);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rates = _rates;
    final query = _searchController.text.trim().toUpperCase();
    final entries =
        rates?.rates.entries
            .where((entry) => entry.key.contains(query))
            .toList() ??
        [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppTheme.violet,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Market board',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Base: ${rates?.baseCode ?? 'USD'} â€¢ Updated: ${rates?.timeLastUpdateUtc ?? 'loading'}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _loadRates,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search currency code, for example EGP, EUR, USD',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(44),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.danger,
                  size: 42,
                ),
                const SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadRates,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else
          ...entries.map((entry) {
            final currentRates = rates!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RateDetailScreen.routeName,
                    arguments: RateDetailArgs(
                      baseCode: currentRates.baseCode,
                      targetCode: entry.key,
                      rate: entry.value,
                      updatedAt: currentRates.timeLastUpdateUtc,
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                tileColor: Colors.white.withValues(alpha: 0.88),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.bgDark,
                  child: Text(
                    entry.key.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '1 ${currentRates.baseCode} = ${entry.value.toStringAsFixed(4)} ${entry.key}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            );
          }),
      ],
    );
  }
}
