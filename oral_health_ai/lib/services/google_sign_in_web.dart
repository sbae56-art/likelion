import 'dart:async';
import 'dart:js_interop';

@JS('google.accounts.id.initialize')
external void _gsiInitialize(JSObject config);

@JS('google.accounts.id.prompt')
external void _gsiPrompt();

extension type _CredentialResponse._(JSObject _) implements JSObject {
  external String get credential;
}

typedef GoogleCredentialCallback = void Function(String idToken);

bool _initialized = false;
Completer<String>? _pendingLogin;

void initGoogleSignInWeb({
  required String clientId,
  required GoogleCredentialCallback onCredential,
}) {
  if (_initialized) return;

  final config = <String, JSAny?>{
    'client_id': clientId.toJS,
    'callback': ((JSAny response) {
      final cred = response as _CredentialResponse;
      final token = cred.credential;
      onCredential(token);
      _pendingLogin?.complete(token);
      _pendingLogin = null;
    }).toJS,
    'auto_select': false.toJS,
  }.jsify() as JSObject;

  _gsiInitialize(config);
  _initialized = true;
}

Future<String> promptGoogleSignIn() {
  if (_pendingLogin != null) {
    return _pendingLogin!.future;
  }

  _pendingLogin = Completer<String>();
  _gsiPrompt();
  return _pendingLogin!.future;
}
