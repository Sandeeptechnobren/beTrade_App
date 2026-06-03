import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Strongly-typed bundle of the fields we read off a Google sign-in.
///
/// Mirrors [AppleAuthCredential] in spirit: the service hands the provider a
/// small domain object instead of the package's raw [GoogleSignInAccount], so
/// the rest of the app never imports the SDK type directly.
///
///   - [idToken]      JWT signed by Google. This is what the backend will
///                    verify once social login is wired. May be null if the
///                    platform didn't return one.
///   - [email]        The selected account's email.
///   - [displayName]  Full name on the Google profile, if shared.
///   - [id]           Google's stable user id (`sub`).
///   - [photoUrl]     Profile photo URL, if any.
class GoogleAuthCredential {
  final String? idToken;
  final String email;
  final String? displayName;
  final String id;
  final String? photoUrl;

  const GoogleAuthCredential({
    required this.idToken,
    required this.email,
    required this.displayName,
    required this.id,
    required this.photoUrl,
  });
}

/// Thin wrapper around the [google_sign_in] package (v7 API).
///
/// Scope right now is deliberately small: open the native Google account
/// chooser and return the picked account. The backend exchange (POST to
/// `/auth/google`, mint app JWT) is intentionally NOT done here yet — that
/// flow is pending confirmation. When it's ready, the provider's
/// signInWithGoogle() should forward [idToken] to AuthService.socialLogin,
/// mirroring the Apple path; this service can stay as-is.
///
/// Why not Firebase Auth: same reason as Apple — Firebase in this project is
/// scoped to FCM only; auth lives on the BeTrade backend.
abstract class GoogleAuthService {
  /// Web OAuth client id (client_type 3 in android/app/google-services.json).
  /// Passed as serverClientId so the idToken returned on Android is aud'd to
  /// the backend's web client. iOS reads its own CLIENT_ID from
  /// ios/Runner/GoogleService-Info.plist automatically.
  static const String _serverClientId =
      '577626610829-o3mkqr4d1ico1hl1r6m16rqf57njdqs5.apps.googleusercontent.com';

  static bool _initialized = false;

  /// v7 requires [GoogleSignIn.initialize] to be called exactly once before
  /// [GoogleSignIn.authenticate]. We do it lazily on first use so main.dart's
  /// startup sequence stays untouched.
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  /// Launches the native Google account chooser and returns the picked
  /// account.
  ///
  /// Throws [GoogleSignInException] with code
  /// [GoogleSignInExceptionCode.canceled] when the user dismisses the sheet —
  /// callers should treat that as a silent no-op. Other exceptions propagate.
  static Future<GoogleAuthCredential> signIn() async {
    await _ensureInitialized();

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate();
    final String? idToken = account.authentication.idToken;

    debugPrint('🟢 Google account picked: email=${account.email}, '
        'name=${account.displayName}, id=${account.id}, '
        'idToken=${idToken == null ? "null" : "present (${idToken.length} chars)"}');

    return GoogleAuthCredential(
      idToken: idToken,
      email: account.email,
      displayName: account.displayName,
      id: account.id,
      photoUrl: account.photoUrl,
    );
  }
}
