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

  Batch update<T extends BmobTable>(T table,
      {String? token, Map<String, dynamic>? body}) {
    assert(table.objectId != null);
    _requests.add({
      "method": "PUT",
      if (token != null) ...{
        'token': token,
      },
      "path": "/1/classes/${table.getBmobTabName()}/${table.objectId}",
      "body": body ?? table.createJson()
    });
    return this;
  }

  Batch delete<T extends BmobTable>(T table, {String? token}) {
    assert(table.objectId != null);
    _requests.add({
      "method": "DELETE",
      if (token != null) ...{
        'token': token,
      },
      "path": "/1/classes/${table.getBmobTabName()}/${table.objectId}",
    });
    return this;
  }
}
