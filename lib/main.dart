// lib/main.dart
import 'package:flawless_beauty_app/auth/user_details.dart';
import 'package:flawless_beauty_app/interface/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/services/interest_data.dart';
import 'package:flawless_beauty_app/services/notification_settings.dart';
import 'package:flawless_beauty_app/services/scan_history.dart';
import 'package:flawless_beauty_app/services/makeup_history.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // If a session already exists (returning user / app resumed after OS killed
  // the process), load all data before the first frame — no empty-state flash.
  if (Supabase.instance.client.auth.currentSession != null) {
    await _loadAll();
  }

  runApp(const MyApp());
}

/// Loads every singleton for the currently signed-in user.
Future<void> _loadAll() => Future.wait([
      UserData.instance.load(),
      InterestData.instance.load(),
      NotificationSettings.instance.load(),
      ScanHistory.instance.load(),    // ← added
      MakeupHistory.instance.load(),  // ← added
    ]);

/// Wipes every singleton so the next sign-in starts completely fresh.
/// Prevents data leaking between accounts on the same device.
void _clearAll() {
  UserData.instance.clear();
  InterestData.instance.clear();
  NotificationSettings.instance.clear();
  ScanHistory.instance.clear();    // ← added
  MakeupHistory.instance.clear();  // ← added
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

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event   = data.event;
      final session = data.session;
      final nav     = _navigatorKey.currentState;
      if (nav == null) return;

      // ── Sign-in / email confirmation ──────────────────────────────────────
      if (event == AuthChangeEvent.signedIn && session != null) {
        // Wipe stale data first, then load this user's data fresh.
        _clearAll();
        await _loadAll();

        final isNew = _isNewUser();
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                isNew ? const UserDetailsPage() : const HomePage(),
          ),
          (_) => false,
        );
      }

      // ── Sign-out ──────────────────────────────────────────────────────────
      if (event == AuthChangeEvent.signedOut) {
        _clearAll();
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const IntroPage()),
          (_) => false,
        );
      }
    });
  }

  bool _isNewUser() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta == null || meta['profile_complete'] != true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flawless Beauty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8708A)),
      ),
      home: Supabase.instance.client.auth.currentSession != null
          ? const HomePage()
          : const IntroPage(),
    );
  }
}