import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  String? errorMessage;
  String? errorCode;
  bool loading = false;
}