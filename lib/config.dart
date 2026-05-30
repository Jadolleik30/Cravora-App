import 'package:flutter/foundation.dart';

class Config {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/code/backend/";
    } else {
      return "http://10.0.2.2/code/backend/";
    }
  }
}
