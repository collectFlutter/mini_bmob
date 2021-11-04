import 'package:flutter_test/flutter_test.dart';
import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';

import 'config.dart';

void main() {
  BmobConfig.init(
    appId,
    apiKey,
    printError: (object, extra) => L.e(object),
    printResponse: (object, extra) => L.d(object),
  );

  group('user', () {
    test('install user', () async {
      BmobUserTable u = BmobUserTable(
          username: 'JsonYe-${DateTime.now().microsecondsSinceEpoch}',
          password: '123456');
      var flag = await u.install();
      expect(flag, true);
      L.i(u);
    });

    test('set acl', () async {
      BmobUserTable user =
          BmobUserTable(username: 'JsonYe', password: '123456');
      BmobUserTable user2 =
          BmobUserTable(username: 'yshye', password: '123456');
      var flag = await user2.login();
      expect(flag, true);
      L.i(user2.toJson());
      flag = await user.login();
      expect(flag, true);
      L.i(user.toJson());
      user.acl
          .user(user, read: true, write: true)
          .user(user2, read: true)
          .all(read: false, write: false);
      flag = await user.update();
      expect(flag, true);
      L.i(user.toJson());
    });

    test('user login', () async {
      BmobUserTable user =
          BmobUserTable(username: 'JsonYe', password: '123456');
      var flag = await user.login();
      expect(flag, true);
      L.i(user);
    });
  });
}
