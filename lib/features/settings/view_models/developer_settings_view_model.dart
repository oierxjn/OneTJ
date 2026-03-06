import 'dart:async';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/features/settings/models/developer_settings_exception.dart';
import 'package:onetj/features/settings/models/developer_settings_model.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';

class DeveloperSettingsViewModel extends BaseViewModel {
  DeveloperSettingsViewModel({DeveloperSettingsModel? model})
      : _model = model ?? DeveloperSettingsModel(),
        _eventController = StreamController<UiEvent>.broadcast();

  final DeveloperSettingsModel _model;
  final StreamController<UiEvent> _eventController;

  Stream<UiEvent> get events => _eventController.stream;

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
      _eventController.add(DeveloperDebugEndpointInvalidEvent(type: error.code));
      return;
    }
    _debugCollectionEndpoint = endpoint.toString();
    _sendingDebug = true;
    notifyListeners();
    try {
      await _model.sendDebugCollection(endpoint: endpoint);
      _eventController.add(const DeveloperDebugUploadSuccessEvent());
    } catch (error) {
      _eventController.add(
        DeveloperDebugUploadFailedEvent(message: error.toString()),
      );
    } finally {
      _sendingDebug = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
