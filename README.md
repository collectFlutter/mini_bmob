## mini_bmob
[![](https://img.shields.io/pub/v/mini_bmob#align=left&display=inline&height=20&originHeight=20&originWidth=76&status=done&style=none&width=76)](https://pub.flutter-io.cn/packages/mini_bmob) ![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/collectFlutter/mini_bmob?style=plastic)


Bmob API 接口封装，包含加密传输，包含用户管理、ACL和角色、地理位置、条件查询、数据关联、数组、对象操作。

> Bmob API interface encapsulation, including encrypted transmission, including user management, ACL and role, geographic location, conditional query, data association, array and object operation.

## 安装
```shell
flutter pub add mini_bmob
```

## 引用
```dart
import 'package:mini_bmob/mini_bmob.dart';
```

## 初始化

- 非加密形式

> 可查看测试代码`no_safe_test.dart`

```dart
BmobConfig.init(
    appId,
    apiKey,
    masterKey: masterKey,
    printError: (object, extra) =>L.e(object),
    printResponse: (object, extra) =>L.d(object)
);
```

- 加密形式

> 可查看测试代码`safe_test.dart`

```dart
BmobConfig.initSafe(
    secretKey,
    'JsonYe-',
    masterKey: masterKey,
    printError: (object, extra) => L.e(object),
    printResponse: (object, extra) => L.d(object),
);
```

## 登陆
```dart
BmobUserTable _user = BmobUserTable(username:'JsonYe',password:'123456');
await _user.login(); // 登陆后会自动更新sessionToken
```


## 创建表类
```dart
class BookTable extends BmobTable{}
```

## 新增对象
```dart
BookTable _table = BookTable();
await _table.install();
```

## 修改对象
```dart
await _table.update();
```

## 删除对象
```dart
await _table.delete();
```

## 查询列表
```dart
BmobWhereBuilder _where = BmobWhereBuilder();
_where.whereBasic('name').contain(['Flutter']);
await BmobQueryHelper.list(BookTable(),(json)=>BmobTable().fromJson(json),where:_where);
```

## 查询对象详情
```dart
BookTable _book = BookTable()..objectId='69a8a68a10';
await _book.getInfo();
```

