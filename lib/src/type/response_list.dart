import '../table/_table.dart';
import '../type/relation.dart';

/// 集合返回结果集
class BmobSetResponse<T> {
  late List<T> results;
  late int count;

  BmobSetResponse._();

  BmobSetResponse.empty() {
    results = [];
    count = 0;
  }

  BmobSetResponse.fromJson(
      Map<String, dynamic> json, JsonToObject<T> jsonToObject) {
    results = [];
    List _results = json['results'] ?? [];
    for (var element in _results) {
      T object = jsonToObject(element);
      results.add(object);
    }
    count = json['count'] ?? 0;
  }
}
