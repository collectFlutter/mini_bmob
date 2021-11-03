import 'package:mini_bmob/src/helper/bmon_net_helper.dart';
import 'package:mini_bmob/src/table/bmob_table.dart';
import 'package:mini_bmob/src/table/bmon_user_table.dart';
import 'package:mini_bmob/src/type/relation.dart';

class BmobRoleTable extends BmobTable {
  /// 角色名称必须限制为字母数字字符、破折号（-）和下划线(_)
  String? name;
  Relation<BmobRoleTable, BmobUserTable>? _users;

  Relation<BmobRoleTable, BmobUserTable>? get users => _users;

  void setUsers(List<BmobUserTable> users) {
    assert(users.isEmpty || !users.any((element) => element.objectId == null));
    if (_users == null) {
      _users = Relation(
        this,
        BmobUserTable(),
        'users',
        BmobUserTable().fromJson,
        users,
      );
    } else {
      _users!.list = users;
    }
  }

  Relation<BmobRoleTable, BmobRoleTable>? _roles;

  Relation<BmobRoleTable, BmobRoleTable>? get roles => _roles;

  void setRoles(List<BmobRoleTable> roles) {
    assert(roles.isEmpty || !roles.any((element) => element.objectId == null));
    if (_roles == null) {
      _roles = Relation(
        this,
        BmobRoleTable(),
        'roles',
        BmobRoleTable().fromJson,
        roles,
      );
    } else {
      _roles!.list = roles;
    }
  }

  BmobRoleTable(
      {this.name,
      List<BmobUserTable> users = const [],
      List<BmobRoleTable> roles = const []}) {
    assert(users.isEmpty || !users.any((element) => element.objectId == null));
    assert(roles.isEmpty || !roles.any((element) => element.objectId == null));
    if (users.isNotEmpty) {
      _users = Relation(
        this,
        BmobUserTable(),
        'users',
        (json) => BmobUserTable().fromJson(json),
        users,
      );
    }
    if (roles.isNotEmpty) {
      _roles = Relation(
        this,
        BmobRoleTable(),
        'roles',
        (json) => BmobRoleTable().fromJson(json),
        roles,
      );
    }
  }

  @override
  BmobRoleTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
    _users = Relation(
      this,
      BmobUserTable(),
      'users',
      (json) => BmobUserTable().fromJson(json),
    );
    _roles = Relation(
      this,
      BmobRoleTable(),
      'roles',
      (json) => BmobRoleTable().fromJson(json),
    );
    return this;
  }

  @override
  Map<String, dynamic> createJson() => {
        'name': Uri.encodeFull(name!),
        if (_users != null) ...{
          'users': _users!.createJson(),
        },
        if (_roles != null) ...{
          'roles': _roles!.createJson(),
        },
      };

  @override
  String getBmobTabName() => '_Role';

  /// 添加
  @override
  Future<bool> install() async {
    if (name == null || name!.isEmpty) throw Exception('name is null or empty');
    var data = await BmobNetHelper.init().post('/1/roles', body: createJson());
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

  /// 获取信息
  @override
  Future<bool> getInfo({List<String> include = const []}) async {
    if (objectId == null) throw Exception("objectId is null");
    var data = await BmobNetHelper.init().get('/1/roles/$objectId');
    if (data != null && data.containsKey('objectId')) {
      fromJson(data);
      return true;
    }
    return false;
  }

  /// 删除
  @override
  Future<bool> delete() async {
    if (objectId == null) throw Exception('objectId is null');
    var data = await BmobNetHelper.init().delete('/1/roles/$objectId');
    return data != null && data.containsKey('msg') && data['msg'] == 'ok';
  }

  /// 更新
  @override
  Future<bool> update([Map<String, dynamic>? body]) async {
    throw Exception('role no update operation');
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'users': _users?.toJson(),
        'roles': _roles?.toJson(),
      };
}
