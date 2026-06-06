import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Strongly-typed bundle of the fields we read off an Apple credential.
///
/// We mirror only the values our backend needs:
///   - [identityToken]      JWT signed by Apple. Backend verifies this against
///                          Apple's public keys (JWKS) and treats the `sub`
///                          claim as the stable Apple user ID.
///   - [authorizationCode]  One-time code, useful if the backend wants to
///                          exchange it for refresh credentials with Apple.
///   - [userIdentifier]     Apple's stable user ID (`sub`). Backend may use
///                          this directly, but the source of truth is the
///                          verified identity token.
///   - [email] / [givenName] / [familyName]
///       Apple only returns these on the FIRST sign-in for an app. Every
///       subsequent sign-in returns null for these — that's by design,
///       not a bug. The backend must persist them on the first call and
///       look up by `sub` thereafter.
class AppleAuthCredential {
  final String identityToken;
  final String authorizationCode;
  final String userIdentifier;
  final String? email;
  final String? givenName;
  final String? familyName;

  const AppleAuthCredential({
    required this.identityToken,
    required this.authorizationCode,
    required this.userIdentifier,
    this.email,
    this.givenName,
    this.familyName,
  });
}

/// Thin wrapper around the [sign_in_with_apple] package.
///
/// Why this lives behind a service:
///   - Keeps the native SDK call in one place so the rest of the app
///     doesn't import [SignInWithApple] directly.
///   - Lets the provider layer reason about a domain object
///     ([AppleAuthCredential]) rather than the package's raw type.
///
/// Why we DON'T use Firebase Auth here:
///   - Firebase in this project is scoped to FCM (push notifications)
///     only. Auth lives on the BeTrade Laravel backend, which mints the
///     app's own JWT after verifying the Apple identity token. Routing
///     Apple sign-in through Firebase Auth would add a third party with
///     nothing to do.
abstract class AppleAuthService {
  /// Launches the native Apple sign-in sheet.
  ///
  /// Returns an [AppleAuthCredential] on success.
  ///
  /// Throws [SignInWithAppleAuthorizationException] when the user cancels
  /// or Apple refuses the request — callers should inspect the [code]
  /// and silently no-op for [AuthorizationErrorCode.canceled]. Other
  /// exception types (network, platform) propagate as-is.
  static Future<AppleAuthCredential> signIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // A valid Apple authorization always returns both tokens. If either
    // is missing something unusual happened — fail loudly rather than
    // pushing a half-empty payload to the backend.
    final identityToken = credential.identityToken;
    final authorizationCode = credential.authorizationCode;
    if (identityToken == null || authorizationCode == null) {
      debugPrint(
          "🍎 Apple credential missing tokens — identityToken=$identityToken, authorizationCode=$authorizationCode");
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message: "Apple did not return identity or authorization tokens",
      );
    }

    return AppleAuthCredential(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      userIdentifier: credential.userIdentifier ?? '',
      email: credential.email,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  }
}
