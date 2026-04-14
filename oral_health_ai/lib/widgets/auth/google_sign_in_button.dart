import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth_service.dart';
import 'auth_social_button.dart';
import 'google_web_wrapper.dart';

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
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isHandlingWebEvent = false;
  String? _initializationError;

  bool get _usesWebRenderedButton =>
      kIsWeb && !AuthService.googleSignIn.supportsAuthenticate();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await AuthService.initializeGoogleSignIn();

      if (_usesWebRenderedButton) {
        _authSubscription = AuthService.googleSignIn.authenticationEvents.listen(
          (event) {
            if (event is GoogleSignInAuthenticationEventSignIn) {
              _handleWebGoogleLogin(event.user);
            }
          },
          onError: (Object error) {
            _showMessage(_googleErrorMessage(error));
          },
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _initializationError = 'Google login initialization failed.';
      });
      _showMessage('$error');
    }
  }

  Future<void> _handleMobileOrDesktopGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.loginWithGoogle();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      widget.onSuccess();
      return;
    }

    _showMessage(result['message']?.toString() ?? 'Google login failed.');
  }

  Future<void> _handleWebGoogleLogin(GoogleSignInAccount user) async {
    if (_isHandlingWebEvent) {
      return;
    }

    _isHandlingWebEvent = true;
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.loginWithGoogleAccount(user);
    if (!mounted) {
      return;
    }

    _isHandlingWebEvent = false;
    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      widget.onSuccess();
      return;
    }

    _showMessage(result['message']?.toString() ?? 'Google login failed.');
  }

  String _googleErrorMessage(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google sign-in was canceled.';
        default:
          return error.description ?? 'Google sign-in failed.';
      }
    }

    return error.toString();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationError != null) {
      return AuthSocialButton(
        text: 'Google login unavailable',
        onPressed: () {
          _showMessage(_initializationError!);
        },
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0C8A8A),
          ),
        ),
      );
    }

    if (_usesWebRenderedButton) {
      return Column(
        children: [
          renderGoogleButton(),
          if (_isLoading) ...[
            const SizedBox(height: 12),
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      );
    }

    return AuthSocialButton(
      text: _isLoading ? 'Signing In...' : 'Continue with Google',
      onPressed: _isLoading ? () {} : _handleMobileOrDesktopGoogleLogin,
    );
  }
}
