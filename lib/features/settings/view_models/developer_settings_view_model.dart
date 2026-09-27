import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/features/settings/application/developer_settings_service.dart';
import 'package:onetj/features/settings/models/developer_settings_exception.dart';
import 'package:onetj/features/settings/models/developer_settings_model.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';

class DeveloperSettingsViewModel extends BaseViewModel<UiEvent> {
  DeveloperSettingsViewModel({required DeveloperSettingsService service})
      : _service = service;

  final DeveloperSettingsService _service;

  bool _sendingDebug = false;
  bool get sendingDebug => _sendingDebug;
  String _debugCollectionEndpoint = defaultDebugCollectionEndpoint;
  String get debugCollectionEndpoint => _debugCollectionEndpoint;

  Future<void> sendDebugCollectionWithEndpoint(String rawEndpoint) async {
    if (_sendingDebug) {
      return;
    }
    final Uri endpoint;
    try {
      endpoint = DeveloperSettingsModel.parseDebugEndpoint(rawEndpoint.trim());
    } on DeveloperDebugEndpointException catch (error) {
      emit(DeveloperDebugEndpointInvalidEvent(type: error.code));
      return;
    }
    _debugCollectionEndpoint = endpoint.toString();
    _sendingDebug = true;
    notifyListeners();
    try {
      await _service.sendDebugCollection(endpoint: endpoint);
      emit(const DeveloperDebugUploadSuccessEvent());
    } catch (error) {
      emit(
        DeveloperDebugUploadFailedEvent(message: error.toString()),
      );
    } finally {
      _sendingDebug = false;
      notifyListeners();
    }
  }
}
