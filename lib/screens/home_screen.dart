import 'package:flutter/material.dart';

import '../models/saved_conversion.dart';
import '../services/saved_conversion_storage.dart';
import 'converter_screen.dart';
import 'rates_screen.dart';
import 'saved_conversions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = SavedConversionStorage();

  int _selectedIndex = 0;
  int _savedScreenVersion = 0;

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleSavedConversion(SavedConversion conversion) async {
    await _storage.add(conversion);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = 2;
      _savedScreenVersion++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${conversion.fromCurrency} to ${conversion.toCurrency} saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ConverterScreen(onSave: _handleSavedConversion),
      const RatesScreen(),
      SavedConversionsScreen(version: _savedScreenVersion),
    ];

    final titles = ['Converter', 'Live Rates', 'Saved Conversions'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: screens[_selectedIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToTab(0),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Convert'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange),
            label: 'Convert',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats),
            label: 'Rates',
          ),
          NavigationDestination(
            icon: Icon(Icons.save_alt),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
