import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/repo/token_repository.dart';

class TongjiApi {
  TongjiApi._();

  /// 获取 [TongjiApi] 实例。
  /// 
  /// 这是一个单例模式，确保在整个应用程序中只有一个实例。
  factory TongjiApi() => _instance;

  static final TongjiApi _instance = TongjiApi._();

  final String _baseUrl = tongjiApiBaseUrl;

  final Logger _logger = Logger('TongjiApi');

  /// Exchange auth code for token.
  ///
  /// Saves the token into [TokenRepository] on success.
  Future<void> code2token(String code) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final response = await http.post(
      uri,
      body: {
        'grant_type': 'authorization_code',
        'client_id': tongjiClientID,
        'code': code,
        'redirect_uri': oneTJredirectUri,
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Code2TokenData data = Code2TokenData.fromJson(json.decode(response.body));
      final TokenRepository repo = TokenRepository.getInstance();
      await repo.saveFromCode2Token(data);
      return;
    }
    // TODO: wrap with NetworkException
    throw AppException(response.statusCode.toString(), 'Failed to get token');
  }

  Future<Code2TokenData> refreshToken(String refreshToken) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final response = await http.post(
      uri,
      body: {
        'grant_type': 'refresh_token',
        'client_id': tongjiClientID,
        'refresh_token': refreshToken,
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.info('refresh token response: ${response.body}');
      return Code2TokenData.fromJson(json.decode(response.body));
    }
    throw AppException(response.statusCode.toString(), 'Failed to refresh token');
  }
}
