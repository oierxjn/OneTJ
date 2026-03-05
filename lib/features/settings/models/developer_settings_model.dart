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
        _userCollectionService = userCollectionService ?? UserCollectionService();

  final StudentInfoRepository _studentInfoRepository;
  final TongjiApi _tongjiApi;
  final UserCollectionService _userCollectionService;

  Future<void> sendDebugCollection() async {
    final StudentInfoData studentInfo = await _studentInfoRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: _tongjiApi.fetchStudentInfo,
    );
    await _userCollectionService.sendDebugCollectionFromCurrentUser(studentInfo);
  }
}
