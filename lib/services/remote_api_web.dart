// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<Map<String, dynamic>?> performHttpGet(String url) async {
  try {
    final request = await html.HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));
    final text = request.responseText;
    if (text == null || text.trim().isEmpty) return null;
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

Future<Map<String, dynamic>?> performHttpPost(String url, Map<String, dynamic> payload) async {
  try {
    final request = await html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: jsonEncode(payload),
      requestHeaders: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));
    final text = request.responseText;
    if (text == null || text.trim().isEmpty) return null;
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}
