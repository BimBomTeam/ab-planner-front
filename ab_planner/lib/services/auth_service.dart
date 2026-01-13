import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/utils/jwt_decoder.dart';

class LoginParams {
  final String authUrl;
  final String verifier;
  final String state;

  LoginParams({
    required this.authUrl,
    required this.verifier,
    required this.state,
  });
}

class AuthService {
  static const String _apiBaseUrl = 'http://130.61.233.185:8000/api/v1';
  // Note: For WebView, the redirect URI here must match what the backend expects/allows.
  // Using localhost is fine as we intercept it.
  static const String _redirectUri = 'http://localhost:8080/auth/callback';

  /// Prepares login parameters: genrates PKCE and fetching Auth URL
  static Future<LoginParams> getLoginParams() async {
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);
    final state = _generateRandomString(16);

    final loginUrlResponse = await http.get(
      Uri.parse(
        '$_apiBaseUrl/auth/microsoft/login-url?code_challenge=$challenge&state=$state',
      ),
    );

    if (loginUrlResponse.statusCode != 200) {
      throw Exception('Failed to get login URL: ${loginUrlResponse.body}');
    }

    final loginUrlData = json.decode(loginUrlResponse.body);
    // Append prompt=select_account to force account picker
    final String authUrl =
        loginUrlData['authorization_url'] + '&prompt=select_account';

    return LoginParams(authUrl: authUrl, verifier: verifier, state: state);
  }

  /// Exchanges the auth code for access tokens
  static Future<void> exchangeToken(String code, String verifier) async {
    final tokenResponse = await http.post(
      Uri.parse('$_apiBaseUrl/auth/microsoft/token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'code': code,
        'code_verifier': verifier,
        'redirect_uri': _redirectUri,
      }),
    );

    if (tokenResponse.statusCode == 200) {
      final data = json.decode(tokenResponse.body);
      final accessToken = data['access_token'];
      debugPrint('Access Token: $accessToken');

      try {
        final payload = parseJwt(accessToken);
        debugPrint(
          'User ID: ${payload['sub'] ?? payload['id'] ?? 'not found'}',
        );
      } catch (e) {
        debugPrint('Could not parse token for User ID: $e');
      }

      final refreshToken = data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refresh_token', refreshToken);
      }
    } else {
      final errorData = json.decode(tokenResponse.body);
      throw Exception(
        'Failed to exchange token: ${errorData['detail'] ?? tokenResponse.body}',
      );
    }
  }

  static String _generateCodeVerifier() {
    return _generateRandomString(32);
  }

  static String _generateCodeChallenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return _base64UrlEncode(digest.bytes);
  }

  static String _generateRandomString(int length) {
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(256));
    return _base64UrlEncode(values);
  }

  static String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
}
