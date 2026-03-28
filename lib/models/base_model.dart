import 'dart:async';

import 'package:flutter/foundation.dart';

class BaseViewModel<TEvent> extends ChangeNotifier {
  String? errorMessage;
  String? errorCode;
  bool loading = false;
  bool _isDisposed = false;
  final StreamController<TEvent> _eventController =
      StreamController<TEvent>.broadcast();

  bool get isDisposed => _isDisposed;
  Stream<TEvent> get events => _eventController.stream;

  @protected
  void emit(TEvent event) {
    if (_isDisposed || _eventController.isClosed) {
      return;
    }
    _eventController.add(event);
  }

  @override
  void notifyListeners() {
    if (_isDisposed) {
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventController.close();
    super.dispose();
  }
}
