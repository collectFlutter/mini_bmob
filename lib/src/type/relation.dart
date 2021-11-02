import 'dart:convert';

import 'package:mini_bmob/src/table/bmob_table.dart';
import 'package:mini_bmob/src/type/pointer.dart';

import '../helper/bmon_net_helper.dart';

typedef JsonToTable<T extends BmobTable> = T Function(
    Map<String, dynamic> json);

class Relation<T extends BmobTable, S extends BmobTable> {
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

  Relation(this.object, this.subset, this.key, this.jsonToTable,
      [this.list = const []]);

  Map<String, dynamic> createJson() => {
        "__op": "AddRelation",
        "objects": list.map((e) => Pointer(e).createJson()).toList()
      };

  Map<String, dynamic> toRemove() => {
        "__op": "RemoveRelation",
        "objects": list.map((e) => Pointer(e).createJson()).toList()
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

  List<Map<String, dynamic>> toJson() => list.map((e) => e.toJson()).toList();
}
