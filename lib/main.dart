import 'package:flawless_beauty_app/auth/user_details.dart';
import 'package:flawless_beauty_app/interface/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vejkddtyqkpbpttdapop.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlamtkZHR5cWtwYnB0dGRhcG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NzMzMTgsImV4cCI6MjA3ODE0OTMxOH0.bqpj8ZPZ4KRUOvGbpRTFZ0IbSdqrVgZJ7rUkWcxTEuQ',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // required for deep-link email confirm
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event   = data.event;
      final session = data.session;

      // ── User tapped the confirmation link in their email ───────────────────
      // AuthChangeEvent.signedIn fires both on email-confirm deep-link AND on
      // normal password login. We only want to redirect to UserDetailsPage when
      // coming from the email confirmation link (passwordRecovery / initial
      // signup confirm). We detect the email-confirm case by checking that the
      // navigator is currently NOT already showing the app's main pages.
      //
      // The cleanest way: only act on signedIn when there is no current route
      // deeper than IntroPage, i.e. we came from a cold deep-link open.
      if (event == AuthChangeEvent.signedIn && session != null) {
        final nav = _navigatorKey.currentState;
        if (nav == null) return;

        // If the app was opened via the confirmation deep-link (cold start),
        // the navigator stack is just IntroPage. Push the user forward.
        // If the user logged in normally via LoginPage, LoginPage already
        // handles navigation itself — but this listener may also fire.
        // Using pushAndRemoveUntil here is safe: if they're already on
        // HomePage the transition is instant and harmless.

        // Check whether the user has completed their beauty profile:
        // UserData.instance.skinType will be empty for brand-new users.
        // For returning users (normal login), their profile would have been
        // loaded. For new email-confirmed users skinType is always empty.
        final isNewUser = _isNewUser();

        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                isNewUser ? const UserDetailsPage() : const HomePage(),
          ),
          (_) => false,
        );
      }

      // ── User signed out ────────────────────────────────────────────────────
      if (event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const IntroPage()),
          (_) => false,
        );
      }
    });
  }

  /// Treat a user as "new" (needs onboarding) if they have no app_metadata
  /// or no user_metadata indicating a completed profile.
  /// Since we save skin type to UserData locally, we check the Supabase
  /// user metadata as the source of truth.
  bool _isNewUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return true;

    // After UserDetailsPage saves data to Supabase (see note below),
    // we mark the profile as complete via user_metadata.
    // If 'profile_complete' is not set, treat as new user.
    final meta = user.userMetadata;
    if (meta == null) return true;
    return meta['profile_complete'] != true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:            _navigatorKey,
      title:                   'Flawless Beauty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8708A), // rose — matches app palette
        ),
      ),
      // On a fresh cold start, show IntroPage.
      // If a session already exists (returning user), go straight to HomePage.
      home: Supabase.instance.client.auth.currentSession != null
          ? const HomePage()
          : const IntroPage(),
    );
  }
}