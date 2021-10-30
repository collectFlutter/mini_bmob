import 'package:mini_bmob/src/bmon_net_helper.dart';

abstract class BmobTable {
  /// 数据表名称
  String getBmobTabName();

  String? createdAt;
  String? updatedAt;
  String? objectId;

  Map<String, dynamic> createJson();

  BmobTable();

  void fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = json['createAt'];
    updatedAt = json['updateAt'];
  }

  /// 插入一条新记录
  Future<bool> install() async {
    var data = await BmobNetHelper.init()
        .post('/1/classes/${getBmobTabName()}', body: createJson());
    if (data != null &&
        data.containsKey('createdAt') &&
        data.containsKey('objectId')) {
      createdAt = data['createdAt'];
      objectId = data['objectId'];
      return true;
    }
    return false;
  }

  /// 更新某条记录
  Future<bool> update([Map<String, dynamic>? body]) async {
    if (objectId == null) throw Exception('objectId is null');
    var data = await BmobNetHelper.init().put(
        '/1/classes/${getBmobTabName()}/$objectId',
        body: body ?? createJson());
    if (data != null && data.containsKey('updatedAt')) {
      updatedAt = data['updatedAt'];
      return true;
    }
    return false;
  }

  /// 获取记录详情
  Future<bool> getInfo({List<String> include = const []}) async {
    if (objectId == null) throw Exception('objectId is null');
    Map<String, String>? body;
    if (include.isNotEmpty) {
      body = {"include": include.join(',')};
    }
    var data = await BmobNetHelper.init()
        .get("/1/classes/${getBmobTabName()}/$objectId", body: body);
    if (data != null && data.containsKey('objectId')) {
      fromJson(data);
      return true;
    }
    return false;
  }

  /// 删除某条记录
  Future<bool> delete() async {
    if (objectId == null) throw Exception('objectId is null');
    var data = await BmobNetHelper.init()
        .delete('/1/classes/${getBmobTabName()}/$objectId');
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 删除某些字段内容
  Future<bool> deleteFieldValue(List<String> field) async {
    if (objectId == null) throw Exception('objectId is null');

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
