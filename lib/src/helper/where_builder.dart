import 'dart:convert';

import '../type/date_time.dart';

class WhereBuilder {
  final Map<String, dynamic> _whereMap = {};
  final List<Map<String, dynamic>> _or = [];
  final List<Map<String, dynamic>> _and = [];
  final List<String> _keys = [];
  late List<String> _order;
  int? _count;
  int? _limit;

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

  /// BQL查询
  // BmobBql? _bql;

  WhereBuilder();

  /// 条件查询
  KeyBuilder<T> whereAdd<T>(String key) {
    if (_whereMap.containsKey(key)) {
      return _whereMap[key];
    }
    _whereMap[key] = KeyBuilder<T>._();
    return _whereMap[key];
  }

  /// 条件查询-复合查询中的或查询
  KeyBuilder<T> or<T>(String key) {
    _or.add({key: KeyBuilder<T>._()});
    return _or.last[key];
  }

  /// 条件查询-复合查询中的与查询
  KeyBuilder<T> and<T>(String key) {
    _and.add({key: KeyBuilder<T>._()});
    return _and.last[key];
  }

  /// 排序字段
  WhereBuilder order(List<String> _order) {
    this._order = _order;
    return this;
  }

  /// 查询结果计数,可用于分页参数，不为空时，返回统计总数.
  /// 如果有一个非0的limit的话，既会返回正确的results也会返回count的值。
  WhereBuilder count([int? count, int? limit]) {
    _count = count;
    _limit = limit;
    return this;
  }

  /// 分组和计数
  WhereBuilder groupBy(
      {List<String> fields = const [], bool groupCount = false}) {
    _groupBy
      ..clear()
      ..addAll(fields);
    _groupCount = groupCount;
    return this;
  }

  /// 聚合-求和
  WhereBuilder sum([List<String> fields = const []]) {
    _sum
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-最小值
  WhereBuilder min([List<String> fields = const []]) {
    _min
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-最大值
  WhereBuilder max([List<String> fields = const []]) {
    _max
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-平均值
  WhereBuilder average([List<String> fields = const []]) {
    _average
      ..clear()
      ..addAll(fields);
    return this;
  }

  /// 聚合-分组中的过滤条件
  WhereBuilder having([Map<String, dynamic> having = const {}]) {
    _having
      ..clear()
      ..addAll(having);
    return this;
  }

  /// 查询指定列
  WhereBuilder keys([List<String> keys = const []]) {
    _keys
      ..clear()
      ..addAll(keys);
    return this;
  }

  /// BQL 查询
  // WhereBuilder bql([BmobBql? bql]) {
  //   _bql = bql;
  //   return this;
  // }

  /// 一处where中的字段条件
  WhereBuilder removeWhere(String key) {
    if (_whereMap.containsKey(key)) {
      _whereMap.remove(key);
    }
    return this;
  }

  /// 清空where条件
  WhereBuilder clearWhere() {
    _whereMap.clear();
    return this;
  }

  /// 清空所有条件
  WhereBuilder clear() {
    _whereMap.clear();
    _or.clear();
    _and.clear();
    _keys.clear();
    _groupCount = false;
    _groupBy.clear();
    _average.clear();
    _sum.clear();
    _max.clear();
    _min.clear();
    _count = null;
    _limit = null;
    _having.clear();
    _order.clear();
    return this;
  }

  Map<String, dynamic> builder() {
    Map<String, dynamic> _where = {};
    if (_whereMap.isNotEmpty) {
      _where
          .addAll({for (var key in _whereMap.keys) key: _whereMap[key]._json});
    }
    if (_or.isNotEmpty) {
      var or = [];
      for (var map in _or) {
        or.add({for (var key in map.keys) key: map[key]._json});
      }
      _where['\$or'] = or;
    }
    if (_and.isNotEmpty) {
      var and = [];
      for (var map in _and) {
        and.add({for (var key in map.keys) key: map[key]._json});
      }
      _where['\$and'] = and;
    }

    return {
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
      if (_count != null) ...{'count': _count},
      if (_limit != null) ...{'limit': _limit},
      // if (_bql != null) ..._bql!.toJson()
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

  /// $regex	匹配PCRE表达式
  KeyBuilder<T> regex(String regex) {
    _json['\$nin'] = regex;
    return this;
  }
}
