import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_bmob/src/helper/bmon_net_helper.dart';
import 'package:mini_bmob/src/type/batch.dart';
import 'package:mini_bmob/src/type/response_list.dart';

import '../table/bmob_table.dart';

class QueryHelper {
  /// 查询列表
  static Future<ResponseList<T>> list<T extends BmobTable>(
    T table,
    JsonToTable<T> jsonToTable, {
    WhereBuilder? where,
  }) async {
    var data = await BmobNetHelper.init().get(
      '/1/classes/${table.getBmobTabName()}',
      body: where?.builder(),
    );
    if (data == null || !data.containsKey('results')) {
      return ResponseList.empty();
    }
    return ResponseList.fromJson(data, jsonToTable);
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

  /// 批量操作
  static Future batch(Batch batch) async {
    /// 批量操作的上限为50个，所以要做分组
    var list = batch.request;
    int quotient = list.length ~/ 50;
    for (int i = 0; i < quotient; i++) {
      await _batch(list.sublist(i * 50, i * 50 + 50));
    }
    int remainder = list.length % 50;
    if (remainder > 0) {
      await _batch(list.sublist(list.length - remainder));
    }
  }

  static Future<dynamic> _batch(List<Map<String, dynamic>> request) async {
    assert(request.length < 51);
    var data = await BmobNetHelper.init()
        .post('/1/batch', body: {'requests': request});
    return data ?? [];
  }
}
