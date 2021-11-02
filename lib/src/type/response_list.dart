import 'package:mini_bmob/src/table/bmob_table.dart';
import 'package:mini_bmob/src/type/relation.dart';

/// 接口返回的列表对象
class ResponseList<T extends BmobTable> {
  late List<T> results;
  late int count;
  late JsonToTable<T> jsonToTable;

  ResponseList._();

  ResponseList.empty() {
    results = [];
    count = 0;
  }

  ResponseList.fromJson(Map<String, dynamic> json, JsonToTable<T> jsonToTable) {
    results = (json['results'] ?? []).map((e) => jsonToTable(e)).toList();
    count = json[''] ?? 0;
  }
}
