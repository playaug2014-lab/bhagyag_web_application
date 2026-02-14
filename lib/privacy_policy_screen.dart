import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF7213),
            const Color(0xFFFF8C42),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.privacy_tip,
              size: 50,
              color: Color(0xFFFF7213),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Privacy Matters to Us',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _buildIntroCard(),
          const SizedBox(height: 24),

          _buildSectionTitle('Updates to This Policy'),
          const SizedBox(height: 12),
          _buildParagraph(
            'We reserve the right to update this Policy to reflect changes in our practices and services. When we post changes to this Policy, we will update the date. Continued use of the Services after such date constitutes acceptance of such updates.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('How We Collect and Use Your Information'),
          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.info_outline,
            title: 'Information Collection',
            description: 'We collect personal information to provide Services, including contact details, order information, account information, and customer support data.',
          ),
          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.shopping_bag,
            title: 'Order Information',
            description: 'Name, billing address, shipping address, payment confirmation, email addresses, and phone number.',
          ),
          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.account_circle,
            title: 'Account Information',
            description: 'Username, password, security questions and other information used for account security purposes.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Services & Quality'),
          const SizedBox(height: 12),
          _buildServiceNote(
            'Users are responsible for ensuring device compatibility, network conditions, and proper software configuration for video and voice calling features.',
          ),
          const SizedBox(height: 12),
          _buildServiceNote(
            'Bhagya G Apps strives for high-quality communication but does not guarantee uninterrupted or error-free service.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Cookies & Tracking Technologies'),
          const SizedBox(height: 12),
          _buildParagraph(
            'We use cookies, web beacons, and similar technologies to enhance your experience, remember preferences, and provide relevant advertising. You can manage cookies through your browser settings.',
          ),
          const SizedBox(height: 16),

          _buildCookieTypes(),
          const SizedBox(height: 24),

          _buildSectionTitle('How We Use Your Information'),
          const SizedBox(height: 16),

          _buildUsageItem(Icons.shopping_cart, 'Providing Products & Services', 'Process payments, fulfill orders, manage accounts'),
          _buildUsageItem(Icons.campaign, 'Marketing & Advertising', 'Send promotional communications, show relevant ads'),
          _buildUsageItem(Icons.security, 'Security & Fraud Prevention', 'Detect and prevent fraudulent activities'),
          _buildUsageItem(Icons.support_agent, 'Customer Support', 'Provide responsive customer service'),

          const SizedBox(height: 24),

          _buildSectionTitle('Information Sharing'),
          const SizedBox(height: 12),
          _buildParagraph(
            'We may share your information with service providers, business partners, affiliates, and as required by law. We do not sell your personal information.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Your Rights'),
          const SizedBox(height: 16),

          _buildRightItem(Icons.visibility, 'Right to Access', 'Request access to your personal information'),
          _buildRightItem(Icons.delete, 'Right to Delete', 'Request deletion of your personal information'),
          _buildRightItem(Icons.edit, 'Right to Correct', 'Request correction of inaccurate information'),
          _buildRightItem(Icons.file_download, 'Right of Portability', 'Receive a copy of your personal information'),

          const SizedBox(height: 24),

          _buildSectionTitle('Data Retention'),
          const SizedBox(height: 12),
          _buildParagraph(
            'We retain your information as required by applicable law. Contact us at info@bhagyag.com if you stop using our Services.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Security'),
          const SizedBox(height: 12),
          _buildParagraph(
            'We implement various security measures to protect your information. However, no security measures are perfect. You provide information at your own risk.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Children\'s Privacy'),
          const SizedBox(height: 12),
          _buildHighlightCard(
            'We do not knowingly collect information from minors. If you are a minor, DO NOT DOWNLOAD OR USE THE SERVICES.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('International Users'),
          const SizedBox(height: 12),
          _buildParagraph(
            'Your information may be transferred, stored, and processed outside your country of residence, including countries that may not have the same data protection laws.',
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Governing Law & Arbitration'),
          const SizedBox(height: 12),
          _buildParagraph(
            'This Policy is governed by the laws of India. Disputes shall be resolved through arbitration in Delhi under the Arbitration & Conciliation Act, 1996.',
          ),
          const SizedBox(height: 32),

          _buildContactCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Colors.grey.shade700,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF7213).withOpacity(0.1),
            const Color(0xFFFF8C42).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFF7213).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: Color(0xFFFF7213),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This Privacy Policy describes how Bhagya G Astro collects, uses, and discloses your personal information when you use our services. By using our Services, you agree to this Privacy Policy.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7213).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7213),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookieTypes() {
    return Column(
      children: [
        _buildCookieItem('Essential Cookies', 'Required for basic site functionality'),
        _buildCookieItem('Analytics Cookies', 'Help us understand how visitors use our site'),
        _buildCookieItem('Marketing Cookies', 'Used to deliver relevant advertisements'),
        _buildCookieItem('Preference Cookies', 'Remember your settings and preferences'),
      ],
    );
  }

  Widget _buildCookieItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7213),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7213).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7213),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF7213),
            const Color(0xFFFF8C42),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7213).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mail_outline,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Have questions about our Privacy Policy?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'info@bhagyag.com',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}