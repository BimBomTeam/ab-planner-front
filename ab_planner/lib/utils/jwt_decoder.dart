import 'dart:convert';

Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Nieprawidłowy token JWT');
  }

  final payload = parts[1];
  var normalized = base64Url.normalize(payload);
  var decodedBytes = base64Url.decode(normalized);
  var decodedString = utf8.decode(decodedBytes);
  final payloadMap = json.decode(decodedString);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('Błąd podczas dekodowania payload JWT');
  }

  return payloadMap;
}