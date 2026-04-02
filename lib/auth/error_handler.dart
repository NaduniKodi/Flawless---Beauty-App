// lib/auth/auth_error_handler.dart
//
// Maps Supabase AuthApiException error codes to friendly messages
// and provides a resend-confirmation helper.

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  /// Returns a human-readable message for any Supabase auth error.
  static String message(Object error) {
    if (error is AuthApiException) {
      switch (error.code) {
        // ── Email errors ──────────────────────────────────────────────────────
        case 'email_address_invalid':
          return 'That email address isn\'t accepted. Try a different one.';
        case 'email_address_not_authorized':
          return 'This email isn\'t authorised to sign up. Contact support.';

        // ── Rate limiting ─────────────────────────────────────────────────────
        case 'over_email_send_rate_limit':
          return 'Too many emails sent. Please wait a few minutes and try again.';
        case 'over_request_rate_limit':
          return 'Too many requests. Please slow down and try again shortly.';

        // ── Confirmation ──────────────────────────────────────────────────────
        case 'email_not_confirmed':
          return 'email_not_confirmed'; // caller handles this specially

        // ── Credentials ───────────────────────────────────────────────────────
        case 'invalid_credentials':
          return 'Incorrect email or password.';
        case 'user_not_found':
          return 'No account found with that email.';
        case 'weak_password':
          return 'Password is too weak. Use at least 8 characters.';
        case 'user_already_exists':
          return 'An account with this email already exists.';

        // ── Session ───────────────────────────────────────────────────────────
        case 'session_not_found':
          return 'Session expired. Please sign in again.';

        default:
          return error.message;
      }
    }
    return error.toString();
  }

  /// True when the error is specifically an unconfirmed email.
  static bool isUnconfirmed(Object error) =>
      error is AuthApiException && error.code == 'email_not_confirmed';

  /// True when the error is a rate-limit error.
  static bool isRateLimited(Object error) =>
      error is AuthApiException &&
      (error.code == 'over_email_send_rate_limit' ||
          error.code == 'over_request_rate_limit');
}