import 'dart:math';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef GoogleCredentialCallback = void Function(String idToken);

GoogleCredentialCallback? _onCredential;
bool _listenerAdded = false;

extension type _MessageData._(JSObject _) implements JSObject {
  external String? get type;
  @JS('id_token')
  external String? get idToken;
}

void initGoogleSignInWeb({
  required String clientId,
  required GoogleCredentialCallback onCredential,
}) {
  _onCredential = onCredential;

  if (_listenerAdded) return;

  web.window.addEventListener(
    'message',
    (web.Event e) {
      try {
        final event = e as web.MessageEvent;
        final data = event.data;
        if (data == null) return;

        final msg = data as _MessageData;
        if (msg.type == 'google_id_token' && msg.idToken != null) {
          _onCredential?.call(msg.idToken!);
        }
      } catch (_) {}
    }.toJS,
  );

  _listenerAdded = true;
}

String _generateNonce() {
  final random = Random.secure();
  return List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

void triggerGoogleSignIn({required String clientId}) {
  final origin = web.window.location.origin;

  final base =
      web.document.querySelector('base')?.getAttribute('href') ?? '/';
  final redirectUri = '$origin$base';

  final nonce = _generateNonce();

  final url = 'https://accounts.google.com/o/oauth2/v2/auth?'
      'client_id=${Uri.encodeComponent(clientId)}'
      '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
      '&response_type=id_token'
      '&scope=openid%20email%20profile'
      '&nonce=$nonce'
      '&prompt=select_account';

  web.window.open(url, 'google_signin', 'width=500,height=600');
}
