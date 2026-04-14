import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_social_button.dart';

import '../../services/google_sign_in_web.dart'
    if (dart.library.io) '../../services/google_sign_in_stub.dart' as gsi;

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback onSuccess;

  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initGsi();
  }

  Future<void> _initGsi() async {
    if (!kIsWeb) {
      setState(() => _isInitialized = true);
      return;
    }

    try {
      gsi.initGoogleSignInWeb(
        clientId: AuthService.googleClientId,
        onCredential: _handleIdToken,
      );
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _initError = 'Google login unavailable');
    }
  }

  Future<void> _handleIdToken(String idToken) async {
    if (_isLoading) return;
    if (mounted) setState(() => _isLoading = true);

    String email = '';
    try {
      final parts = idToken.split('.');
      if (parts.length >= 2) {
        String payload = parts[1];
        while (payload.length % 4 != 0) {
          payload += '=';
        }
        final bytes = base64Url.decode(payload);
        final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        email = json['email']?.toString() ?? '';
      }
    } catch (_) {}

    final result = await AuthService.loginWithIdToken(
      idToken: idToken,
      email: email,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      widget.onSuccess();
    } else {
      _showMessage(result['message']?.toString() ?? 'Google login failed.');
    }
  }

  Future<void> _onTap() async {
    if (!kIsWeb) {
      _showMessage('Google login is only available on web.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await gsi.promptGoogleSignIn();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Google sign-in failed: $e');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return AuthSocialButton(
        text: 'Google login unavailable',
        onPressed: () => _showMessage(_initError!),
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0C8A8A)),
        ),
      );
    }

    return AuthSocialButton(
      text: _isLoading ? 'Signing In...' : 'Continue with Google',
      onPressed: _isLoading ? () {} : _onTap,
    );
  }
}
