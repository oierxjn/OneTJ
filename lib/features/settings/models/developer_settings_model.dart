import 'package:onetj/features/settings/models/developer_settings_exception.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';

class DeveloperSettingsModel {
  DeveloperSettingsModel({
    StudentInfoRepository? studentInfoRepository,
    TongjiApi? tongjiApi,
    UserCollectionService? userCollectionService,
  })  : _studentInfoRepository =
            studentInfoRepository ?? StudentInfoRepository.getInstance(),
        _tongjiApi = tongjiApi ?? TongjiApi(),
        _userCollectionService =
            userCollectionService ?? UserCollectionService();

  final StudentInfoRepository _studentInfoRepository;
  final TongjiApi _tongjiApi;
  final UserCollectionService _userCollectionService;

  Future<void> sendDebugCollection({
    required Uri endpoint,
  }) async {
    final StudentInfoData studentInfo = await _studentInfoRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: _tongjiApi.fetchStudentInfo,
    );
    await _userCollectionService.sendDebugCollectionFromCurrentUser(
      studentInfo,
      endpoint: endpoint,
    );
  }

  Uri parseDebugEndpoint(String raw) {
    final String trimmed = raw.trim();
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw DeveloperDebugEndpointException(
        code: DeveloperDebugEndpointException.invalidFormat,
        message: 'Invalid endpoint format',
      );
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw DeveloperDebugEndpointException(
        code: DeveloperDebugEndpointException.invalidScheme,
        message: 'Endpoint scheme must be http or https',
      );
    }
    return uri;
  }
}
