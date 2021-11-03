import 'package:mini_bmob/src/table/bmob_table.dart';
import 'package:mini_bmob/src/type/relation.dart';

/// 接口返回的列表对象
class ResponseList<T extends BmobTable> {
  late List<T> results;
  late int count;

  ResponseList._();

  ResponseList.empty() {
    results = [];
    count = 0;
  }

  ResponseList.fromJson(Map<String, dynamic> json, JsonToTable<T> jsonToTable) {
    results = [];
    List _results = json['results'] ?? [];
    for (var element in _results) {
      T object = jsonToTable(element);
      results.add(object);
    }
    count = json['count'] ?? 0;
  }
}
