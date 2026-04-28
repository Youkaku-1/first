*import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_conversion.dart';

class SavedConversionStorage {
  static const _storageKey = 'saved_conversions';

  Future<List<SavedConversion>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final savedItems = decoded
        .map((item) => SavedConversion.fromJson(item as Map<String, dynamic>))
        .toList();
    savedItems.sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
    return savedItems;
  }

  Future<void> add(SavedConversion item) async {
    final items = await getAll();
    items.add(item);
    await _write(items);
  }

  Future<void> update(SavedConversion updatedItem) async {
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index == -1) {
      return;
    }

    items[index] = updatedItem;
    await _write(items);
  }

  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await _write(items);
  }

  Future<void> _write(List<SavedConversion> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
