// lib/interface/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/notification_settings.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFFE8708A), Color(0xFFF8AFCB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            // ListenableBuilder rebuilds the whole scroll area whenever any
            // toggle changes — cheap because the tree is small.
            child: ListenableBuilder(
              listenable: NotificationSettings.instance,
              builder: (_, __) {
                final ns = NotificationSettings.instance;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Push notifications ────────────────────────────────────
                      _sectionLabel('PUSH NOTIFICATIONS'),
                      const SizedBox(height: 8),
                      _buildCard([
                        _tile(
                          'All Notifications',
                          'Master toggle for all push notifications',
                          Icons.notifications_outlined,
                          ns.pushAll,
                          ns.setPushAll,
                          isMaster: true,
                        ),
                        _divider(),
                        _tile('Messages', 'New messages and replies',
                            Icons.chat_bubble_outline,
                            ns.pushMessages, ns.setPushMessages),
                        _divider(),
                        _tile('Likes', 'When someone likes your content',
                            Icons.favorite_border,
                            ns.pushLikes, ns.setPushLikes),
                        _divider(),
                        _tile('Comments', 'New comments on your posts',
                            Icons.comment_outlined,
                            ns.pushComments, ns.setPushComments),
                        _divider(),
                        _tile('New Followers', 'When someone follows you',
                            Icons.person_add_outlined,
                            ns.pushFollowers, ns.setPushFollowers),
                        _divider(),
                        _tile('Promotions & Offers', 'Exclusive deals and offers',
                            Icons.local_offer_outlined,
                            ns.pushPromos, ns.setPushPromos),
                      ]),

                      const SizedBox(height: 20),

                      // ── Email notifications ───────────────────────────────────
                      _sectionLabel('EMAIL NOTIFICATIONS'),
                      const SizedBox(height: 8),
                      _buildCard([
                        _tile('Weekly Digest', 'Summary of your weekly activity',
                            Icons.mail_outline,
                            ns.emailWeekly, ns.setEmailWeekly),
                        _divider(),
                        _tile('App Updates', 'New features and improvements',
                            Icons.system_update_outlined,
                            ns.emailUpdates, ns.setEmailUpdates),
                        _divider(),
                        _tile('Tips & Tutorials',
                            'How to get the most out of the app',
                            Icons.lightbulb_outline,
                            ns.emailTips, ns.setEmailTips),
                      ]),

                      const SizedBox(height: 20),

                      // ── Sound & vibration ─────────────────────────────────────
                      _sectionLabel('SOUND & VIBRATION'),
                      const SizedBox(height: 8),
                      _buildCard([
                        _tile('Sound', 'Play sound for notifications',
                            Icons.volume_up_outlined,
                            ns.sound, ns.setSound),
                        _divider(),
                        _tile('Vibration', 'Vibrate for notifications',
                            Icons.vibration,
                            ns.vibration, ns.setVibration),
                        _divider(),
                        _tile('Do Not Disturb', 'Silence all notifications',
                            Icons.do_not_disturb_on_outlined,
                            ns.doNotDisturb, ns.setDoNotDisturb),
                      ]),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _gradient),
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
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 22),
                ),
              ),
              const Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF9E8DA8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
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
            color: const Color(0xFFE8708A).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, color: Color(0xFFF3ECF1));

  Widget _tile(
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
      activeColor: const Color(0xFFE8708A),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMaster
              ? const Color(0xFFE8708A).withOpacity(0.10)
              : const Color(0xFFF8AFCB).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isMaster
              ? const Color(0xFFE8708A)
              : const Color(0xFFE8708A).withOpacity(0.75),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isMaster ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14.5,
          color: const Color(0xFF1C1224),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF9E8DA8), fontSize: 12),
      ),
    );
  }
}