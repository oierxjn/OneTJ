import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/data/code2token.dart';

class TongjiApi{
  final String _baseUrl = tongjiApiBaseUrl;

  Future<Map<String, dynamic>> code2token(String code) async {
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
      // TODO 可能需要做Token存储
      return data.toJson();
    } else {
      // TODO 需要用 NetworkException 包装
      throw AppException(response.statusCode.toString(), 'Failed to get token');
    }
  }
}