import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Push Notifications
  bool _pushAll = true;
  bool _pushMessages = true;
  bool _pushLikes = true;
  bool _pushComments = true;
  bool _pushFollowers = false;
  bool _pushPromotions = false;

  // Email Notifications
  bool _emailWeekly = true;
  bool _emailUpdates = false;
  bool _emailTips = true;

  // Sound & Vibration
  bool _sound = true;
  bool _vibration = true;
  bool _doNotDisturb = false;

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
                  _buildSectionLabel('PUSH NOTIFICATIONS'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile(
                      'All Notifications',
                      'Master toggle for all push notifications',
                      Icons.notifications_outlined,
                      _pushAll,
                      (v) => setState(() {
                        _pushAll = v;
                        _pushMessages = v;
                        _pushLikes = v;
                        _pushComments = v;
                      }),
                      isMaster: true,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Messages', 'New messages and replies', Icons.chat_bubble_outline, _pushMessages,
                        (v) => setState(() => _pushMessages = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Likes', 'When someone likes your content', Icons.favorite_border, _pushLikes,
                        (v) => setState(() => _pushLikes = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Comments', 'New comments on your posts', Icons.comment_outlined, _pushComments,
                        (v) => setState(() => _pushComments = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('New Followers', 'When someone follows you', Icons.person_add_outlined,
                        _pushFollowers, (v) => setState(() => _pushFollowers = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Promotions & Offers', 'Exclusive deals and offers', Icons.local_offer_outlined,
                        _pushPromotions, (v) => setState(() => _pushPromotions = v)),
                  ]),

                  const SizedBox(height: 20),
                  _buildSectionLabel('EMAIL NOTIFICATIONS'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile('Weekly Digest', 'Summary of your weekly activity', Icons.mail_outline,
                        _emailWeekly, (v) => setState(() => _emailWeekly = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('App Updates', 'New features and improvements', Icons.system_update_outlined,
                        _emailUpdates, (v) => setState(() => _emailUpdates = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Tips & Tutorials', 'How to get the most out of the app', Icons.lightbulb_outline,
                        _emailTips, (v) => setState(() => _emailTips = v)),
                  ]),

                  const SizedBox(height: 20),
                  _buildSectionLabel('SOUND & VIBRATION'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildSwitchTile('Sound', 'Play sound for notifications', Icons.volume_up_outlined, _sound,
                        (v) => setState(() => _sound = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Vibration', 'Vibrate for notifications', Icons.vibration, _vibration,
                        (v) => setState(() => _vibration = v)),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile('Do Not Disturb', 'Silence all notifications', Icons.do_not_disturb_on_outlined,
                        _doNotDisturb, (v) => setState(() => _doNotDisturb = v)),
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
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                ),
              ),
              const Expanded(
                child: Text(
                  'Notifications',
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
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
    bool isMaster = false,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFF06292),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMaster
              ? const Color(0xFFF06292).withOpacity(0.1)
              : const Color(0xFFF48FB1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isMaster ? const Color(0xFFF06292) : const Color(0xFFF48FB1), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: isMaster ? FontWeight.w600 : FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
    );
  }
}