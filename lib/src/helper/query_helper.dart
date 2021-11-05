import 'where_builder.dart';
import '../type/relation.dart';

import '../helper/net_helper.dart';
import '../type/batch.dart';
import '../type/response_list.dart';

import '../table/_table.dart';

class BmobQueryHelper {
  /// 适用于聚合查询，返回非表格字段
  static Future<List<O>> query<T extends BmobTable, O>(
      T table, JsonToObject<O> jsonToObject,
      {BmobWhereBuilder? where}) async {
    var data = await BmobNetHelper.init().get(
      '/1/classes/${table.getBmobTabName()}',
      body: where?.builder(),
    );
    if (data == null || !data.containsKey('results')) {
      return [];
    }
    List list = data['results'];
    return list.map((e) => jsonToObject(e)).toList();
  }

  /// 数据列表查询
  static Future<BmobSetResponse<T>> list<T extends BmobTable>(
    T table,
    JsonToTable<T> jsonToTable, {
    BmobWhereBuilder? where,
  }) async {
    var data = await BmobNetHelper.init().get(
      '/1/classes/${table.getBmobTabName()}',
      body: where?.builder(),
    );
    if (data == null || !data.containsKey('results')) {
      return BmobSetResponse<T>.empty();
    }
    return BmobSetResponse<T>.fromJson(data, jsonToTable);
  }

  /// 查询列表
  static Future<List<Map<String, dynamic>>> bql(
      {required String bql, List? values}) async {
    var data = await BmobNetHelper.init().get(
      '/1/cloudQuery',
      body: {
        'bql': bql,
        if (values != null) ...{'values': values}
      },
    );
    return data?['results'] ?? [];
  }

  /// 批量操作的上限为50个，会分组进行上传
  static Future<List> batch(BmobBatch batch) async {
    List _list = [];
    var list = batch.request;
    int quotient = list.length ~/ 50;
    for (int i = 0; i < quotient; i++) {
      _list.addAll(await _batch(list.sublist(i * 50, i * 50 + 50)));
    }
    int remainder = list.length % 50;
    if (remainder > 0) {
      _list.addAll(await _batch(list.sublist(list.length - remainder)));
    }
    return _list;
  }

  static Future<List> _batch(List<Map<String, dynamic>> request) async {
    assert(request.length < 51);
    var data = await BmobNetHelper.init()
        .post('/1/batch', body: {'requests': request});
    return data ?? [];
  }
}
