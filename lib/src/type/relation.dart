import 'dart:convert';

import '../table/_table.dart';
import '../type/pointer.dart';

import '../helper/net_helper.dart';

typedef JsonToObject<T> = T Function(Map<String, dynamic> json);

typedef JsonToTable<T extends BmobTable> = T Function(
    Map<String, dynamic> json);

class BmobRelation<T extends BmobTable, S extends BmobTable> {
  /// 列表内容
  List<S> list = [];

  /// 主对象
  late T object;

  /// 列表对象
  late S subset;

  /// json 转换 对象
  late JsonToTable<S> jsonToTable;

  /// 关联的key
  String key;

  BmobRelation(this.object, this.subset, this.key, this.jsonToTable,
      [this.list = const []]);

  Map<String, dynamic> createJson([List<S>? list]) => {
        "__op": "AddRelation",
        "objects":
            (list ?? this.list).map((e) => BmobPointer(e).createJson()).toList()
      };

  Map<String, dynamic> _removeJson([List<S>? list]) => {
        "__op": "RemoveRelation",
        "objects":
            (list ?? this.list).map((e) => BmobPointer(e).createJson()).toList()
      };

  Future<bool> include() async {
    if (object.objectId == null) throw Exception('objectId is null');
    var data = await BmobNetHelper.init().get(
      '/1/classes/${subset.getBmobTabName()}',
      body: {
        "where": jsonEncode({
          "\$relatedTo": {
            "object": {
              "__type": "Pointer",
              "className": object.getBmobTabName(),
              "objectId": object.objectId,
            },
            "key": key,
          }
        })
      },
    );
    if (data != null && data.containsKey('results')) {
      List _list = data['results'];
      list = _list.map((e) => jsonToTable(e)).toList();
      return true;
    }
    list = [];
    return false;
  }

  /// 添加关联对象
  Future<bool> add([List<S> list = const []]) async {
    if (object.objectId == null) throw Exception('objectId is null');
    if (list.isEmpty) return true;
    var data = await BmobNetHelper.init().put(
      '/1/classes/${object.getBmobTabName()}/${object.objectId}',
      body: {key: createJson(list)},
    );
    if (data != null && data.containsKey('updatedAt')) {
      var _list = list
          .where((e1) => !this.list.any((e2) => e1.objectId == e2.objectId));
      if (_list.isNotEmpty) {
        this.list.addAll(_list);
      }
      return true;
    }
    return false;
  }

  /// 移除关联对象
  Future<bool> remove([List<S> list = const []]) async {
    if (object.objectId == null) throw Exception('objectId is null');
    if (list.isEmpty) return true;
    var data = await BmobNetHelper.init().put(
      '/1/classes/${object.getBmobTabName()}/${object.objectId}',
      body: {key: _removeJson(list)},
    );
    if (data != null && data.containsKey('updatedAt')) {
      this
          .list
          .removeWhere((e1) => list.any((e2) => e1.objectId == e2.objectId));
      return true;
    }
    return false;
  }

  /// 清空关联对象
  Future<bool> clear() async {
    if (object.objectId == null) throw Exception('objectId is null');
    if (list.isEmpty) return true;
    var data = await BmobNetHelper.init().put(
      '/1/classes/${object.getBmobTabName()}/${object.objectId}',
      body: {key: _removeJson(list)},
    );
    if (data != null && data.containsKey('updatedAt')) {
      list.clear();
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> toJson() => list.map((e) => e.toJson()).toList();
}
