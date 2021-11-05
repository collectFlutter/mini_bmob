import 'dart:convert';

import 'package:crypto/crypto.dart' show md5;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

void _printLog(Object object, Map<String, dynamic> extra) =>
    debugPrint(object.toString());

typedef LogCallback = void Function(Object object, Map<String, dynamic> extra);

class BmobConfig {
  final Uuid _uuid = const Uuid();

  static BmobConfig get config => _config;
  static late BmobConfig _config;

  /// REST API 地址
  String get host => _host;
  final String _host;

  /// REST API Key，REST API请求中HTTP头部信息必须附带密钥之一
  String? get apiKey => _apiKey;
  final String? _apiKey;

  /// Application ID，SDK初始化必须用到此密钥
  String? get appId => _appId;
  final String? _appId;

  /// Master Key，超级权限Key。应用开发或调试的时候可以使用该密钥进行各种权限的操作，此密钥不可泄漏
  String? get masterKey => _masterKey;
  final String? _masterKey;

  /// Secret Key，是SDK安全密钥，不可泄漏，在云函数测试云函数时需要用到
  String? get secretKey => _secretKey;
  final String? _secretKey;

  /// 是否进行加密请求
  bool _safeRequest = false;

  bool get safeRequest => _safeRequest;

  /// 自定义API安全码，不通过网络传输。设置 API 安全码: 在应用功能设置，安全验证，API安全码自己设置长度为6个字符
  String? _safeToken;

  String? get safeToken => _safeToken;

  /// 打印错误请求日志
  final LogCallback printError;

  /// 打印请求正确日志
  final LogCallback printResponse;

  /// 用户登陆的token
  String? sessionToken;

  BmobConfig._(
    this._host,
    this._apiKey,
    this._appId,
    this._masterKey,
    this._secretKey, {
    this.printError = _printLog,
    this.printResponse = _printLog,
    bool safeRequest = false,
    String? safeToken,
    this.sessionToken,
  }) {
    _safeRequest = safeRequest;
    _safeToken = safeToken;
  }

  /// 组件初始化。 加密请求
  /// - [secretKey] B是SDK安全密钥，不可泄漏，在云函数测试云函数时需要用到
  /// - [host] 接口地址
  /// - [masterKey] 超级权限Key。应用开发或调试的时候可以使用该密钥进行各种权限的操作，此密钥不可泄漏
  /// - [safeToken] 自定义API安全码，不通过网络传输。设置 API 安全码: 在应用功能设置，安全验证，API安全码自己设置长度为6个字符
  /// - [printError] 打印错误请求日志
  /// - [printResponse] 打印正常日志
  static void initSafe(
    String secretKey,
    String safeToken, {
    String host = "https://api2.bmob.cn",
    String? masterKey,
    String? sessionToken,
    printError,
    printResponse,
  }) {
    _config = BmobConfig._(
      host,
      null,
      null,
      masterKey,
      secretKey,
      printError: printError,
      printResponse: printResponse,
      safeRequest: true,
      safeToken: safeToken,
      sessionToken: sessionToken,
    );
  }

  /// 组件初始化。 非加密请求
  /// - [appId] SDK初始化必须用到此密钥
  /// - [apiKey] REST API请求中HTTP头部信息必须附带密钥之一
  /// - [host] 接口地址
  /// - [masterKey] 超级权限Key。应用开发或调试的时候可以使用该密钥进行各种权限的操作，此密钥不可泄漏
  /// - [printError] 打印错误日志
  /// - [printResponse] 打印正常日志
  static void init(
    String appId,
    String apiKey, {
    String host = "https://api2.bmob.cn",
    String? masterKey,
    String? sessionToken,
    printError,
    printResponse,
  }) {
    _config = BmobConfig._(
      host,
      apiKey,
      appId,
      masterKey,
      null,
      printError: printError,
      printResponse: printResponse,
      safeRequest: false,
      safeToken: null,
      sessionToken: sessionToken,
    );
  }

  Map<String, dynamic> getHeaders({String? url}) {
    if (_safeRequest) {
      assert(url != null && _secretKey != null);
      int timeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String nonceStr = _uuid.v4().replaceAll('-', '').substring(3, 19);
      var content =
          const Utf8Encoder().convert("$url$timeStamp$_safeToken$nonceStr");
      var sign = md5.convert(content);
      return {
        'X-Bmob-SDK-Type': 'API',
        'X-Bmob-Safe-Timestamp': timeStamp,
        'X-Bmob-Noncestr-Key': nonceStr,
        'X-Bmob-Secret-Key': _secretKey,
        'X-Bmob-Safe-Sign': sign,
        if (sessionToken != null) ...{
          "X-Bmob-Session-Token": sessionToken,
        },
        if (_masterKey != null) ...{
          "X-Bmob-Master-Key": masterKey,
        }
      };
    }
    return {
      "X-Bmob-Application-Id": appId,
      "X-Bmob-REST-API-Key": apiKey,
      if (sessionToken != null) ...{
        "X-Bmob-Session-Token": sessionToken,
      },
      if (_masterKey != null) ...{
        "X-Bmob-Master-Key": masterKey,
      }
    };
  }
}
