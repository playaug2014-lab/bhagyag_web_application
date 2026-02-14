import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Profile Service Fragment - Astrologer Performance & Reviews
/// Shows:
/// - Performance ratings (Chat, Call, Video)
/// - User reviews list
class ProfileServiceFragment extends StatefulWidget {
  final String? userId;

  const ProfileServiceFragment({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfileServiceFragment> createState() => _ProfileServiceFragmentState();
}

class _ProfileServiceFragmentState extends State<ProfileServiceFragment> {
  bool _isLoading = true;

  // Performance ratings
  double _chatRating = 0.0;
  double _callRating = 0.0;
  double _videoCallRating = 0.0;
  String _fullName = '';

  // User reviews
  List<UserReview> _reviews = [];

  static const String BASE_URL = 'https://test.bhagyag.com';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? widget.userId ?? '';

    if (userId.isEmpty) {
      _showError('User ID not found');
      return;
    }

    await Future.wait([
      _fetchPerformanceRating(userId),
      _fetchUserReviews(userId),
    ]);
  }

  /// Fetch Performance Rating
  Future<void> _fetchPerformanceRating(String astrologerId) async {
    try {
      final url = Uri.parse('$BASE_URL/api/UserReview/AstrologerPerforms/$astrologerId');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _chatRating = (data['chatRating'] ?? 0.0).toDouble();
          _callRating = (data['voiceCallRating'] ?? 0.0).toDouble();
          _videoCallRating = (data['videoCallRating'] ?? 0.0).toDouble();
          _fullName = data['fullName'] ?? '';
        });

        debugPrint('✅ Performance rating loaded');
      } else {
        debugPrint('❌ Failed to load rating: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Performance rating error: $e');
    }
  }

  /// Fetch User Reviews
  Future<void> _fetchUserReviews(String astrologerId) async {
    try {
      final url = Uri.parse('$BASE_URL/api/UserReview?AstrologerId=$astrologerId');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> recordList = jsonData['record'] ?? [];

        setState(() {
          _reviews = recordList
              .map((json) => UserReview.fromJson(json))
              .toList();
          _isLoading = false;
        });

        debugPrint('✅ Loaded ${_reviews.length} reviews');
      } else {
        setState(() => _isLoading = false);
        debugPrint('❌ Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ User reviews error: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Astrologer Performance',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFD6E62),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance Ratings Card
              _buildPerformanceCard(),

              const SizedBox(height: 24),

              // Reviews Section
              _buildReviewsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Ratings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Chat Rating
            _buildRatingRow(
              icon: Icons.chat,
              label: 'Chat',
              rating: _chatRating,
            ),

            const Divider(height: 24),

            // Call Rating
            _buildRatingRow(
              icon: Icons.call,
              label: 'Call',
              rating: _callRating,
            ),

            const Divider(height: 24),

            // Video Call Rating
            _buildRatingRow(
              icon: Icons.videocam,
              label: 'Video Call',
              rating: _videoCallRating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow({
    required IconData icon,
    required String label,
    required double rating,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFD6E62),
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD6E62),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                color: Color(0xFFFD6E62),
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_reviews.isNotEmpty)
              Text(
                '${_reviews.length} reviews',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        _reviews.isEmpty
            ? _buildEmptyReviews()
            : Column(
          children: _reviews
              .map((review) => _buildReviewCard(review))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews from users will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(UserReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: review.profileImage.isNotEmpty
                      ? NetworkImage('https://test.bhagyag.com/files/profile/${review.profileImage}')
                      : null,
                  child: review.profileImage.isEmpty
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.onDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFD6E62),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFD6E62),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Review text
            if (review.reviewText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.reviewText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${(difference.inDays / 365).floor()} years ago';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

/// User Review Model
class UserReview {
  final String fullName;
  final String onDate;
  final String profileImage;
  final double rating;
  final String reviewText;
  final String userId;

  UserReview({
    required this.fullName,
    required this.onDate,
    required this.profileImage,
    required this.rating,
    required this.reviewText,
    required this.userId,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      fullName: json['fullName'] ?? '',
      onDate: json['onDate'] ?? '',
      profileImage: json['profileImage'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewText: json['reviewText'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'onDate': onDate,
      'profileImage': profileImage,
      'rating': rating,
      'reviewText': reviewText,
      'userId': userId,
    };
  }
}