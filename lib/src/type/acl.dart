import 'package:mini_bmob/src/table/role_table.dart';
import 'package:mini_bmob/src/table/user_table.dart';

class BmobACL {
  final Map<String, dynamic> _acl = {};

  BmobACL([Map<String, dynamic> acl = const {}]) {
    _acl.clear();
    _acl.addAll(acl);
  }

  /// 设置全部人及其权限权限
  BmobACL all({bool read = false, bool write = false}) {
    if (read || write) {
      _acl['*'] = _createCAL(read, write);
    } else {
      _acl.remove('*');
    }
    return this;
  }

  /// 设置用户及其权限
  BmobACL user(BmobUserTable user, {bool read = false, bool write = false}) {
    if (user.objectId == null) throw Exception('user objectId is null');
    if (read || write) {
      _acl[user.objectId!] = _createCAL(read, write);
    } else {
      _acl.remove(user.objectId);
    }
    return this;
  }

  /// 设置多用户及统一权限
  BmobACL users(List<BmobUserTable> users,
      {bool read = false, bool write = false}) {
    for (var user in users) {
      this.user(user, read: read, write: write);
    }
    return this;
  }

  /// 设置角色及其权限
  BmobACL role(BmobRoleTable role, {bool read = false, bool write = false}) {
    if (role.objectId == null) throw Exception('role objectId is null');
    if (role.name == null) throw Exception('role name is null');
    if (read || write) {
      _acl["${role.name}:${role.objectId}"] = _createCAL(read, write);
    } else {
      _acl.remove("${role.name}:${role.objectId}");
    }
    return this;
  }

  /// 设置多个角色及统一权限
  BmobACL roles(List<BmobRoleTable> roles,
      {bool read = false, bool write = false}) {
    for (var role in roles) {
      this.role(role, read: read, write: write);
    }
    return this;
  }

  /// 权限的Json
  Map<String, dynamic> toJson() => {..._acl};

  Map<String, bool> _createCAL([bool read = false, bool write = false]) => {
        if (read) ...{
          "read": read,
        },
        if (write) ...{
          "write": write,
        },
      };
}
