import 'package:flutter/material.dart';

import '../models/saved_conversion.dart';
import '../services/saved_conversion_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

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
    if (oldWidget.version != widget.version) _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _storage.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(SavedConversion item) async {
    await _storage.delete(item.id);
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.bookmarks_rounded,
                  color: AppTheme.violet,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved conversions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Stored locally on this device.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            ],
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
        else if (_items.isEmpty)
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: AppTheme.muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No saved conversions yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Convert a currency and press save to see it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
                ),
              ],
            ),
          )
        else
          ..._items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => _deleteItem(item),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.bgDark,
                        child: Text(
                          item.fromCurrency.characters.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.amount.toStringAsFixed(2)} ${item.fromCurrency} â†’ ${item.convertedAmount.toStringAsFixed(2)} ${item.toCurrency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saved on ${item.createdAtIso.substring(0, 10)}',
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
