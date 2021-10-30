import 'package:mini_bmob/src/bmon_config.dart';
import 'package:mini_net/mini_net.dart';

class BmobNetHelper {
  late final BmobConfig _config;

  BmobNetHelper._(this._config);

  factory BmobNetHelper.init() {
    return BmobNetHelper._(BmobConfig.config);
  }

  Future<Map<String, dynamic>?> get(
    path, {
    Map<String, dynamic>? body,
    cancelToken,
    Map<String, dynamic> extra = const {},
    String? session,
  }) async {
    NetManager manager = NetManager.internal(
      baseUrl: _config.host,
      headers: _config.getHeaders(session),
      connectTimeout: 5000,
      interceptors: [
        MiniLogInterceptor(
          printError: _config.printError,
          printResponse: _config.printResponse,
        )
      ],
    );
    ResponseModel response = await manager.get(
      path,
      body: body,
      cancelToken: cancelToken,
      extra: extra,
    );
    return response.response?.data;
  }

  Future<Map<String, dynamic>?> post(
    path, {
    Map<String, dynamic>? body,
    cancelToken,
    Map<String, dynamic> extra = const {},
    String? session,
  }) async {
    NetManager manager = NetManager.internal(
      baseUrl: _config.host,
      headers: _config.getHeaders(session),
      connectTimeout: 5000,
      interceptors: [
        MiniLogInterceptor(
          printError: _config.printError,
          printResponse: _config.printResponse,
        )
      ],
    );
    ResponseModel response = await manager.post(
      path,
      body: body,
      cancelToken: cancelToken,
      extra: extra,
    );
    return response.response?.data;
  }

  Future<Map<String, dynamic>?> delete(
    path, {
    Map<String, dynamic>? body,
    cancelToken,
    Map<String, dynamic> extra = const {},
    String? session,
  }) async {
    NetManager manager = NetManager.internal(
      baseUrl: _config.host,
      headers: _config.getHeaders(session),
      connectTimeout: 5000,
      interceptors: [
        MiniLogInterceptor(
          printError: _config.printError,
          printResponse: _config.printResponse,
        )
      ],
    );
    ResponseModel response = await manager.delete(
      path,
      body: body,
      cancelToken: cancelToken,
      extra: extra,
    );
    return response.response?.data;
  }

  Future<Map<String, dynamic>?> put(
    path, {
    Map<String, dynamic>? body,
    cancelToken,
    Map<String, dynamic> extra = const {},
    String? session,
  }) async {
    NetManager manager = NetManager.internal(
      baseUrl: _config.host,
      headers: _config.getMasterHeaders(),
      connectTimeout: 5000,
      interceptors: [
        MiniLogInterceptor(
          printError: _config.printError,
          printResponse: _config.printResponse,
        )
      ],
    );
    ResponseModel response = await manager.put(
      path,
      body: body,
      cancelToken: cancelToken,
      extra: extra,
    );
    return response.response?.data;
  }
}
