typedef GoogleCredentialCallback = void Function(String idToken);

void initGoogleSignInWeb({
  required String clientId,
  required GoogleCredentialCallback onCredential,
}) {
  throw UnsupportedError('Google Sign-In web is only available on web.');
}

void showGooglePrompt() {
  throw UnsupportedError('Google Sign-In web is only available on web.');
}

void triggerGoogleSignIn() {
  throw UnsupportedError('Google Sign-In web is only available on web.');
}
