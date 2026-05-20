import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage>
    with WidgetsBindingObserver {
  bool _biometric = false;
  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _rememberDevice = true;
  bool _appLock = false;
  bool _isAuthenticating = false;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    _loadSecuritySettings();
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// FIX 3: Added `mounted` check before every async operation.
  /// FIX 3: Only reads storage once and exits early if app lock is off.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    if (!_appLock) return;
    if (_isAuthenticating) return;

    // 🔑 Set the flag IMMEDIATELY — before any await.
    // This blocks every subsequent resumed event that fires
    // while the biometric dialog is open.
    _isAuthenticating = true;

    // Small delay so the app UI is fully visible before the prompt appears
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      _isAuthenticating = false;
      return;
    }

    final success = await _authenticate();
    _isAuthenticating = false; // Only release AFTER auth fully completes

    if (!mounted) return;
    if (!success) {
      SystemNavigator.pop();
    }
  }

  // ─── Storage ──────────────────────────────────────────────────────────────

  Future<void> _loadSecuritySettings() async {
    final bio = await _storage.read(key: 'biometric');
    final lock = await _storage.read(key: 'app_lock');
    final twofa = await _storage.read(key: '2fa');
    final alerts = await _storage.read(key: 'login_alerts');
    final remember = await _storage.read(key: 'remember_device');

    if (!mounted) return; // FIX: guard before setState
    setState(() {
      _biometric = bio == 'true';
      _appLock = lock == 'true';
      _twoFactor = twofa == 'true';
      _loginAlerts = alerts != 'false'; // default true
      _rememberDevice = remember != 'false'; // default true
    });
  }

  // ─── Biometric helper ─────────────────────────────────────────────────────

  /// Returns true if the user successfully authenticated.
  /// Shows a snackbar on error but never crashes.
  Future<bool> _authenticate() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isSupported) {
        if (mounted) _snack('Biometrics not available on this device');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN/pattern fallback
          stickyAuth: true, // don't cancel when app goes to background
        ),
      );
    } on PlatformException catch (e) {
      if (mounted) _snack('Biometric error: ${e.message}');
      return false;
    }
  }

  // ─── Toggle handlers ──────────────────────────────────────────────────────

  /// FIX 1: Authenticate FIRST. Only save + update state on success.
  /// If disabling, just clear storage — no auth prompt needed.
  Future<void> _onBiometricToggled(bool enable) async {
    if (enable) {
      _isAuthenticating = true;
      final success = await _authenticate();
      _isAuthenticating = false;
      if (!mounted) return;

      if (success) {
        setState(() => _biometric = true);
        await _storage.write(key: 'biometric', value: 'true');
      } else {
        // Leave the toggle OFF — don't update state or storage
        _snack('Biometric authentication failed');
      }
    } else {
      setState(() => _biometric = false);
      await _storage.write(key: 'biometric', value: 'false');
    }
  }

  /// FIX 3: Require biometric confirmation before enabling App Lock.
  /// This prevents someone from enabling it without being the real user.
  Future<void> _onAppLockToggled(bool enable) async {
    if (enable) {
      _isAuthenticating = true;
      final success = await _authenticate();
      _isAuthenticating = false;
      if (!mounted) return;

      if (success) {
        setState(() => _appLock = true);
        await _storage.write(key: 'app_lock', value: 'true');
        _snack('App Lock enabled');
      } else {
        _snack('Authentication required to enable App Lock');
        // toggle stays false — no state update needed
      }
    } else {
      setState(() => _appLock = false);
      await _storage.write(key: 'app_lock', value: 'false');
    }
  }

  // ─── 2FA ─────────────────────────────────────────────────────────────────

  /// FIX 2: Show the dialog and wait for the user's choice.
  /// Only save 'true' to storage if the user confirms.
  /// Revert the toggle to false if the user cancels.
  Future<void> _onTwoFactorToggled(bool enable) async {
    if (enable) {
      // Optimistically flip the UI, then confirm via dialog
      setState(() => _twoFactor = true);

      final confirmed = await _show2FADialog();
      if (!mounted) return;

      if (confirmed == true) {
        await _storage.write(key: '2fa', value: 'true');
        _snack('Two-factor authentication enabled');
      } else {
        // FIX 2: User cancelled — revert the toggle
        setState(() => _twoFactor = false);
        await _storage.write(key: '2fa', value: 'false');
      }
    } else {
      setState(() => _twoFactor = false);
      await _storage.write(key: '2fa', value: 'false');
      _snack('Two-factor authentication disabled');
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  final LinearGradient _gradient = const LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 20),

                  _buildSectionLabel('AUTHENTICATION'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile(
                      'Biometric Login',
                      'Use fingerprint or Face ID to sign in(TEMPORARY DISABLED IN DEVELOPMENT)',
                      Icons.fingerprint,
                      false,
                      (_) {}, 
                    ),
                    const Divider(height: 1, indent: 56),

                    _buildSwitchTile(
                      'Two-Factor Authentication',
                      'Extra layer of protection for your account',
                      Icons.verified_outlined,
                        false,
                      (_) {},
                    badge: 'Coming Soon', // FIX 2: Show "Coming Soon" badge and disable toggle
                     /* _twoFactor,
                      _onTwoFactorToggled, // FIX 2
                      badge: !_twoFactor ? 'Recommended' : null, */
                    ),
                    const Divider(height: 1, indent: 56),

                    _buildSwitchTile(
                      'App Lock',
                      'Require authentication to open the app (Temporarily disabled (in development))',
                      Icons.lock_outline,
                        false,
                        (_) {}, // FIX 3
                      /*_appLock,
                      _onAppLockToggled, */ // FIX 3
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _buildSectionLabel('ACTIVITY & DEVICES'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile(
                      'Login Alerts',
                      'Get notified of new sign-ins to your account',
                      Icons.notifications_active_outlined,
                      _loginAlerts,
                      (v) async {
                        setState(() => _loginAlerts = v);
                        await _storage.write(
                          key: 'login_alerts',
                          value: v.toString(),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'Remember This Device',
                      'Skip verification on trusted devices',
                      Icons.devices_outlined,
                      _rememberDevice,
                      (v) async {
                        setState(() => _rememberDevice = v);
                        await _storage.write(
                          key: 'remember_device',
                          value: v.toString(),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildNavTile(
                      'Active Sessions',
                      'Manage devices signed in to your account',
                      Icons.phone_android_outlined,
                      () => _showActiveSessions(context),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _buildSectionLabel('PASSWORD'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildNavTile(
                      'Change Password',
                      'Update your account password',
                      Icons.lock_reset_outlined,
                      () => _showChangePassword(context),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildNavTile(
                      'Forgot Password',
                      'Send a password reset link to your email',
                      Icons.help_outline_rounded,
                      _sendPasswordReset,
                    ),
                  ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Score card ───────────────────────────────────────────────────────────

  Widget _buildScoreCard() {
    // Score increases as features are enabled
    final score =
        [
          _biometric,
          _twoFactor,
          _appLock,
          _loginAlerts,
        ].where((e) => e).length /
        4;

    final label = score >= 0.75
        ? 'Strong 💪'
        : score >= 0.5
        ? 'Good'
        : 'Weak';

    final tip = !_twoFactor
        ? 'Enable 2FA to strengthen your account'
        : !_appLock
        ? 'Enable App Lock for extra protection'
        : 'Your account is well protected!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF06292).withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          const Text(
            'Security Score',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tip,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  /// FIX 2: Returns `true` if confirmed, `false`/`null` if cancelled.
  /// The caller uses this return value to decide whether to save to storage.
  Future<bool?> _show2FADialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // force an explicit choice
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enable 2FA',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'A verification code will be sent to your email each time you sign in. '
          'Make sure your email is accessible before enabling this.',
        ),
        actions: [
          TextButton(
            // Returns false — caller will revert the toggle
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB0BEC5)),
            ),
          ),
          ElevatedButton(
            // Returns true — caller will save to storage
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF06292),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Sessions',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 16),
            _sessionTile(
              'Start Pixel 7',
              'Current device · Android 13',
              Icons.phone_android,
              true,
            ),
            _sessionTile(
              'Redmi Note 11 Pro',
              'Active device · Android 13',
              Icons.phone_android,
              true,
            ),
            _sessionTile(
              'Windows PC',
              'Last active 5 hours ago · Windows 11',
              Icons.laptop_windows,
              false,
            ),
            _sessionTile(
              'iPad Air',
              'Last active Long time ago · iPadOS',
              Icons.tablet_mac,
              false,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirm = TextEditingController();
    final supabase = Supabase.instance.client;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 16),
            _passField('Current Password', current),
            const SizedBox(height: 10),
            _passField('New Password', newPass),
            const SizedBox(height: 10),
            _passField('Confirm New Password', confirm),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final currentPw = current.text.trim();
                  final newPw = newPass.text.trim();
                  final confirmPw = confirm.text.trim();

                  if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                    _snack('Please fill all fields');
                    return;
                  }
                  if (newPw != confirmPw) {
                    _snack('Passwords do not match');
                    return;
                  }
                  if (newPw.length < 6) {
                    _snack('Password must be at least 6 characters');
                    return;
                  }

                  try {
                    final email = supabase.auth.currentUser?.email;
                    if (email == null) {
                      _snack('User not found');
                      return;
                    }

                    await supabase.auth.signInWithPassword(
                      email: email,
                      password: currentPw,
                    );
                    await supabase.auth.updateUser(
                      UserAttributes(password: newPw),
                    );

                    if (!mounted) return;
                    Navigator.pop(sheetCtx);
                    _snack('Password updated successfully 🎉');
                  } catch (e) {
                    if (!mounted) return;
                    _snack(_authErrorMessage(e));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF06292),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) {
      _snack('No email found for your account');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      _snack('Reset link sent to $email');
    } catch (e) {
      if (!mounted) return;
      _snack(_authErrorMessage(e));
    }
  }

  // ─── Reusable widgets ─────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: _gradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Security',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: Color(0xFFB0BEC5),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  Widget _buildCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    String? badge,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFF06292),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF48FB1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFF48FB1), size: 20),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF06292).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFF06292),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
      ),
    );
  }

  Widget _buildNavTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF48FB1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFF48FB1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0BEC5)),
    );
  }

  Widget _sessionTile(
    String device,
    String info,
    IconData icon,
    bool isCurrent,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isCurrent ? const Color(0xFFF06292) : const Color(0xFFB0BEC5),
      ),
      title: Text(device, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        info,
        style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF06292).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Color(0xFFF06292),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : TextButton(
              onPressed: () {},
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
    );
  }

  Widget _passField(String label, TextEditingController controller) =>
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFCE4EC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF48FB1)),
        ),
      );

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// FIX minor: no context parameter needed — uses `this.context` safely
  /// after a mounted check by the caller.
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _authErrorMessage(Object e) {
    if (e is AuthException && e.message.isNotEmpty) return e.message;
    return 'Something went wrong. Please try again.';
  }
}
