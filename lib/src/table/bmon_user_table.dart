import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_bmob/src/table/bmob_table.dart';

import '../helper/bmon_net_helper.dart';

class BmobUserTable extends BmobTable {
  String? sessionToken;
  String? username;
  String? password;
  String? email;
  String? mobilePhoneNumber;

  BmobUserTable({
    this.username,
    this.password,
    this.email,
    this.mobilePhoneNumber,
  });

  @override
  String getBmobTabName() => "_User";

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    username = json['username'];
    password = json['password'];
    email = json['email'];
    mobilePhoneNumber = json['mobilePhoneNumber'];
  }

  @override
  Map<String, dynamic> createJson() => {
        "username": username,
        "password": password,
        "email": email,
        "mobilePhoneNumber": mobilePhoneNumber,
      };

  /// 注册
  @override
  Future<bool> install() async {
    var data = await BmobNetHelper.init().post('/1/users', body: createJson());
    if (data != null &&
        data.containsKey('createdAt') &&
        data.containsKey('objectId')) {
      createdAt = data['createdAt'];
      updatedAt = data['createdAt'];
      objectId = data['objectId'];
      sessionToken = data['sessionToken'];
      return true;
    }
    return false;
  }

  /// 登陆,username\email\mobilePhoneNumber都可以
  Future<bool> login() async {
    var body = {
      "username": username ?? email ?? mobilePhoneNumber,
      "password": password
    };
    var data = await BmobNetHelper.init().get('/1/login', body: body);
    if (data != null &&
        data.containsKey('createdAt') &&
        data.containsKey('objectId')) {
      fromJson(data);
      return true;
    }
    return false;
  }

  /// 检查用户的登录是否过期
  Future<bool> checkSession() async {
    if (objectId == null || sessionToken == null) {
      throw Exception('objectId or sessionToken is null');
    }
    var data = await BmobNetHelper.init()
        .get('/1/checkSession/$objectId', session: sessionToken);
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 获取用户信息
  @override
  Future<bool> getInfo({List<String> include = const []}) async {
    if (objectId == null) throw Exception("objectId is null");
    var data = await BmobNetHelper.init().get('/1/users/$objectId');
    if (data != null && data.containsKey('objectId')) {
      fromJson(data);
      return true;
    }
    return false;
  }

  /// 删除自己的账户
  @override
  Future<bool> delete() async {
    if (objectId == null) throw Exception('objectId is null');
    var data = await BmobNetHelper.init()
        .delete('/1/user/$objectId', session: sessionToken);
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 修改密码
  Future<bool> updatePassword(String oldPwd, String newPwd) async {
    if (objectId == null || sessionToken == null) {
      throw Exception('objectId or sessionToken is null');
    }
    var data = await BmobNetHelper.init().put('/1/updateUserPassword/$objectId',
        body: {"oldPassword": oldPwd, "newPassword": newPwd},
        session: sessionToken);
    if (data != null && data.containsKey('msg') && data['msg'] == 'ok') {
      password = newPwd;
      return true;
    }
    return false;
  }

  @override
  Future<bool> update([Map<String, dynamic>? body]) async {
    if (objectId == null) {
      throw Exception('objectId or sessionToken is null');
    }
    var data = await BmobNetHelper.init().put(
      '/1/users/$objectId',
      body: body ?? createJson(),
      session: sessionToken,
    );
    if (data != null && data.containsKey('updatedAt')) {
      updatedAt = data['updatedAt'];
      return true;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'username': username,
        'password': password,
        'email': email,
        'mobilePhoneNumber': mobilePhoneNumber,
        'sessionToken': sessionToken,
      };
}
