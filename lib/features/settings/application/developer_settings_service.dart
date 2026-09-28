import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';

/// 开发者设置页的调试上报编排。
///
/// 负责取学生信息并按给定 endpoint 触发一次调试采集上报。
class DeveloperSettingsService {
  DeveloperSettingsService({
    required StudentInfoRepository studentInfoRepository,
    required TongjiApi tongjiApi,
    required UserCollectionService userCollectionService,
  })  : _studentInfoRepository = studentInfoRepository,
        _tongjiApi = tongjiApi,
        _userCollectionService = userCollectionService;

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
}
