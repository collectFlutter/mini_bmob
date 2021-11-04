import 'package:flutter_test/flutter_test.dart';

import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';

import 'table/author.dart';
import 'table/book.dart';
import 'table/category.dart';
import 'config.dart';

// 加密请求
void main() {
  BmobConfig.initSafe(secretKey,
      masterKey: masterKey,
      printError: (object, extra) => L.e(object),
      printResponse: (object, extra) => L.d(object));

  group('User Test', () {
    BmobUserTable _user = BmobUserTable(username: 'Safe', password: '123456');

    test('User Install', () async {
      var flag = await _user.install();
      expect(flag, true);
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
      _user.mobilePhoneNumber = '18916689123';
      flag = await _user.update();
      expect(flag, true);
    });

    test('User update password', () async {
      var flag = await _user.login();
      expect(flag, true);
      flag = await _user.updatePassword('123456', '111111');
      expect(flag, true);
      flag = await _user.updatePassword('111111', '123456');
      expect(flag, true);
    });

    test('deleteFieldValue', () async {
      await _user.login();
      await _user.deleteFieldValue(['email']);
      await _user.getInfo();
    });
  });

  group('Role Test', () {
    test('Role Install', () async {
      BmobRoleTable r1 = BmobRoleTable(name: '开发人员');
      var flag = await r1.install();
      expect(flag, true);
      BmobRoleTable r2 = BmobRoleTable(name: '运维人员');
      flag = await r2.install();
      expect(flag, true);
      BmobRoleTable r3 = BmobRoleTable(name: '测试人员');
      flag = await r3.install();
      expect(flag, true);
      BmobRoleTable r4 = BmobRoleTable(name: '运营人员');
      flag = await r4.install();
      expect(flag, true);
      BmobRoleTable r = BmobRoleTable(name: '管理员', roles: [r1, r2, r3]);
      flag = await r.install();
      expect(flag, true);
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
    test('Batch Query', () {});
  });
}
