import 'package:flutter/material.dart';
import '../services/storage_services.dart';

class ItemProvider with ChangeNotifier {
  final StorageServices _storage = StorageServices();

  List<String> _items = [];
  List<String> get items => _items;

  void loadItems() {
    _items = _storage.getitems();
    notifyListeners();
  }

  void addItem(String item) {
    _items.add(item);
    _storage.saveitems(_items);
    notifyListeners();
  }

  void removeItem(String item) {
    _items.remove(item);
    _storage.saveitems(_items);
    notifyListeners();
  }
}
