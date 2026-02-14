import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Shop Screen - Opens BhagyaG website in Safari/Chrome
/// NO WebView = NO iOS version issues!
class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<ShopCategory> _categories = [
    ShopCategory(
      name: 'Gemstones',
      icon: '💎',
      url: 'https://bhagyag.com/collections/gemstones',
      description: 'Natural certified gemstones',
      color: const Color(0xFFE91E63),
    ),
    ShopCategory(
      name: 'Rudraksha',
      icon: '📿',
      url: 'https://bhagyag.com/collections/rudraksha',
      description: 'Lab certified Nepali Rudraksha',
      color: const Color(0xFF8B4513),
    ),
    ShopCategory(
      name: 'Crystal Bracelets',
      icon: '✨',
      url: 'https://bhagyag.com/collections/bracelets',
      description: 'Healing crystal bracelets',
      color: const Color(0xFF9C27B0),
    ),
    ShopCategory(
      name: 'Idols',
      icon: '🙏',
      url: 'https://bhagyag.com/collections/idols',
      description: 'Sacred deity idols',
      color: const Color(0xFFFF9800),
    ),
    ShopCategory(
      name: 'Yantras',
      icon: '🕉️',
      url: 'https://bhagyag.com/collections/yantra',
      description: 'Powerful Vedic Yantras',
      color: const Color(0xFF00BCD4),
    ),
    ShopCategory(
      name: 'Pendants',
      icon: '🔮',
      url: 'https://bhagyag.com/collections/pendent',
      description: 'Crystal & stone pendants',
      color: const Color(0xFF4CAF50),
    ),
    ShopCategory(
      name: 'Mala',
      icon: '📿',
      url: 'https://bhagyag.com/collections/mala',
      description: 'Prayer beads & malas',
      color: const Color(0xFFFF5722),
    ),
    ShopCategory(
      name: 'Tree',
      icon: '🌳',
      url: 'https://bhagyag.com/collections/tree',
      description: 'Crystal & gemstone trees',
      color: const Color(0xFF4CAF50),
    ),
    ShopCategory(
      name: 'Hanging',
      icon: '🎐',
      url: 'https://bhagyag.com/collections/hanging',
      description: 'Wall & door hangings',
      color: const Color(0xFF03A9F4),
    ),
  ];

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Could not open website');
      }
    } catch (e) {
      print('Error opening URL: $e');
      _showSnackBar('Error opening website');
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/919266233655?text=Hello, I need astrology consultation',
    );
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open WhatsApp');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      _showSnackBar('Error opening WhatsApp');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri.parse('tel:+919266233655');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnackBar('Could not make phone call');
      }
    } catch (e) {
      print('Error launching phone: $e');
      _showSnackBar('Error making call');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF7213),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Simple structure - no extra constraints since parent handles it
    return Container(
      color: const Color(0xFFFFF5E6),
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedBanner(),
                    SizedBox(height: isWeb ? 32 : 24),
                    _buildCategoryHeader(),
                    SizedBox(height: isWeb ? 20 : 16),
                    _buildCategoriesGrid(),
                    SizedBox(height: isWeb ? 40 : 32),
                    _buildAstrologerSection(),
                    SizedBox(height: isWeb ? 40 : 32),
                    _buildFeaturesSection(),
                    SizedBox(height: isWeb ? 120 : 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24 : 16,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFF7213),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Shop Spiritual Products',
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: Icon(
                Icons.language,
                color: Colors.white,
                size: isWeb && screenWidth > 600 ? 26 : 24,
              ),
              onPressed: () => _openUrl('https://bhagyag.com'),
              tooltip: 'Visit Website',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = isWeb && screenWidth > 600 ? 190.0 : 160.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _openUrl('https://bhagyag.com'),
        child: Container(
          margin: EdgeInsets.all(isWeb ? 24 : 16),
          height: bannerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF7213),
                Color(0xFFFF8C42),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: isWeb ? 8 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.shop,
                    size: isWeb && screenWidth > 600 ? 120 : 130,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isWeb ? 24 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // ✅ Added this
                    children: [
                      Text(
                        '🛍️ Shop Now',
                        style: TextStyle(
                          fontSize: isWeb && screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1, // ✅ Added this
                        overflow: TextOverflow.ellipsis, // ✅ Added this
                      ),
                      SizedBox(height: isWeb ? 6 : 4), // ✅ Reduced spacing
                      Flexible( // ✅ Wrapped in Flexible
                        child: Text(
                          'Browse 1000+ Authentic\nSpiritual Products',
                          style: TextStyle(
                            fontSize: isWeb && screenWidth > 600 ? 16 : 14,
                            color: Colors.white,
                          ),
                          maxLines: 2, // ✅ Added this
                          overflow: TextOverflow.ellipsis, // ✅ Added this
                        ),
                      ),
                      SizedBox(height: isWeb ? 8 : 3), // ✅ Reduced spacing
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 20 : 16,
                          vertical: isWeb ? 10 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Visit Store →',
                          style: TextStyle(
                            fontSize: isWeb && screenWidth > 600 ? 15 : 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF7213),
                          ),
                          maxLines: 1, // ✅ Added this
                          overflow: TextOverflow.ellipsis, // ✅ Added this
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Shop by Category',
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: () => _openUrl('https://bhagyag.com'),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: isWeb && screenWidth > 600 ? 16 : 14,
                  color: const Color(0xFFFF7213),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive column count
    int crossAxisCount;
    if (isWeb && screenWidth > 800) {
      crossAxisCount = 4;
    } else if (isWeb && screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 3;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.85,
          crossAxisSpacing: isWeb ? 16 : 12,
          mainAxisSpacing: isWeb ? 16 : 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(ShopCategory category) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _openUrl(category.url),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: category.color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: isWeb ? 6 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: TextStyle(
                  fontSize: isWeb && screenWidth > 600 ? 46 : 40,
                ),
              ),
              SizedBox(height: isWeb ? 10 : 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: isWeb && screenWidth > 600 ? 15 : 13,
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      padding: EdgeInsets.all(isWeb ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isWeb ? 8 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: isWeb && screenWidth > 600 ? 70 : 60,
            color: const Color(0xFFFF7213),
          ),
          SizedBox(height: isWeb ? 20 : 16),
          Text(
            'Need Help Choosing?',
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          Text(
            'Talk to our expert astrologers for\npersonalized product recommendations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 16 : 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          SizedBox(height: isWeb ? 24 : 20),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: Icon(
                      Icons.chat,
                      size: isWeb && screenWidth > 600 ? 22 : 20,
                    ),
                    label: Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: isWeb && screenWidth > 600 ? 16 : 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb && screenWidth > 600 ? 16 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isWeb ? 16 : 12),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: _launchPhone,
                    icon: Icon(
                      Icons.phone,
                      size: isWeb && screenWidth > 600 ? 22 : 20,
                    ),
                    label: Text(
                      'Call Now',
                      style: TextStyle(
                        fontSize: isWeb && screenWidth > 600 ? 16 : 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7213),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb && screenWidth > 600 ? 16 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose BhagyaG?',
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: isWeb ? 20 : 16),
          _buildFeatureItem(
            Icons.verified,
            'Lab Certified',
            'All products are lab tested and certified',
          ),
          _buildFeatureItem(
            Icons.local_shipping,
            'Free Shipping',
            'On orders above ₹1000',
          ),
          _buildFeatureItem(
            Icons.star,
            'Trusted by 1M+',
            '4.8/5 customer satisfaction rating',
          ),
          _buildFeatureItem(
            Icons.support_agent,
            'Expert Support',
            'Certified astrologers available',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: isWeb && screenWidth > 600 ? 56 : 50,
            height: isWeb && screenWidth > 600 ? 56 : 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7213).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7213),
              size: isWeb && screenWidth > 600 ? 28 : 24,
            ),
          ),
          SizedBox(width: isWeb ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isWeb && screenWidth > 600 ? 15 : 13,
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
}

class ShopCategory {
  final String name;
  final String icon;
  final String url;
  final String description;
  final Color color;

  ShopCategory({
    required this.name,
    required this.icon,
    required this.url,
    required this.description,
    required this.color,
  });
}