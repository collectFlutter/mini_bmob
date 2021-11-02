import 'package:flutter_test/flutter_test.dart';

import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';
import 'table/author.dart';
import 'table/book.dart';
import 'table/category.dart';
import 'config.dart';

void main() {
  BmobConfig.init(appId, apiKey,
      masterKey: masterKey,
      secretKey: secretKey,
      printError: (object, extra) => L.e(object),
      printResponse: (object, extra) => L.d(object));

  group('query test', () {
    test('batch', () {
      List<int> list = List.generate(123, (index) => index + 1);
      int quotient = list.length ~/ 50;
      for (int i = 0; i < quotient; i++) {
        L.i(list.sublist(i * 50, i * 50 + 50));
      }
      int remainder = list.length % 50;
      if (remainder > 0) {
        L.i(list.sublist(list.length - remainder));
      }
    });
  });

  group('where_builder Test', () {
    test("AggregateQueryBuilder", () {
      WhereBuilder agr = WhereBuilder();
      agr.max(['age', 'height']).min(['age', 'height']).average(
          ['age', 'height']).sum(['age']).groupBy(fields: [
        'sex'
      ], groupCount: true).order(['-age']);
      L.i(agr.builder());
    });

    test('WhereBuilder', () {
      WhereBuilder where = WhereBuilder();
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

  group("Pointer Test", () {
    test("Install", () async {
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

    test('query', () async {
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

  group('User Test', () {
    BmobUserTable _user = BmobUserTable(username: 'JsonYe', password: '123456');

    test('Install', () async {
      var flag = await _user.install();
      expect(flag, false);
    });

    test('Login', () async {
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

    test('Update', () async {
      var flag = await _user.login();
      expect(flag, true);
      _user.email = '824252187@qq.com';
      flag = await _user.update();
      expect(flag, true);
    });

    test('updatePassword', () async {
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
}
