import 'package:mini_bmob/src/bmon_net_helper.dart';

abstract class BmobTable {
  /// 数据表名称
  String getBmobTabName();

  String? createdAt;
  String? updatedAt;
  String? objectId;

  Map<String, dynamic> getBody();

  BmobTable();

  BmobTable.formJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = json['createAt'];
    updatedAt = json['updateAt'];
  }

  Future<bool> install() async {
    var data = await BmobNetHelper.init()
        .post('/1/classes/${getBmobTabName()}', body: getBody());
    if (data != null &&
        data.containsKey('createdAt') &&
        data.containsKey('objectId')) {
      createdAt = data['createdAt'];
      updatedAt = data['createdAt'];
      objectId = data['objectId'];
      return true;
    }
    return false;
  }

  Future<bool> update([Map<String, dynamic>? body]) async {
    var data = await BmobNetHelper.init().put(
        '/1/classes/${getBmobTabName()}/$objectId',
        body: body ?? getBody());
    if (data != null && data.containsKey('updatedAt')) {
      updatedAt = data['updatedAt'];
      return true;
    }
    return false;
  }

  Future<bool> delete() async {
    var data = await BmobNetHelper.init()
        .delete('/1/classes/${getBmobTabName()}/$objectId');
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 删除某些字段内容
  Future<bool> deleteFieldValue(List<String> field) async {
    var body = {
      for (var item in field) item: {"__op": "Delete"}
    };
    var data = await BmobNetHelper.init()
        .put('/1/classes/${getBmobTabName()}/$objectId', body: body);
    if (data != null && data.containsKey('updatedAt')) {
      updatedAt = data['updatedAt'];
      return true;
    }
    return false;
  }

  Map<String, dynamic> dateToJson(DateTime dateTime) => {
        "__type": "Date",
        "iso": dateTime.toIso8601String().replaceAll('T', ' ')
      };

  DateTime? jsonToDate(Map<String, dynamic> json) =>
      DateTime.tryParse(json['iso']);
}
