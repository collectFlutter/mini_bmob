import 'package:flutter_test/flutter_test.dart';
import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';

import 'config.dart';
import 'work_hour/work_info.dart';

/// 非加密请求
void main() {
  BmobConfig.init(
    appId,
    apiKey,
    masterKey: masterKey,
    printError: (object, extra) => L.e(object),
    printResponse: (object, extra) => L.d(object),
  );

  group('WorkHour', () {
    BmobUserTable _user =
        BmobUserTable(username: '27017', password: 'admin123');
    _user.sessionToken = '849ffee7404739fd808ba59e7c49cc87';
    test('Login', () async {
      var flag = await _user.login();
      expect(flag, true);
    });

    test('work_info', () async {
      DateTime _begin = DateTime(2021, 9, 26);
      DateTime _end = DateTime(2021, 10, 25, 23, 59, 59, 999);
      BmobWhereBuilder _where = BmobWhereBuilder();
      _where.whereBasic<DateTime>('date').gte(_begin).lte(_end);
      _where.whereBasic<String>('username').contain(['27017']);
      _where.order(['-date']);
      BmobSetResponse<WorkInfoTable> set = await BmobQueryHelper.query(
        WorkInfoTable(),
        (json) => WorkInfoTable().fromJson(json),
        where: _where,
      );
      L.d(set.results.map((e) => e.toJson()));
    });
  });
}
