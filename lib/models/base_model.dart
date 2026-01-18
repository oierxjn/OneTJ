import 'package:flutter/foundation.dart';

class BaseModel extends ChangeNotifier {
  String? errorMessage;
  String? errorCode;
  bool loading = false;
}