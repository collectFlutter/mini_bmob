import 'dart:convert';

import 'package:mini_bmob/src/type/geo_point.dart';

import '../type/date_time.dart';

class BmobWhereBuilder {
  final Map<String, dynamic> _whereBasic = {};
  final Map<String, dynamic> _whereGeoPoint = {};
  final List<Map<String, dynamic>> _orBasic = [];
  final List<Map<String, dynamic>> _andBasic = [];
  final List<Map<String, dynamic>> _orGeoPoint = [];
  final List<Map<String, dynamic>> _andGeoPoint = [];
  final List<String> _keys = [];
  late List<String> _order = [];

  /// 每页数量
  int? _limit;

  /// 偏移量
  int? _skip;

  /// 返回的列为 _avg+首字母大写的列名 ，有
  final List<String> _groupBy = [];

  /// 为true的情形下则返回_count
  bool _groupCount = false;

  /// 查询结果值都用 _sum+首字母大写的列名 的格
  final List<String> _sum = [];

  /// 返回的列为 _avg+首字母大写的列名
  final List<String> _average = [];

  /// 查询结果值都用 _max+首字母大写的列名 的格
  final List<String> _max = [];

  /// 查询结果值都用 _min+首字母大写的列名 的格
  final List<String> _min = [];

  /// having传的是和where类似的json字符串，但having只应该用于过滤分组查询得到的结果集，即having只应该包含结果集中的列名如 {"_sumScore":{"$gt":100}}
  final Map<String, dynamic> _having = {};

  BmobWhereBuilder();

  /// 位置信息字段查询
  GeoPointBuilder whereGeoPoint(String key, BmobGeoPoint center) {
    if (_whereGeoPoint.containsKey(key)) {
      return _whereGeoPoint[key];
    }
    _whereGeoPoint[key] = GeoPointBuilder._(center);
    return _whereGeoPoint[key];
  }

  /// 条件查询-复合查询中的或查询
  GeoPointBuilder orGeoPoint(String key, BmobGeoPoint center) {
    _orGeoPoint.add({key: GeoPointBuilder._(center)});
    return _orGeoPoint.last[key];
  }

  /// 条件查询-复合查询中的与查询
  GeoPointBuilder andGeoPoint(String key, BmobGeoPoint center) {
    _orGeoPoint.add({key: GeoPointBuilder._(center)});
    return _orGeoPoint.last[key];
  }

  /// 基础数据类型查询，包含DateTime
  KeyBuilder<T> whereBasic<T>(String key) {
    if (_whereBasic.containsKey(key)) {
      return _whereBasic[key];
    }
    _whereBasic[key] = KeyBuilder<T>._();
    return _whereBasic[key];
  }

  /// 条件查询-复合查询中的或查询
  KeyBuilder<T> or<T>(String key) {
    _orBasic.add({key: KeyBuilder<T>._()});
    return _orBasic.last[key];
  }

  /// 条件查询-复合查询中的与查询
  KeyBuilder<T> and<T>(String key) {
    _andBasic.add({key: KeyBuilder<T>._()});
    return _andBasic.last[key];
  }

  /// 排序字段
  BmobWhereBuilder order(List<String> _order) {
    this._order = _order;
    return this;
  }

  /// 不查询具体数据，只统计
  BmobWhereBuilder noData() {
    _limit = 0;
    return this;
  }

  /// 分页查询
  /// [pageIndex] - 页面
  /// [pageSize] - 每页数量,默认100，最大的默认值是100，企业pro版套餐的最大值为1000，其它版套餐的最大值为500
  BmobWhereBuilder page([int pageIndex = 1, int pageSize = 100]) {
    pageIndex = pageIndex < 1 ? 1 : pageIndex;
    _limit = pageSize;
    _skip = (pageIndex - 1) * pageSize;
    return this;
  }

  /// 分组和计数
  BmobWhereBuilder groupBy(
      {List<String> fields = const [], bool groupCount = false}) {
    _groupBy
      ..clear()
      ..addAll(fields);
    _groupCount = groupCount;
    return this;
  }

