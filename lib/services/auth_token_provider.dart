import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/logged_http.dart';

/// 负责认证令牌的生命周期管理:授权码交换、过期检查与刷新。
///
/// 通过 `appLocator<AuthTokenProvider>()` 获取实例。
class AuthTokenProvider {
  AuthTokenProvider({TokenRepository? repository})
      : _repository = repository ?? appLocator<TokenRepository>();

  final TokenRepository _repository;

  final String _baseUrl = tongjiApiBaseUrl;
  static const Duration _tokenSkew = Duration(seconds: 30);

  /// 用授权码交换 token,成功后写入 [TokenRepository]。
  Future<void> exchangeCode(String code) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final http.Response response = await loggedHttpPost(
      uri,
      loggerName: 'AuthTokenProvider',
      body: <String, String>{
        'grant_type': 'authorization_code',
        'client_id': tongjiClientID,
        'code': code,
        'redirect_uri': oneTJredirectUri,
      },
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Code2TokenData data =
          Code2TokenData.fromJson(json.decode(response.body));
      await _repository.saveFromCode2Token(data);
      return;
    }
    throw NetworkException.http(
      statusCode: response.statusCode,
      uri: uri,
      responseBody: response.body,
    );
  }

  /// 返回一个有效的 access token。
  ///
  /// access token 过期时会用 refresh token 刷新,并写回 [TokenRepository]。
  /// 没有 token 时抛出 `AppException('AUTH_REQUIRED')`;
  /// refresh token 也过期时抛出 `AppException('AUTH_EXPIRED')`。
  Future<String> getValidAccessToken() async {
    final TokenData? token =
        await _repository.getToken(refreshFromStorage: true);
    if (token == null) {
      throw AppException('AUTH_REQUIRED', 'Missing access token');
    }
    if (!token.isAccessTokenExpired(skew: _tokenSkew)) {
      return token.accessToken;
    }
    if (token.isRefreshTokenExpired(skew: _tokenSkew)) {
      throw AppException('AUTH_EXPIRED', 'Refresh token expired');
    }
    final Code2TokenData refreshed = await _refreshToken(token.refreshToken);
    await _repository.saveFromCode2Token(refreshed);
    return refreshed.accessToken;
  }

  /// 用 refresh token 刷新 token,返回新的 [Code2TokenData],不写存储。
  Future<Code2TokenData> _refreshToken(String refreshToken) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final http.Response response = await loggedHttpPost(
      uri,
      loggerName: 'AuthTokenProvider',
      body: <String, String>{
        'grant_type': 'refresh_token',
        'client_id': tongjiClientID,
        'refresh_token': refreshToken,
      },
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Code2TokenData.fromJson(json.decode(response.body));
    }
    throw NetworkException.http(
      statusCode: response.statusCode,
      uri: uri,
      responseBody: response.body,
    );
  }
}
