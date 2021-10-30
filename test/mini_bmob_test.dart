import 'package:flutter_test/flutter_test.dart';

import 'package:mini_bmob/mini_bmob.dart';
import 'package:mini_logger/mini_logger.dart';
import 'config.dart';

void main() {
  BmobConfig.init(appId, apiKey,
      masterKey: masterKey,
      secretKey: secretKey,
      printError: (object, extra) => L.e(object),
      printResponse: (object, extra) => L.d(object));

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
      L.i(_user.getBody());
    });

    test('deleteFieldValue', () async {
      await _user.login();
      await _user.deleteFieldValue(['email']);
      await _user.getInfo();
    });
  });
}
