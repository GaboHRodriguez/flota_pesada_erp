import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>?> performHttpGet(String url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.getUrl(Uri.parse(url));
    req.headers.set('Accept', 'application/json');
    final resp = await req.close().timeout(const Duration(seconds: 12));
    final body = await resp.transform(utf8.decoder).join();
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>?> performHttpPost(String url, Map<String, dynamic> payload) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.postUrl(Uri.parse(url));
    req.headers.set('Content-Type', 'application/json; charset=utf-8');
    req.add(utf8.encode(jsonEncode(payload)));
    final resp = await req.close().timeout(const Duration(seconds: 12));
    final body = await resp.transform(utf8.decoder).join();
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
}
