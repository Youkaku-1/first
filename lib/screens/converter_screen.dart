import 'package:flutter/material.dart';

import '../models/currency_rates.dart';
import '../models/saved_conversion.dart';
import '../services/currency_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, required this.onSave});

  final Future<void> Function(SavedConversion conversion) onSave;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '1');
  final _apiService = CurrencyApiService();

  CurrencyRates? _currencyRates;
  bool _isLoadingCurrencies = true;
  bool _isConverting = false;
  String? _loadError;
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double? _convertedAmount;

  @override
  void initState() {
    super.initState();
    _loadSupportedCurrencies();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSupportedCurrencies() async {
    setState(() {
      _isLoadingCurrencies = true;
      _loadError = null;
    });

    try {
      final rates = await _apiService.fetchLatestRates('USD');
      final availableCodes = rates.sortedCodes();
      if (!mounted) return;
      setState(() {
        _currencyRates = rates;
        if (!availableCodes.contains(_toCurrency) &&
            availableCodes.isNotEmpty) {
          _toCurrency = availableCodes.first;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingCurrencies = false);
    }
  }

  Future<void> _convertCurrency() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isConverting = true;
      _loadError = null;
    });

    try {
      final rates = await _apiService.fetchLatestRates(_fromCurrency);
      final parsedAmount = double.parse(_amountController.text.trim());
      final rate = rates.rates[_toCurrency];
      if (rate == null) {
        throw Exception('The selected currency is not available right now.');
      }
      if (!mounted) return;
      setState(() => _convertedAmount = parsedAmount * rate);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  Future<void> _saveConversion() async {
    final converted = _convertedAmount;
    if (converted == null) return;

    final item = SavedConversion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text.trim()),
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
      convertedAmount: converted,
      createdAtIso: DateTime.now().toIso8601String(),
    );

    await widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    final rates = _currencyRates;
    final codes = rates?.sortedCodes() ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        GlassCard(
          dark: true,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lime,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LIVE CONVERTER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.bgDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Convert money with a futuristic trading card layout.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rates update from the currency API service.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_isLoadingCurrencies)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_loadError != null && rates == null)
          _ErrorState(message: _loadError!, onRetry: _loadSupportedCurrencies)
        else
          GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payments_rounded),
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid positive amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _CurrencyDropdown(
                          label: 'From',
                          value: _fromCurrency,
                          codes: codes,
                          onChanged: (v) => setState(() => _fromCurrency = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CircleAvatar(
                          backgroundColor: AppTheme.bgDark,
                          child: IconButton(
                            onPressed: () => setState(() {
                              final temp = _fromCurrency;
                              _fromCurrency = _toCurrency;
                              _toCurrency = temp;
                            }),
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _CurrencyDropdown(
                          label: 'To',
                          value: _toCurrency,
                          codes: codes,
                          onChanged: (v) => setState(() => _toCurrency = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isConverting ? null : _convertCurrency,
                      icon: _isConverting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bolt_rounded),
                      label: const Text('Convert Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_convertedAmount != null) ...[
          const SizedBox(height: 18),
          _ResultCard(
            amount: _amountController.text,
            from: _fromCurrency,
            to: _toCurrency,
            convertedAmount: _convertedAmount!,
            onSave: _saveConversion,
          ),
        ],
      ],
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  const _CurrencyDropdown({
    required this.label,
    required this.value,
    required this.codes,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> codes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: codes.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: codes
          .map(
            (code) => DropdownMenuItem(
              value: code,
              child: Text(
                code,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.amount,
    required this.from,
    required this.to,
    required this.convertedAmount,
    required this.onSave,
  });

  final String amount;
  final String from;
  final String to;
  final double convertedAmount;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$amount $from equals',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${convertedAmount.toStringAsFixed(2)} $to',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lime,
              side: const BorderSide(color: AppTheme.lime),
            ),
            icon: const Icon(Icons.bookmark_add_rounded),
            label: const Text('Save this conversion'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 44, color: AppTheme.danger),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
