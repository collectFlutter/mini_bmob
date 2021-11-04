import 'package:flutter_test/flutter_test.dart';
import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';

import 'dart:convert';

import 'table/author.dart';
import 'table/book.dart';
import 'table/category.dart';
import 'config.dart';

/// 非加密请求
void main() {
  BmobConfig.init(
    appId,
    apiKey,
    masterKey: masterKey,
    printError: (object, extra) => L.e(object),
    printResponse: (object, extra) => L.d(object),
  );

  group('User Test', () {
    BmobUserTable _user =
        BmobUserTable(username: 'JsonYe2', password: '123456');

    test('User Install', () async {
      var flag = await _user.install();
      expect(flag, false);
    });

    test('User Login', () async {
      var flag = await _user.login();
      expect(flag, true);
      _user.username = null;
      flag = await _user.login();
      expect(flag, true);
      _user.username = null;
      _user.email = null;
      flag = await _user.login();
      expect(flag, true);
    });

    test('User Update', () async {
      var flag = await _user.login();
      expect(flag, true);
      _user.email = '824252187@qq.com';
      flag = await _user.update();
      expect(flag, true);
    });

    test('User update password', () async {
      var flag = await _user.login();
      expect(flag, true);
      flag = await _user.updatePassword('111111', '123456');
      expect(flag, true);
      L.i(_user.createJson());
    });

    test('deleteFieldValue', () async {
      await _user.login();
      await _user.deleteFieldValue(['email']);
      await _user.getInfo();
    });
  });

  group('Role Test', () {
    test('Role Install', () async {
      BmobRoleTable r1 = BmobRoleTable(name: 'Developer2');
      var flag = await r1.install();
      expect(flag, true);
      BmobRoleTable r2 = BmobRoleTable(name: 'Maintain2');
      flag = await r2.install();
      expect(flag, true);
      BmobRoleTable r3 = BmobRoleTable(name: 'Test2');
      flag = await r3.install();
      expect(flag, true);
      BmobRoleTable r4 = BmobRoleTable(name: 'Operate2');
      flag = await r4.install();
      expect(flag, true);
      // BmobRoleTable r = BmobRoleTable(name: 'Admin', roles: [r1, r2, r3]);
      // flag = await r.install();
      // expect(flag, true);
    });

    test('Role Remove Users', () async {
      BmobRoleTable admin = BmobRoleTable()..objectId = '69a8a68a10';
      var flag = await admin.getInfo();
      expect(flag, true);
      L.i(admin.toJson());

      await admin.users?.include();
      L.i(admin.toJson());

      var _user = admin.users!.list;
      if (_user.isNotEmpty) {
        L.i(_user.first.toJson());
        await admin.users!.remove([_user.first]);
        L.i(admin.toJson());
      }
    });

    test('Role Remove Roles', () async {
      BmobRoleTable admin = BmobRoleTable()..objectId = '69a8a68a10';
      var flag = await admin.getInfo();
      expect(flag, true);
      L.i(admin.toJson());

      await admin.roles?.include();
      L.i(admin.toJson());

      var _data = admin.roles!.list;
      if (_data.isNotEmpty) {
        L.i(_data.first.toJson());
        await admin.roles!.remove([_data.first]);
        L.i(admin.toJson());
      }
      flag = await admin.getInfo();
      expect(flag, true);
      L.i(admin.toJson());
    });
  });

  group('Batch Test', () {
    test('batch delete', () async {
      BmobWhereBuilder _where = BmobWhereBuilder();
      _where.whereAdd('nationality').contain(['中国']);
      BmobSetResponse<AuthorTable> _list = await BmobQueryHelper.list(
        AuthorTable(),
        (json) => AuthorTable().fromJson(json),
        where: _where,
      );
      BmobBatch batch = BmobBatch();
      for (var element in _list.results) {
        batch.delete(element);
      }
      L.i(batch.request);
      var data = await batch.post();
      L.i(data);
    });

    test('batch update', () async {
      BmobWhereBuilder _where = BmobWhereBuilder();
      _where.whereAdd('nationality').contain(['China']);
      _where.page(1, 10);
      BmobSetResponse<AuthorTable> _list = await BmobQueryHelper.list(
        AuthorTable(),
        (json) => AuthorTable().fromJson(json),
        where: _where,
      );
      BmobBatch batch = BmobBatch();
      batch.updateAll(_list.results, body: {'nationality': '中国'});
      L.i(batch.request);
      var date = await batch.post();
      L.i(date);
    });

    test('batch create', () async {
      List<AuthorTable> authors = List.generate(
        100,
        (index) => AuthorTable(name: 'JsonYe${index + 1}', nationality: '中国'),
      );
      BmobBatch batch = BmobBatch();
      for (var element in authors) {
        batch.create(element);
      }
      L.i(jsonEncode(batch.request));

      var data = await batch.post();
      L.i(data);
    });
  });

  group("Pointer Pointer Test", () {
    test("RP Install", () async {
      CategoryTable category = CategoryTable()..objectId = 'DV3c8889';
      await category.getInfo();
      AuthorTable author =
          AuthorTable(name: '弗朗西斯科·西里洛(Francesco Cirillo)', nationality: '意');
      await author.install();
      BookTable book =
          BookTable(name: '番茄工作法', author: [author], category: category);
      await book.install();
      L.i(book.toJson());
      await book.category.include();
      L.i(book.toJson());
    });

    test('RP query', () async {
      BookTable book = BookTable()..objectId = '1dc666b9be';
      await book.getInfo();
      L.i(book.toJson());
      await book.getInfo(include: ['category[name]']);
      L.i(book.toJson());
      await book.category.include();
      L.i(book.toJson());
      await book.author.include();
      L.i(book.toJson());
    });
  });

  group('WhereBuilder Test', () {
    test("聚合查询", () {
      BmobWhereBuilder agr = BmobWhereBuilder();
      agr.max(['age', 'height']).min(['age', 'height']).average(
          ['age', 'height']).sum(['age']).groupBy(fields: [
        'sex'
      ], groupCount: true).order(['-age']);
      L.i(agr.builder());
    });

    test('条件查询', () {
      BmobWhereBuilder where = BmobWhereBuilder();
      where
          .whereAdd<int>('age')
          .lt(100)
          .lte(100)
          .gt(20)
          .gte(20)
          .contain([30, 40, 50, 60])
          .unContain([50])
          .ne(30)
          .all([20, 23, 12]);
      where
          .whereAdd<DateTime>('birthday')
          .gte(DateTime.parse('2020-10-12 12:10:09'))
          .lte(DateTime(2021, 12, 13, 23, 12, 12));
      where.or<double>('width').gte(12.0).lte(34.9);
      where.or<double>('width').gte(13.0).lte(34.9);
      where.and<double>('width').gte(13.0).lte(34.9);
      where.and<double>('width').gte(13.0).lte(34.9);
      where.order(['-birthday', 'age']);
      L.i(where.builder());
    });
  });

  group('QueryHelper Test', () {
    test('batch test', () async {
      BmobBatch batch = BmobBatch();
      batch.request.addAll([
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe1", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe2", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe3", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe4", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe5", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe6", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe7", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe8", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe9", "nationality": "中国"}
        },
        {
          "method": "POST",
          "path": "/1/classes/author",
          "body": {"name": "JsonYe10", "nationality": "中国"}
        }
      ]);
      L.i(jsonEncode(batch.request));
      await BmobQueryHelper.batch(batch);
    });
  });
}
