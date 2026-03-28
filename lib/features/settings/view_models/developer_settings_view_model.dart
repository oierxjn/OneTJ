import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/features/settings/models/developer_settings_exception.dart';
import 'package:onetj/features/settings/models/developer_settings_model.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';

class DeveloperSettingsViewModel extends BaseViewModel<UiEvent> {
  DeveloperSettingsViewModel({DeveloperSettingsModel? model})
      : _model = model ?? DeveloperSettingsModel();

  final DeveloperSettingsModel _model;

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
      endpoint = _model.parseDebugEndpoint(rawEndpoint.trim());
    } on DeveloperDebugEndpointException catch (error) {
      emit(DeveloperDebugEndpointInvalidEvent(type: error.code));
      return;
    }
    _debugCollectionEndpoint = endpoint.toString();
    _sendingDebug = true;
    notifyListeners();
    try {
      await _model.sendDebugCollection(endpoint: endpoint);
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
