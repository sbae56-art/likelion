import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('google.accounts.id.initialize')
external void _gsiInitialize(JSObject config);

@JS('google.accounts.id.renderButton')
external void _gsiRenderButton(JSAny element, JSObject config);

@JS('google.accounts.id.prompt')
external void _gsiPrompt();

extension type _CredentialResponse._(JSObject _) implements JSObject {
  external String get credential;
}

typedef GoogleCredentialCallback = void Function(String idToken);

bool _initialized = false;

void initGoogleSignInWeb({
  required String clientId,
  required GoogleCredentialCallback onCredential,
}) {
  if (_initialized) return;

  final config = <String, JSAny?>{
    'client_id': clientId.toJS,
    'callback': ((JSAny response) {
      final cred = response as _CredentialResponse;
      onCredential(cred.credential);
    }).toJS,
    'auto_select': false.toJS,
  }.jsify() as JSObject;

  _gsiInitialize(config);

  final container = web.document.createElement('div');
  container.id = 'gsi-hidden-btn';
  (container as web.HTMLElement).style.setProperty('position', 'fixed');
  container.style.setProperty('top', '-9999px');
  container.style.setProperty('left', '-9999px');
  web.document.body!.append(container);

  final btnConfig = <String, JSAny?>{
    'type': 'standard'.toJS,
    'size': 'large'.toJS,
    'theme': 'outline'.toJS,
    'text': 'signin_with'.toJS,
  }.jsify() as JSObject;

  _gsiRenderButton(container, btnConfig);

  _initialized = true;
}

void showGooglePrompt() {
  _gsiPrompt();
}

void triggerGoogleSignIn() {
  final container = web.document.getElementById('gsi-hidden-btn');
  if (container == null) return;

  final btn = container.querySelector('div[role="button"]')
      ?? container.querySelector('iframe');

  if (btn != null) {
    (btn as web.HTMLElement).click();
  } else {
    _gsiPrompt();
  }
}
