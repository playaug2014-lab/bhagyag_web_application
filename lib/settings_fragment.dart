import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'support_screen.dart';
import 'language_selection_screen.dart'; // Add this import

/// Settings Fragment - App Settings & Options
/// Features:
/// - Notifications toggle
/// - Payment report
/// - Privacy policy, About us, Terms
/// - Support
/// - Social media links
/// - Logout
class SettingsFragment extends StatefulWidget {
  const SettingsFragment({Key? key}) : super(key: key);

  @override
  State<SettingsFragment> createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  List<SocialMediaItem> _socialMediaLinks = [];

  static const String BASE_URL = 'https://test.bhagyag.com';
  static const String APP_VERSION = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchSocialMediaLinks();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  /// Fetch Social Media Links from API
  Future<void> _fetchSocialMediaLinks() async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$BASE_URL/api/SocialMedia');
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _socialMediaLinks = jsonList
              .map((json) => SocialMediaItem.fromJson(json))
              .toList();
          _isLoading = false;
        });

        debugPrint('✅ Loaded ${_socialMediaLinks.length} social media links');
      } else {
        setState(() => _isLoading = false);
        debugPrint('❌ Failed to load social media: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Social media fetch error: $e');
    }
  }

  /// Open URL in browser
  Future<void> _openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showError('Could not open link');
      }
    } catch (e) {
      _showError('Invalid URL');
      debugPrint('URL launch error: $e');
    }
  }

  /// Navigate to page
  void _navigateToPage(String page) {
    String url = '';

    switch (page) {
      case 'privacy':
        url = 'https://bhagyag.com/pages/privacy-policy';
        break;
      case 'about':
        url = 'https://bhagyag.com/pages/about-us';
        break;
      case 'terms':
        url = 'https://bhagyag.com/pages/terms-of-service';
        break;
      case 'support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupportScreen()),
        );
        return;
      case 'report':
        _showInfo('Payment report feature coming soon');
        return;
    }

    if (url.isNotEmpty) {
      _openUrl(url);
    }
  }

  /// Logout
  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFD6E62)),
      ),
    );

    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      debugPrint('✅ Logout successful');

      // Hide loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Logged out successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Wait for snackbar
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to language selection screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      debugPrint('❌ Logout error: $e');
      _showError('Logout failed. Please try again.');
    }
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFD6E62),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 8),
            _buildNotificationSwitch(),

            const SizedBox(height: 16),

            // Payment Report
            _buildSettingsTile(
              icon: Icons.assessment,
              title: 'Payment Report',
              onTap: () => _navigateToPage('report'),
            ),

            const Divider(height: 32),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () => _navigateToPage('privacy'),
            ),

            _buildSettingsTile(
              icon: Icons.info,
              title: 'About Us',
              onTap: () => _navigateToPage('about'),
            ),

            _buildSettingsTile(
              icon: Icons.description,
              title: 'Terms and Conditions',
              onTap: () => _navigateToPage('terms'),
            ),

            _buildSettingsTile(
              icon: Icons.support_agent,
              title: 'Support',
              iconColor: Colors.blue,
              onTap: () => _navigateToPage('support'),
            ),

            const Divider(height: 32),

            // Social Media Section
            if (_socialMediaLinks.isNotEmpty) ...[
              _buildSocialMediaSection(),
              const SizedBox(height: 24),
            ],

            // App Version
            Center(
              child: Text(
                'App ver $APP_VERSION',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            _buildLogoutButton(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() => _notificationsEnabled = value);
          _saveNotificationSetting(value);
        },
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        secondary: const Icon(
          Icons.notifications,
          color: Color(0xFFFD6E62),
        ),
        activeColor: const Color(0xFFFD6E62),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? const Color(0xFFFD6E62),
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Connect With Us'),
        const SizedBox(height: 16),

        _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD700),
          ),
        )
            : SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _socialMediaLinks.length,
            itemBuilder: (context, index) {
              final link = _socialMediaLinks[index];
              return _buildSocialMediaCard(link);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaCard(SocialMediaItem item) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openUrl(item.linkUrl),
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Social Media Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: item.linkLogo.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    '$BASE_URL${item.linkLogo}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getSocialMediaIcon(item.linkName),
                        color: const Color(0xFFFD6E62),
                      );
                    },
                  ),
                )
                    : Icon(
                  _getSocialMediaIcon(item.linkName),
                  color: const Color(0xFFFD6E62),
                ),
              ),
              const SizedBox(height: 8),
              // Social Media Name
              Text(
                item.linkName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSocialMediaIcon(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('facebook')) return Icons.facebook;
    if (nameLower.contains('twitter') || nameLower.contains('x')) return Icons.close; // X icon
    if (nameLower.contains('instagram')) return Icons.camera_alt;
    if (nameLower.contains('youtube')) return Icons.play_circle;
    if (nameLower.contains('linkedin')) return Icons.business;
    if (nameLower.contains('whatsapp')) return Icons.chat;
    if (nameLower.contains('telegram')) return Icons.send;

    return Icons.link;
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

/// Social Media Item Model
class SocialMediaItem {
  final int id;
  final String linkLogo;
  final String linkName;
  final String linkUrl;

  SocialMediaItem({
    required this.id,
    required this.linkLogo,
    required this.linkName,
    required this.linkUrl,
  });

  factory SocialMediaItem.fromJson(Map<String, dynamic> json) {
    return SocialMediaItem(
      id: json['id'] ?? 0,
      linkLogo: json['linkLogo'] ?? '',
      linkName: json['linkName'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkLogo': linkLogo,
      'linkName': linkName,
      'linkUrl': linkUrl,
    };
  }
}