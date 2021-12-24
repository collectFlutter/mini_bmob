import 'package:flutter_test/flutter_test.dart';
import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';

import 'config.dart';
import 'table/author.dart';
import 'table/book.dart';
import 'table/category.dart';

void main() {
  BmobConfig.init(
    appId,
    apiKey,
    masterKey: masterKey,
    printError: (object, extra) => L.e(object),
    printResponse: (object, extra) => L.d(object),
  );

  group('key', () {
    BmobWhereBuilder _where = BmobWhereBuilder();
    test('basic', () async {
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('equals', () async {
      _where.whereBasic('name').equals('C++ Primer 中文版（第5版）');
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('condition', () async {
      _where
          .whereBasic<DateTime>('pubdate')
          .gte(DateTime(2010, 6, 30))
          .lt(DateTime(2020, 7, 1));
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('table Pointer', () async {
      BmobWhereBuilder category = BmobWhereBuilder();
      category.whereBasic('objectId').equals('DV3c8889');
      _where.whereTable('category', CategoryTable()).inQuery(category);
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });
    test('table Pointer And', () async {
      BmobWhereBuilder category = BmobWhereBuilder();
      category.whereBasic('objectId').equals('DV3c8889');
      _where.whereTable('category', CategoryTable()).inQuery(category);

      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('table Relation', () async {
      BmobWhereBuilder author = BmobWhereBuilder();
      author
          .whereBasic('name')
          .contain(['Stanley B.Lippman', '弗朗西斯科·西里洛(Francesco Cirillo)']);
      _where.whereTable('author', AuthorTable()).inQuery(author);
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('table Relation2', () async {
      BmobWhereBuilder author = BmobWhereBuilder();
      author.whereBasic('name').contain(['Barbara E.Moo']);
      _where.whereTable('author', AuthorTable()).notInQuery(author);
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });

    test('group', () async {
      _where.groupBy(fields: ['category'], include: true);
      await BmobQueryHelper.query(
          BookTable(), (json) => BookTable().fromJson(json),
          where: _where);
    });
  });
}
