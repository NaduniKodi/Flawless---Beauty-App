import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  static const _sections = [
    {
      'title': '1. Acceptance of Terms',
      'content':
          'By accessing or using our application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you may not access the service. These terms apply to all visitors, users, and others who access or use the service.',
    },
    {
      'title': '2. User Accounts',
      'content':
          'When you create an account with us, you must provide accurate, complete, and current information. You are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password. You agree not to disclose your password to any third party.',
    },
    {
      'title': '3. Privacy Policy',
      'content':
          'Your use of the application is also governed by our Privacy Policy, which is incorporated into these Terms by this reference. Please review our Privacy Policy to understand our practices regarding the collection and use of your personal information.',
    },
    {
      'title': '4. User Content',
      'content':
          'Our service may allow you to post, link, store, share, and otherwise make available certain information, text, graphics, or other material. You are responsible for the content that you post to the service, including its legality, reliability, and appropriateness.',
    },
    {
      'title': '5. Prohibited Activities',
      'content':
          'You may not use the application for any unlawful purpose or in violation of any regulations. Prohibited activities include but are not limited to: harassment, spam, impersonation, unauthorized data collection, distributing malware, or any activity that interferes with the proper working of the service.',
    },
    {
      'title': '6. Intellectual Property',
      'content':
          'The service and its original content, features, and functionality are and will remain the exclusive property of the company and its licensors. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of the company.',
    },
    {
      'title': '7. Termination',
      'content':
          'We may terminate or suspend your account immediately, without prior notice or liability, for any reason, including without limitation if you breach the Terms. Upon termination, your right to use the service will cease immediately.',
    },
    {
      'title': '8. Limitation of Liability',
      'content':
          'In no event shall the company, its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
    },
    {
      'title': '9. Changes to Terms',
      'content':
          'We reserve the right to modify or replace these terms at any time at our sole discretion. We will provide notice of any changes by updating the "Last Updated" date. Your continued use of the service after any changes constitutes your acceptance of the new terms.',
    },
    {
      'title': '10. Contact Us',
      'content':
          'If you have any questions about these Terms and Conditions, please contact us at support@flawless.lk or through the help section within the application. We aim to respond to all inquiries within 2 business days.',
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
                        'Terms & Conditions',
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
                  // Date badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFF06292)),
                        SizedBox(width: 6),
                        Text('Last updated: January 1, 2025',
                            style: TextStyle(color: Color(0xFFF06292), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Intro
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Text(
                      'Please read these Terms and Conditions carefully before using our application. These terms govern your use of our service and constitute a legally binding agreement between you and us.',
                      style: TextStyle(color: Color(0xFF616161), fontSize: 14, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sections
                  ..._sections.map((section) => _buildSection(section['title']!, section['content']!)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF48FB1).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.article_outlined, color: Color(0xFFF06292), size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF212121))),
        iconColor: const Color(0xFFF06292),
        collapsedIconColor: const Color(0xFFB0BEC5),
        children: [
          Text(content, style: const TextStyle(color: Color(0xFF616161), fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}