import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/user_data.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  String? _selectedReason;
  final _confirmController = TextEditingController();
  bool _understood = false;
  int _step = 1;
  bool _isDeleting = false;

  final List<String> _reasons = [
    'I\'m not using the app anymore',
    'I have privacy concerns',
    'I created a duplicate account',
    'I\'m having technical issues',
    'I didn\'t find what I was looking for',
    'Other reason',
  ];

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      final success = await ProfileService.instance.deleteAccount();

      if (!mounted) return;

      if (success) {
        // Clear local state
        UserData.instance.clear();

        // Navigate to login/splash and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // ← replace with your login/splash route name
          (route) => false,
        );
      } else {
        setState(() => _isDeleting = false);
        _showError('Failed to delete account. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('An error occurred: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
              child: _step == 1 ? _buildStep1() : _buildStep2(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _isDeleting ? null : () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                ),
              ),
              const Expanded(
                child: Text(
                  'Delete Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure you want to leave?',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF212121)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deleting your account is permanent. You will lose all your data, posts, followers, and cannot undo this action.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // What you'll lose
        const Text(
          'WHAT YOU\'LL LOSE',
          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              _buildLossTile('Profile & personal information', Icons.person_off_outlined),
              const Divider(height: 1, indent: 56),
              _buildLossTile('All posts, photos and content', Icons.no_photography_outlined),
              const Divider(height: 1, indent: 56),
              _buildLossTile('Followers and connections', Icons.group_remove_outlined),
              const Divider(height: 1, indent: 56),
              _buildLossTile('Messages and conversations', Icons.speaker_notes_off_outlined),
              const Divider(height: 1, indent: 56),
              _buildLossTile('Saved items and favourites', Icons.bookmark_remove_outlined),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Reason
        const Text(
          'REASON FOR LEAVING',
          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: _reasons.map((reason) {
              return Column(
                children: [
                  RadioListTile<String>(
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (v) => setState(() => _selectedReason = v),
                    activeColor: const Color(0xFFF06292),
                    title: Text(reason, style: const TextStyle(fontSize: 14)),
                  ),
                  if (reason != _reasons.last) const Divider(height: 1, indent: 16),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF06292)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Keep Account',
                    style: TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedReason == null ? null : () => setState(() => _step = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    final canDelete = _confirmController.text == 'DELETE' && _understood && !_isDeleting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Final warning
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
          ),
          child: const Column(
            children: [
              Icon(Icons.delete_forever, color: Colors.redAccent, size: 48),
              SizedBox(height: 12),
              Text('Final Step',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.redAccent)),
              SizedBox(height: 8),
              Text(
                'Type "DELETE" below to confirm you want to permanently delete your account. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Confirm input
        TextField(
          controller: _confirmController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.characters,
          enabled: !_isDeleting,
          decoration: InputDecoration(
            hintText: 'Type DELETE to confirm',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _confirmController.text == 'DELETE'
                    ? Colors.redAccent
                    : const Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            prefixIcon: const Icon(Icons.edit_outlined, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 12),

        // Checkbox
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Checkbox(
                value: _understood,
                onChanged: _isDeleting ? null : (v) => setState(() => _understood = v!),
                activeColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              const Expanded(
                child: Text(
                  'I understand that deleting my account is permanent and irreversible.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canDelete ? () => _showFinalConfirm(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              disabledBackgroundColor: Colors.redAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Permanently Delete Account',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Go back button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _isDeleting ? null : () => setState(() => _step = 1),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFF06292)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Go Back',
                style: TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLossTile(String text, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent.withOpacity(0.7), size: 20),
      title: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF424242))),
    );
  }

  void _showFinalConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Last chance!',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent)),
        content: const Text(
            'Your account and all data will be permanently deleted from our servers. Are you absolutely sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0BEC5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _deleteAccount();       // trigger real deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}