import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart' as win;
import 'package:webview_flutter/webview_flutter.dart' as mob;

class MicrosoftLoginWebView extends StatefulWidget {
  final String authUrl;
  final String expectedState;

  const MicrosoftLoginWebView({
    super.key,
    required this.authUrl,
    required this.expectedState,
  });

  @override
  State<MicrosoftLoginWebView> createState() => _MicrosoftLoginWebViewState();
}

class _MicrosoftLoginWebViewState extends State<MicrosoftLoginWebView> {
  // Windows controller
  final _windowsController = win.WebviewController();
  bool _isWindowsInitialized = false;

  // Mobile controller
  late final mob.WebViewController _mobileController;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _initWindowsWebView();
    } else {
      _initMobileWebView();
    }
  }

  // --- Windows Implementation ---
  Future<void> _initWindowsWebView() async {
    try {
      await _windowsController.initialize();
      _windowsController.url.listen((url) {
        if (url.startsWith('http://localhost:8080/auth/callback')) {
          _handleRedirect(Uri.parse(url));
        }
      });
      await _windowsController.setBackgroundColor(Colors.transparent);
      await _windowsController.loadUrl(widget.authUrl);

      if (!mounted) return;
      setState(() {
        _isWindowsInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop({'error': e.toString()});
    }
  }

  // --- Mobile Implementation (Android/iOS) ---
  void _initMobileWebView() {
    _mobileController =
        mob.WebViewController()
          ..setJavaScriptMode(mob.JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            mob.NavigationDelegate(
              onNavigationRequest: (mob.NavigationRequest request) {
                // Check for redirect
                if (request.url.startsWith(
                  'http://localhost:8080/auth/callback',
                )) {
                  _handleRedirect(Uri.parse(request.url));
                  return mob.NavigationDecision.prevent;
                }
                return mob.NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      _windowsController.dispose();
    }
    super.dispose();
  }

  void _handleRedirect(Uri uri) {
    final queryParams = uri.queryParameters;

    if (queryParams.containsKey('error')) {
      Navigator.of(context).pop({'error': queryParams['error']});
      return;
    }

    if (queryParams['state'] != widget.expectedState) {
      Navigator.of(context).pop({'error': 'Invalid state received'});
      return;
    }

    final code = queryParams['code'];
    if (code != null) {
      Navigator.of(context).pop({'code': code});
    } else {
      Navigator.of(context).pop({'error': 'No auth code found'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logowanie Microsoft'),
        backgroundColor: const Color(0xFF1A1F38),
      ),
      body: Center(
        child:
            Platform.isWindows
                ? (_isWindowsInitialized
                    ? win.Webview(
                      _windowsController,
                      permissionRequested: _onPermissionRequested,
                    )
                    : const CircularProgressIndicator())
                : mob.WebViewWidget(controller: _mobileController),
      ),
    );
  }

  Future<win.WebviewPermissionDecision> _onPermissionRequested(
    String url,
    win.WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    final decision = await showDialog<win.WebviewPermissionDecision>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Zgoda na dostęp'),
            content: Text('Strona $url żąda uprawnienia: $kind'),
            actions: <Widget>[
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      win.WebviewPermissionDecision.deny,
                    ),
                child: const Text('Odmów'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      win.WebviewPermissionDecision.allow,
                    ),
                child: const Text('Zezwól'),
              ),
            ],
          ),
    );
    return decision ?? win.WebviewPermissionDecision.deny;
  }
}
