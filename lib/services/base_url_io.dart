import 'dart:io';

String getApiBaseUrl() {
  // Android emulator uses 10.0.2.2 to reach the host machine's localhost.
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api';
  }
  return 'http://localhost:8000/api';
}
