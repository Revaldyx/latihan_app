import 'package:hive/hive.dart';

class StorageServices {
  final Box box = Hive.box('myBox');

  List<String> getitems() {
    return box.get('items', defaultValue: []).cast<String>();
  }

  void saveitems(List<String> items) {
    box.put('items', items);
  }
}
