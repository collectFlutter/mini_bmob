import 'package:flutter/foundation.dart';

void _printLog(Object object, Map<String, dynamic> extra) =>
    debugPrint(object.toString());

typedef LogCallback = void Function(Object object, Map<String, dynamic> extra);

class BmobConfig {
  static BmobConfig get config => _config;
  static late BmobConfig _config;

  /// REST API 地址
  String get host => _host;
  late final String _host;

  /// REST API Key，REST API请求中HTTP头部信息必须附带密钥之一
  String get apiKey => _apiKey;
  late final String _apiKey;

  /// Application ID，SDK初始化必须用到此密钥
  String get appId => _appId;
  late final String _appId;

  /// Master Key，超级权限Key。应用开发或调试的时候可以使用该密钥进行各种权限的操作，此密钥不可泄漏
  String? get masterKey => _masterKey;
  final String? _masterKey;

  /// Secret Key，是SDK安全密钥，不可泄漏，在云函数测试云函数时需要用到
  String? get secretKey => _secretKey;
  final String? _secretKey;

  final LogCallback printError;
  final LogCallback printResponse;

  BmobConfig._(
    this._host,
    this._apiKey,
    this._appId,
    this._masterKey,
    this._secretKey, {
    this.printError = _printLog,
    this.printResponse = _printLog,
  });

  static void init(
    String appId,
    String apiKey, {
    String host = "https://api2.bmob.cn",
    String? masterKey,
    String? secretKey,
    printError,
    printResponse,
  }) {
    _config = BmobConfig._(
      host,
      apiKey,
      appId,
      masterKey,
      secretKey,
      printError: printError,
      printResponse: printResponse,
    );
  }

  Map<String, dynamic> getHeaders([String? session]) => {
        "X-Bmob-Application-Id": appId,
        "X-Bmob-REST-API-Key": apiKey,
        if (session != null) ...{
          "X-Bmob-Session-Token": session,
        },
      };

  Map<String, dynamic> getMasterHeaders([String? session]) => {
        "X-Bmob-Application-Id": appId,
        "X-Bmob-REST-API-Key": apiKey,
        "X-Bmob-Master-Key": masterKey,
        if (session != null) ...{
          "X-Bmob-Session-Token": session,
        },
      };
}
