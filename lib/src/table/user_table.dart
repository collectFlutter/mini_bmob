import '../config.dart';
import '../helper/net_helper.dart';
import '_table.dart';

class BmobUserTable extends BmobTable {
  /// 登陆后，返回的session
  String sessionToken;

  /// 用户名，不可重复
  String? username;

  /// 密码，登陆时必填
  String password;

  /// 邮箱，不可重复
  String? email;

  /// 手机号码，不可重复
  String? mobilePhoneNumber;

  BmobUserTable({
    this.username,
    this.password = '',
    this.email,
    this.mobilePhoneNumber,
    this.sessionToken = '',
  });

  @override
  String getBmobTabName() => "_User";

  @override
  BmobUserTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    username = json['username'];
    if (json.containsKey('password')) {
      password = json['password'];
    }
    email = json['email'];
    mobilePhoneNumber = json['mobilePhoneNumber'];
    if (json.containsKey('sessionToken')) {
      sessionToken = json['sessionToken'];
    }
    return this;
  }

  @override
  Map<String, dynamic> createJson() => {
        ...super.createJson(),
        "username": username,
        if (password.isNotEmpty) ...{
          "password": password,
        },
        if (email != null) ...{
          "email": email,
        },
        if (mobilePhoneNumber != null) ...{
          "mobilePhoneNumber": mobilePhoneNumber,
        },
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
    assert(!(username == null && email == null && mobilePhoneNumber == null));
    var body = {
      "username": username ?? email ?? mobilePhoneNumber,
      "password": password
    };
    var data = await BmobNetHelper.init().get('/1/login', body: body);
    if (data != null &&
        data.containsKey('createdAt') &&
        data.containsKey('objectId')) {
      fromJson(data);
      BmobConfig.config.sessionToken = sessionToken;
      return true;
    }
    BmobConfig.config.sessionToken = null;
    return false;
  }

  /// 检查用户的登录是否过期
  Future<bool> checkSession() async {
    if (objectId.isEmpty || sessionToken.isEmpty) {
      throw Exception('objectId or sessionToken is empty');
    }
    var data = await BmobNetHelper.init().get('/1/checkSession/$objectId');
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 获取用户信息
  @override
  Future<bool> getInfo({List<String> include = const []}) async {
    if (objectId.isEmpty) throw Exception("objectId is empty");
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
    if (objectId.isEmpty) throw Exception('objectId is empty');
    var data = await BmobNetHelper.init().delete('/1/user/$objectId');
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 修改密码
  Future<bool> updatePassword(String oldPwd, String newPwd) async {
    if (objectId.isEmpty || sessionToken.isEmpty) {
      throw Exception('objectId or sessionToken is empty');
    }
    var data = await BmobNetHelper.init().put('/1/updateUserPassword/$objectId',
        body: {"oldPassword": oldPwd, "newPassword": newPwd});
    if (data != null && data.containsKey('msg') && data['msg'] == 'ok') {
      password = newPwd;
      return true;
    }
    return false;
  }

  @override
  Future<bool> update([Map<String, dynamic>? body]) async {
    if (objectId.isEmpty) {
      throw Exception('objectId  is empty');
    }
    var data = await BmobNetHelper.init().put(
      '/1/users/$objectId',
      body: body ?? createJson(),
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
