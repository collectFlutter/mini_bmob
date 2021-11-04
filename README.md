## mini_bmob
[![](https://img.shields.io/pub/v/mini_calendar#align=left&display=inline&height=20&originHeight=20&originWidth=76&status=done&style=none&width=76)](https://pub.flutter-io.cn/packages/mini_bmob) ![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/collectFlutter/mini_bmob?style=plastic)


Bmob API 接口封装，包含加密传输，包含用户管理、ACL和角色、地理位置、条件查询、数据关联、数组、对象操作。

> Bmob API interface encapsulation, including encrypted transmission, including user management, ACL and role, geographic location, conditional query, data association, array and object operation.

## Usage

### 1. 初始化

- 非加密形式

> 可查看测试代码`no_safe_test.dart`

```dart
BmobConfig.init(
appId,
apiKey,
masterKey: masterKey,
printError: (object, extra) =>L.e(object),
printResponse: (object, extra) =>L.d(object));
```

- 加密形式

> 可查看测试代码`safe_test.dart`

```dart
BmobConfig.initSafe(
    secretKey,
    safeToken: 'JsonYe-', // 安全码，详见官方文档
    masterKey: masterKey, //masterKey 不必填
    printError: (
    object, extra) =>
    L.e(object), // 访问API时，打印错误信息
    printResponse: (
    object, extra) =>
    L.d(object),
); // 访问API时，打印正常请求信息
```

### 2. ACL

> ACL 已经集成到基类中，若要启动，直接设置即可。可参考 `acl_test.dart`

### 3 创建表对象

> 以`book.dart`为例介绍

#### 3.1 创建[表名]Table类，继承BmobTable

```dart
class BookTable extends BmobTable {
}
```

#### 3.2 实现一个抽象方法 `getBmobTabName()`,返回bmob数据表中对应的表名称。

```dart
@override
String getBmobTabName() => "book";
```

#### 3.3 添加自有字段

##### 3.3.1 基本数据类型

```dart
/// 数名
String? name;
```

##### 3.3.2 Pointer数据类型

```dart
/// 所属类别
late BmobPointer<CategoryTable> category;
```

##### 3.3.3 Relation 数据类型

```dart
/// 作者
late BmobRelation<BookTable, AuthorTable> author;
```

##### 3.3.4 DateTime数据类型

```dart
/// 出版时间
BmobDateTime? pubDate;
```

#### 3.4 重写方法，补全解析代码

##### 3.4.1 构造方法

> 基础数据类型，可直接初始化。对于自定义的数据类型，建议传入基础数据类型，在构造函数中进行初始化。

```dart
BookTable({
  this.name,
  DateTime? pubDate,
  List<AuthorTable> author = const [],
  CategoryTable? category,
}) {
  assert(category == null || category.objectId != null);
  assert(
  author.isEmpty || !author.any((element) => element.objectId == null));
  if (pubDate != null) {
    this.pubDate = BmobDateTime(pubDate);
  }
  this.author = BmobRelation(
    this,
    AuthorTable(),
    'author',
        (json) => AuthorTable().fromJson(json),
    author,
  );
  this.category = BmobPointer(category);
}
```

##### 3.4.2 fromJson 方法
> 此方法也将用到对象查询中，json转对象，所以需要补全

```dart
@override
BookTable fromJson(Map<String, dynamic> json) {
  super.fromJson(json);
  name = json['name'];
  if (json.containsKey('pubdate')) {
    pubDate = BmobDateTime.fromJson(json['pubdate']);
  }
  if (category.subSet == null) {
    category.subSet = CategoryTable()
      ..fromJson(json['category']);
  } else {
    category.fromJson(json['category']);
  }
  author = BmobRelation(
    this,
    AuthorTable(),
    'author',
        (json) => AuthorTable().fromJson(json),
    [],
  );
  return this;
}
```

##### 3.4.3 createJson 方法
> 此方法，将用在数据新增、修改时会被调用，自动转换，需要补全

```dart
@override
Map<String, dynamic> createJson() => {
  ...super.createJson(), //此处建议包含基类的createJson方法，会自动完成ACL的设置。
  "name": name,
  "pubdate": pubDate?.toJson(),
  "category": category.createJson(),
  "author": author.createJson(),
};
```

##### 3.4.4 toJson() 方法，可选
> 此方法，用于将对象进行json化。组件中未引用。所以可结合实际使用需求进行补全。
```dart
@override
Map<String, dynamic> createJson() => {
    ...super.createJson(),
    "name": name,
    "pubdate": pubDate?.toJson(),
    "category": category.createJson(),
    "author": author.createJson(),
  };
```

### 4 查询
#### 4.1 WhereBuilder
> 用于生成查询语句，包含基础字段查询（包括DateTime类型）、复合查询、关联对象查询、位置查询、分页查询、聚合查询、排序、字段过滤
##### 4.1.1 基础字段查询
```dart
BmobWhereBuilder where = BmobWhereBuilder();
where
  .whereBasic<int>('age')
  .lte(100)
  .gte(20)
  .contain([30, 40, 50, 60])
  .unContain([50])
  .ne(30)
  .all([20, 23, 12]);
where
  .whereBasic<DateTime>('birthday')
  .gte(DateTime.parse('2020-10-12 12:10:09'))
  .lte(DateTime(2021, 12, 13, 23, 12, 12));
/// 打印查询语句
L.i(jsonEncode(where.builder()));
```
##### 4.1.2 复合查询
```dart
BmobWhereBuilder where = BmobWhereBuilder();
where.or<double>('width').gte(12.0).lte(34.9);
where.or<double>('width').gte(13.0).lte(34.9);
where.and<double>('height').gte(13.0).lte(34.9);
where.and<double>('height').gte(23.0).lte(44.9);
/// 打印查询语句
L.i(jsonEncode(where.builder()));
```
##### 4.1.3 关联对象查询
> 关联对象，直接调用其include方法即可
```dart
/// Relation 对象
await book.category.include();
/// Pointer 对象
await book.author.include();
```
##### 4.1.4 位置查询
TODO: or和and的复合查询，未测试过，不知是否可行

```dart
BmobWhereBuilder geo = BmobWhereBuilder();
// 基本查询
geo
    .whereGeoPoint('location', BmobGeoPoint(37.423112, 114.123412))
    .maxDistanceInKilometers(1000);

// or复合查询
geo
    .orGeoPoint('location', BmobGeoPoint(37.423112, 114.123412))
    .maxDistanceInKilometers(1000);

// and 复合查询
geo
    .andGeoPoint('location', BmobGeoPoint(37.123421, 114.124412))
    .maxDistanceInKilometers(1000);
/// 打印查询语句
L.i(jsonEncode(geo.builder()));
```

##### 4.1.5 分页查询
> pageIndex 从1开始。小于1的会自动转化成1

```dart
BmobWhereBuilder where = BmobWhereBuilder();
where.page(1,20); // 页码、每页数量。
/// 打印查询语句
L.i(jsonEncode(where.builder()));
```

##### 4.1.6 聚合查询
> 支持常见的 max、min、sum、average、groupBy。支持聚合后的筛选having
```dart
BmobWhereBuilder agr = BmobWhereBuilder();
agr.max(['age', 'height'])
  .min(['age', 'height'])
  .average(['age', 'height'])
  .sum(['age'])
  .groupBy(fields: ['sex'], groupCount: true); // 分组字段，是否对分组进行统计
L.i(agr.builder());
```

##### 4.1.7 排序
> 支持多字段排序，升序直接写字段名称，降序在字段名称前加-，也支持聚合查询后的字段排序。

```dart
BmobWhereBuilder where = BmobWhereBuilder();
where.order(['name','-age']);
/// 打印查询语句
L.i(jsonEncode(where.builder()));
```

##### 4.1.8 字段过滤
```dart
BmobWhereBuilder where = BmobWhereBuilder();
where.keys(['name','age']);
/// 打印查询语句
L.i(jsonEncode(where.builder()));
```