  /// 聚合-求和
  BmobWhereBuilder sum([List<String> fields = const []]) {
    _sum
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-最小值
  BmobWhereBuilder min([List<String> fields = const []]) {
    _min
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-最大值
  BmobWhereBuilder max([List<String> fields = const []]) {
    _max
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-平均值
  BmobWhereBuilder average([List<String> fields = const []]) {
    _average
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-分组中的过滤条件
  BmobWhereBuilder having([Map<String, dynamic> having = const {}]) {
    _having
      ..clear()
      ..addAll(having);
    return this;
  }

  /// 查询指定列
  BmobWhereBuilder keys([List<String> keys = const []]) {
    _keys
      ..clear()
      ..addAll(keys);
    return this;
  }

  /// 一处where中的字段条件
  BmobWhereBuilder removeWhere(String key) {
    if (_whereBasic.containsKey(key)) {
      _whereBasic.remove(key);
    }
    return this;
  }

  /// 清空where条件
  BmobWhereBuilder clearWhere() {
    _whereBasic.clear();
    return this;
  }

  /// 清空所有条件
  BmobWhereBuilder clear() {
    _whereBasic.clear();
    _whereGeoPoint.clear();
    _orBasic.clear();
    _andBasic.clear();
    _keys.clear();
    _groupCount = false;
    _groupBy.clear();
    _average.clear();
    _sum.clear();
    _max.clear();
    _min.clear();
    _limit = null;
    _skip = null;
    _having.clear();
    _order.clear();
    return this;
  }

  Map<String, dynamic> builder() {
    Map<String, dynamic> _where = {};
    _where.addAll(
        {for (var key in _whereGeoPoint.keys) key: _whereGeoPoint[key]._json});
    _where.addAll(
        {for (var key in _whereBasic.keys) key: _whereBasic[key]._json});

    if (_orBasic.isNotEmpty || _orGeoPoint.isNotEmpty) {
      var or = [];
      for (var map in _orBasic) {
        or.add({for (var key in map.keys) key: map[key]._json});
      }
      for (var map in _orGeoPoint) {
        or.add({for (var key in map.keys) key: map[key]._json});
      }
      _where['\$or'] = or;
    }
    if (_andBasic.isNotEmpty || _andGeoPoint.isNotEmpty) {
      var and = [];
      for (var map in _andBasic) {
        and.add({for (var key in map.keys) key: map[key]._json});
      }
      for (var map in _andGeoPoint) {
        and.add({for (var key in map.keys) key: map[key]._json});
      }
      _where['\$and'] = and;
    }

    return {
      'count': true,
      if (_where.isNotEmpty) ...{'where': jsonEncode(_where)},
      if (_groupCount) ...{'groupcount': _groupCount},
      if (_groupBy.isNotEmpty) ...{'groupby': _groupBy.join(',')},
      if (_sum.isNotEmpty) ...{'sum': _sum.join(',')},
      if (_min.isNotEmpty) ...{'min': _min.join(',')},
      if (_max.isNotEmpty) ...{'max': _max.join(',')},
      if (_average.isNotEmpty) ...{'average': _average.join(',')},
      if (_having.isNotEmpty) ...{'having': jsonEncode(_having)},
      if (_order.isNotEmpty) ...{'order': _order.join(',')},
      if (_keys.isNotEmpty) ...{'keys': _keys.join(',')},
      if (_limit != null) ...{'limit': _limit},
      if (_skip != null) ...{'skip': _skip},
    };
  }
}

class KeyBuilder<T> {
  final Map<String, dynamic> _json = {};

  KeyBuilder._();

  ///$lt	小于
  KeyBuilder<T> lt(T value) {
    if (value is DateTime) {
      _json['\$lt'] = BmobDateTime(value).toJson();
    } else {
      _json['\$lt'] = value;
    }
    return this;
  }

  /// $lte	小于等于
  KeyBuilder<T> lte(T value) {
    if (value is DateTime) {
      _json['\$lte'] = BmobDateTime(value).toJson();
    } else {
      _json['\$lte'] = value;
    }
    return this;
  }

  /// $gt	大于
  KeyBuilder<T> gt(T value) {
    if (value is DateTime) {
      _json['\$gt'] = BmobDateTime(value).toJson();
    } else {
      _json['\$gt'] = value;
    }
    return this;
  }

  /// $gte	大于等于
  KeyBuilder<T> gte(T value) {
    if (value is DateTime) {
      _json['\$gte'] = BmobDateTime(value).toJson();
    } else {
      _json['\$gte'] = value;
    }
    return this;
  }

  /// $ne	不等于
  KeyBuilder<T> ne(T value) {
    if (value is DateTime) {
      _json['\$ne'] = BmobDateTime(value).toJson();
    } else {
      _json['\$ne'] = value;
    }
    return this;
  }

  /// $in	包含在数组中
  KeyBuilder<T> contain(List<T> list) {
    var _list = [
      for (var i in list) (i is DateTime) ? BmobDateTime(i).toJson() : i
    ];
    _json['\$in'] = _list;
    return this;
  }

  /// $nin	不包含在数组中
  KeyBuilder<T> unContain(List<T> list) {
    var _list = [
      for (var i in list) (i is DateTime) ? BmobDateTime(i).toJson() : i
    ];
    _json['\$nin'] = _list;
    return this;
  }

  /// $exists	这个 Key 有值
  KeyBuilder<T> exists(bool exists) {
    _json['\$exists'] = exists;
    return this;
  }

  /// $select	匹配另一个查询的返回值
  KeyBuilder<T> select(Map<String, dynamic> query) {
    _json['\$select'] = {"query": query};
    return this;
  }

  ///$dontSelect	排除另一个查询的返回
  KeyBuilder<T> unSelect(Map<String, dynamic> query) {
    _json['\$dontSelect'] = {'query': query};
    return this;
  }

  /// $all	包括所有给定的值
  KeyBuilder<T> all(List<T> list) {
    _json['\$all'] = list;
    return this;
  }

  /// $regex	匹配PCRE表达式,模糊查询只对付费用户开放，付费后可直接使用。
  KeyBuilder<T> regex(String regex) {
    _json['\$regex'] = regex;
    return this;
  }
}

class GeoPointBuilder {
  final Map<String, dynamic> _json = {};

  GeoPointBuilder._(BmobGeoPoint point) {
    _json['\$nearSphere'] = point.toJson();
  }

  // /// 查询的中心点
  // GeoPointBuilder nearSphere(BmobGeoPoint point) {
  //   _json['\$nearSphere'] = point.toJson();
  //   return this;
  // }

  /// 距离中心点的最大距离
  /// [miles] (英里)
  GeoPointBuilder maxDistanceInMiles([double? miles]) {
    if (miles != null && miles > 0) {
      _json['\$maxDistanceInMiles'] = miles;
    } else {
      _json.remove('\$maxDistanceInMiles');
    }
    return this;
  }

  /// 距离中心点的最大距离
  /// [kilometers] (公里)
  GeoPointBuilder maxDistanceInKilometers([double? kilometers]) {
    if (kilometers != null && kilometers > 0) {
      _json['\$maxDistanceInKilometers'] = kilometers;
    } else {
      _json.remove("\$maxDistanceInKilometers");
    }
    return this;
  }

  /// 距离中心点的最大距离
  /// [radians] (公里)
  GeoPointBuilder maxDistanceInRadians([double? radians]) {
    if (radians != null) {
      _json['\$maxDistanceInRadians'] = radians;
    } else {
      _json.remove('\$maxDistanceInRadians');
    }
    return this;
  }

  /// 距离中心点的最大距离
  /// [radians] (公里)
  GeoPointBuilder withIn([List<BmobGeoPoint> box = const []]) {
    if (box.isNotEmpty) {
      _json['\$within'] = {"$box": box.map((e) => e.toJson()).toList()};
    } else {
      _json.remove('\$within');
    }
    return this;
  }
}
