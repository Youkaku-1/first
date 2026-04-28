import 'package:flutter/material.dart';

import '../models/saved_conversion.dart';
import '../services/saved_conversion_storage.dart';

class SavedConversionsScreen extends StatefulWidget {
  const SavedConversionsScreen({super.key, required this.version});

  final int version;

  @override
  State<SavedConversionsScreen> createState() => _SavedConversionsScreenState();
}

class _SavedConversionsScreenState extends State<SavedConversionsScreen> {
  final _storage = SavedConversionStorage();
  List<SavedConversion> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant SavedConversionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.version != widget.version) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    final items = await _storage.getAll();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _editItem(SavedConversion item) async {
    final amountController = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<SavedConversion>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit saved conversion'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final newAmount = double.parse(amountController.text.trim());
                final newConvertedAmount = item.convertedAmount * (newAmount / item.amount);

                Navigator.of(context).pop(
                  item.copyWith(
                    amount: newAmount,
                    convertedAmount: newConvertedAmount,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    amountController.dispose();

    if (updated == null) {
      return;
    }

    await _storage.update(updated);
    await _loadItems();
  }

  Future<void> _deleteItem(SavedConversion item) async {
    await _storage.delete(item.id);
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bookmarks_outlined, size: 42),
            SizedBox(height: 12),
            Text('No saved conversions yet.'),
            SizedBox(height: 8),
            Text('Create one from the converter screen to demonstrate CRUD.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.fromCurrency} to ${item.toCurrency}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _editItem(item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _deleteItem(item),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.amount.toStringAsFixed(2)} ${item.fromCurrency} = ${item.convertedAmount.toStringAsFixed(2)} ${item.toCurrency}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saved on ${item.createdAtIso.substring(0, 10)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
