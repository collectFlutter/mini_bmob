import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_bmob/src/helper/query_helper.dart';
import 'package:mini_bmob/src/table/bmob_table.dart';

class Batch {
  final List<Map<String, dynamic>> _requests = [];

  List<Map<String, dynamic>> get request => _requests;

  Batch();

  Batch create<T extends BmobTable>(T table) {
    _requests.add({
      "method": "POST",
      "path": "/1/classes/${table.getBmobTabName()}",
      "body": table.createJson()
    });
    return this;
  }

  Batch createAll<T extends BmobTable>(List<T> tables) {
    for (var table in tables) {
      create(table);
    }
    return this;
  }

  Batch update<T extends BmobTable>(T table, {Map<String, dynamic>? body}) {
    assert(table.objectId != null);
    _requests.add({
      "method": "PUT",
      if (BmobConfig.config.sessionToken != null) ...{
        'token': BmobConfig.config.sessionToken,
      },
      "path": "/1/classes/${table.getBmobTabName()}/${table.objectId}",
      "body": body ?? table.createJson()
    });
    return this;
  }

  Batch updateAll<T extends BmobTable>(List<T> tables,
      {Map<String, dynamic>? body}) {
    for (var table in tables) {
      update(table, body: body);
    }
    return this;
  }

  Batch delete<T extends BmobTable>(T table) {
    assert(table.objectId != null);
    _requests.add({
      "method": "DELETE",
      if (BmobConfig.config.sessionToken != null) ...{
        'token': BmobConfig.config.sessionToken,
      },
      "path": "/1/classes/${table.getBmobTabName()}/${table.objectId}",
    });
    return this;
  }

  Batch deleteAll<T extends BmobTable>(List<T> tables) {
    for (var table in tables) {
      delete(table);
    }
    return this;
  }

  /// 批量操作的上限为50个，会分组进行上传
  Future<List> post() => QueryHelper.batch(this);
}
