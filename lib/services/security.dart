import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometric = true;
  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _rememberDevice = true;
  bool _appLock = false;

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
                  // Security score card
                  Container(
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
                        const Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Security Score',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Text(
                          'Good',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.68,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enable 2FA to strengthen your account',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionLabel('AUTHENTICATION'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile(
                      'Biometric Login',
                      'Use fingerprint or Face ID to sign in',
                      Icons.fingerprint,
                      _biometric,
                      (v) => setState(() => _biometric = v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'Two-Factor Authentication',
                      'Extra layer of protection for your account',
                      Icons.verified_outlined,
                      _twoFactor,
                      (v) {
                        setState(() => _twoFactor = v);
                        if (v) _show2FADialog(context);
                      },
                      badge: !_twoFactor ? 'Recommended' : null,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'App Lock',
                      'Require authentication to open the app',
                      Icons.lock_outline,
                      _appLock,
                      (v) => setState(() => _appLock = v),
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
                      (v) => setState(() => _loginAlerts = v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'Remember This Device',
                      'Skip verification on trusted devices',
                      Icons.devices_outlined,
                      _rememberDevice,
                      (v) => setState(() => _rememberDevice = v),
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
                      () {},
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB0BEC5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
  }

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

  void _show2FADialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enable 2FA',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'A verification code will be sent to your email each time you sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB0BEC5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
              'iPhone 14 Pro',
              'Current device · iOS 17',
              Icons.phone_iphone,
              true,
            ),
            _sessionTile(
              'MacBook Pro',
              'Last active 2 hours ago · macOS',
              Icons.laptop_mac,
              false,
            ),
            _sessionTile(
              'iPad Air',
              'Last active yesterday · iPadOS',
              Icons.tablet_mac,
              false,
            ),
          ],
        ),
      ),
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
      builder: (_) => Padding(
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
                  final currentPassword = current.text.trim();
                  final newPassword = newPass.text.trim();
                  final confirmPassword = confirm.text.trim();

                  // 🛑 Validation
                  if (currentPassword.isEmpty ||
                      newPassword.isEmpty ||
                      confirmPassword.isEmpty) {
                    _snack(context, "Please fill all fields");
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    _snack(context, "Passwords do not match");
                    return;
                  }

                  if (newPassword.length < 6) {
                    _snack(context, "Password must be at least 6 characters");
                    return;
                  }

                  try {
                    final user = supabase.auth.currentUser;
                    final email = user?.email;

                    if (email == null) {
                      _snack(context, "User not found");
                      return;
                    }

                    // 🔐 Re-authenticate user
                    await supabase.auth.signInWithPassword(
                      email: email,
                      password: currentPassword,
                    );

                    // 🔁 Update password
                    await supabase.auth.updateUser(
                      UserAttributes(password: newPassword),
                    );

                    Navigator.pop(context);
                    _snack(context, "Password updated successfully 🎉");
                  } catch (e) {
                    _snack(context, _authErrorMessage(e));
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

  String _authErrorMessage(Object e) {
    if (e is AuthException && e.message.isNotEmpty) {
      return e.message;
    }
    return 'Something went wrong. Please try again.';
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _passField(String label, TextEditingController controller) {
    return TextField(
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
  }
}
