import 'package:mini_bmob/src/type/date_time.dart';

class BmobArray<T> {
  List<T> list = [];

  BmobArray([this.list = const []]);

  Map<String, dynamic> createJson() => {
        "__op": "Add",
        "objects": [
          for (var item in list)
            item is DateTime ? BmobDateTime(item).toJson() : item
        ],
      };

  Map<String, dynamic> updateJson() => {
        "__op": "AddUnique",
        "objects": [
          for (var item in list)
            item is DateTime ? BmobDateTime(item).toJson() : item
        ],
      };

  Map<String, dynamic> removeJson() => {
        "__op": "Remove",
        "objects": [
          for (var item in list)
            item is DateTime ? BmobDateTime(item).toJson() : item
        ],
      };
}
