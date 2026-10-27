import 'remote_api_io.dart' if (dart.library.js_interop) 'remote_api_web.dart' as impl;

class RemoteApiClient {
  static Future<Map<String, dynamic>?> getJson(String url) => impl.performHttpGet(url);

  static Future<Map<String, dynamic>?> postJson(String url, Map<String, dynamic> payload) =>
      impl.performHttpPost(url, payload);
}
