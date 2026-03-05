import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/user_collection_consent.dart';
import 'package:onetj/models/user_collection_payload.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/device_info_service.dart';

class UserCollectionService {
  UserCollectionService._({
    http.Client? client,
    DeviceInfoService? deviceInfoService,
  })  : _client = client ?? http.Client(),
        _deviceInfoService = deviceInfoService ?? DeviceInfoService();

  static final UserCollectionService _instance = UserCollectionService._();

  factory UserCollectionService() => _instance;

  final http.Client _client;
  final DeviceInfoService _deviceInfoService;
  final Uri _endpoint =
      Uri.https('www.gardilily.com', '/oneDotTongji/userLoginInfoUpload.php');
  final Uri _debugEndpoint = Uri.http('127.0.0.1:8000', '/collector/v1/events');

  bool _uploadedInSession = false;

  Future<void> uploadForProduction({
    required StudentInfoData studentInfo,
    required SettingsData settings,
  }) async {
    if (!_canUploadBySettings(settings)) {
      AppLogger.debug(
        'User collection skipped by settings gate',
        loggerName: 'UserCollectionService',
        context: <String, Object?>{
          'featureFlag': settings.userCollectionFeatureFlag,
          'enabled': settings.userCollectionEnabled,
          'consent': settings.userCollectionConsent.jsonValue,
        },
      );
      return;
    }
    try {
      await _collectAndUpload(
        studentInfo: studentInfo,
        endpoint: _endpoint,
        applySessionGate: true,
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'User collection upload failed',
        loggerName: 'UserCollectionService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> sendDebugCollectionFromCurrentUser(
    StudentInfoData studentInfo,
  ) async {
    await _collectAndUpload(
      studentInfo: studentInfo,
      endpoint: _debugEndpoint,
      applySessionGate: false,
    );
  }

  Future<void> _collectAndUpload({
    required StudentInfoData studentInfo,
    required Uri endpoint,
    /// 为 true 时，仅在当前会话中上传一次
    required bool applySessionGate,
  }) async {
    if (applySessionGate && _uploadedInSession) {
      return;
    }
    final UserCollectionPayload payload =
        await _buildPayload(studentInfo: studentInfo);
    await _postJson(
      endpoint: endpoint,
      payload: payload,
    );
    if (applySessionGate) {
      _uploadedInSession = true;
    }
    AppLogger.info(
      'User collection success',
      loggerName: 'UserCollectionService',
      context: payload.toSafeDebugMap(),
    );
  }

  Future<void> _postJson({
    required Uri endpoint,
    required UserCollectionPayload payload,
  }) async {
    AppLogger.info(
      'User collection started',
      loggerName: 'UserCollectionService',
      context: payload.toSafeDebugMap(),
    );
    final Stopwatch stopwatch = Stopwatch()..start();
    final http.Response response = await _client.post(
      endpoint,
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(payload.toJson()),
    );
    AppLogger.info(
      'User collection response',
      loggerName: 'UserCollectionService',
      context: <String, Object?>{
        'statusCode': response.statusCode,
        'elapsedMs': stopwatch.elapsedMilliseconds,
        'endpoint': endpoint.toString(),
        'body': response.body,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException.http(
        statusCode: response.statusCode,
        uri: endpoint,
      );
    }
  }

  bool _canUploadBySettings(SettingsData settings) {
    return settings.userCollectionFeatureFlag &&
        settings.userCollectionEnabled &&
        settings.userCollectionConsent == UserCollectionConsent.accepted;
  }

  Future<UserCollectionPayload> _buildPayload({
    required StudentInfoData studentInfo,
  }) async {
    final DeviceInfoData deviceInfo = await _deviceInfoService.getDeviceInfo();
    return UserCollectionPayload(
      userid: studentInfo.userId,
      username: studentInfo.name,
      clientVersion: '$oneTJAppVersion+$oneTJAppBuildNumber',
      deviceBrand: deviceInfo.brand,
      deviceModel: deviceInfo.model,
      deptName: studentInfo.deptName,
      schoolName: studentInfo.schoolName,
      gender: studentInfo.sexName,
      platform: deviceInfo.platform,
    );
  }
}
