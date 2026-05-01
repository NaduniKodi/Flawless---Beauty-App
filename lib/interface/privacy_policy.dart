import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _policies = [
    {
      'icon': Icons.person_outline,
      'title': 'Information We Collect',
      'content':
          'We collect information you provide directly to us, such as your name, email address, profile photo, and any other information you choose to provide when creating or updating your account. We also collect usage information automatically, including the pages you view and the actions you take within the app.',
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'How We Use Your Information',
      'content':
          'We use the information we collect to provide, maintain, and improve our services, personalize your experience, send you technical notices and support messages, respond to your comments and questions, and send you marketing communications (with your consent).',
    },
    {
      'icon': Icons.share_outlined,
      'title': 'Sharing of Information',
      'content':
          'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy. We may share information with service providers who assist us in operating our platform, conducting our business, or servicing you.',
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Data Security',
      'content':
          'We implement appropriate technical and organizational measures to protect your personal information against unauthorized or unlawful processing, accidental loss, destruction, or damage. We use industry-standard encryption to protect data in transit and at rest.',
    },
    {
      'icon': Icons.cookie_outlined,
      'title': 'Cookies & Tracking',
      'content':
          'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, some features of our service may not function properly without cookies.',
    },
    {
      'icon': Icons.child_care_outlined,
      'title': "Children's Privacy",
      'content':
          'Our service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent and you are aware that your child has provided us with personal data, please contact us.',
    },
    {
      'icon': Icons.edit_outlined,
      'title': 'Your Rights',
      'content':
          'You have the right to access, update, or delete your personal information at any time. You may also object to our processing of your data, request restriction, and request data portability. To exercise these rights, please contact us through the settings page.',
    },
    {
      'icon': Icons.location_on_outlined,
      'title': 'Data Retention & Location',
      'content':
          'We retain your information for as long as your account is active or as needed to provide you services. Your information may be transferred to and maintained on servers located outside of your country, where data protection laws may differ from those in your jurisdiction.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Column(
        children: [
          // Header
          Container(
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
                        'Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shield banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFF48FB1).withOpacity(0.15), const Color(0xFFF06292).withOpacity(0.08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF48FB1).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF06292).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined, color: Color(0xFFF06292), size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Privacy Matters',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF212121))),
                              SizedBox(height: 4),
                              Text('We are committed to protecting your personal information and your right to privacy.',
                                  style: TextStyle(color: Color(0xFF757575), fontSize: 12, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('Effective: January 1, 2025',
                        style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
                  ),
                  const SizedBox(height: 12),

                  // Policy items
                  ..._policies.map((p) => _buildPolicyCard(p)),

                  const SizedBox(height: 16),

                  // Contact section
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contact Our Privacy Team',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF212121))),
                        const SizedBox(height: 8),
                        const Text(
                          'Questions about privacy? We\'re here to help.',
                          style: TextStyle(color: Color(0xFF757575), fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mail_outline, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text('support@flawless.lk',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF48FB1).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(policy['icon'] as IconData, color: const Color(0xFFF06292), size: 18),
        ),
        title: Text(policy['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF212121))),
        iconColor: const Color(0xFFF06292),
        collapsedIconColor: const Color(0xFFB0BEC5),
        children: [
          Text(policy['content'] as String,
              style: const TextStyle(color: Color(0xFF616161), fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}