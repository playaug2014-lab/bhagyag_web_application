import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'astrologer_detail_screen.dart';
import 'models/astrologer_model.dart';
import 'models/service_type_model.dart';
import 'models/astrology_type_model.dart';
import 'widgets/filter_bottom_sheet.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  List<AstrologerModel> _astrologers = [];
  List<ServiceTypeModel> _serviceTypes = [];
  List<AstrologyTypeModel> _astrologyTypes = [];
  bool _isLoading = true;
  String? _selectedCategory;

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';
  static const String PROFILE_IMAGE_URL = 'https://test.bhagyag.com/files/profile/';
  static const String SERVICE_TYPE_IMAGE_URL = 'https://test.bhagyag.com/files/userServerType/';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      getAllData(),
      astrolist(),
      getAstrologyType(),
    ]);
  }

  Future<void> getAllData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/User/AstrologerList'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _astrologers = data.map((json) => AstrologerModel.fromJson(json)).toList();
          _selectedCategory = null;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> astrolist() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/UserServiceType'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _serviceTypes = data.map((json) => ServiceTypeModel.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getAstrologyType() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/AstrologyType'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _astrologyTypes = data.map((json) => AstrologyTypeModel.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> categories(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/User/AstrologerCategoris?Categories=$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _astrologers = data.map((json) => AstrologerModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> languagefilter(String language) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/User/LanguageFilter?language=$language'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _astrologers = data.map((json) => AstrologerModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> astrotypefragementlist(String skill) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/User/AstrologerTypeSkills?skill=$skill'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _astrologers = data.map((json) => AstrologerModel.fromJson(json)).toList();
          _selectedCategory = skill;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void showLanguagePopup() {
    final languages = [
      "English", "Hindi", "Kannada", "Assamese", "Marwari",
      "Rajasthani", "Odia", "Tamil", "Telugu", "Marathi",
      "Bengali", "Gujarati", "Malayalam", "Punjabi"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(languages[index]),
                onTap: () {
                  Navigator.pop(context);
                  languagefilter(languages[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        astrologyTypes: _astrologyTypes,
        onApply: (skill) {
          astrotypefragementlist(skill);
        },
      ),
    );
  }

  void onItemClicked(String categoryName) {
    categories(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF5E6),
            const Color(0xFFFFE6D6),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildServiceTypeChips(),
          const SizedBox(height: 12),
          _buildLanguageFilter(),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7213)))
                : _astrologers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No astrologers found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: getAllData, child: const Text('Show All')),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: getAllData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _astrologers.length,
                itemBuilder: (context, index) {
                  return _buildAstrologerCard(_astrologers[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologerCard(AstrologerModel astrologer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0x70FAFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF5722), width: 2)),
                  child: ClipOval(
                    child: astrologer.profileImage.isNotEmpty
                        ? Image.network('$PROFILE_IMAGE_URL${astrologer.profileImage}', fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 40, color: Colors.grey)))
                        : Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 40, color: Colors.grey)),
                  ),
                ),
                if (astrologer.status.toLowerCase() == 'online')
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(astrologer.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 20, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF797676)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(astrologer.specializedIn, style: const TextStyle(fontSize: 14, color: Color(0xFF797676)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.language, size: 18, color: Color(0xFF797676)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(astrologer.knownLanguages, style: const TextStyle(fontSize: 14, color: Color(0xFF797676)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(5, (index) => Icon(index < astrologer.rating.floor() ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
                      const SizedBox(width: 5),
                      const Text('Exp:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF797676))),
                      const SizedBox(width: 6),
                      Text(astrologer.experience, style: const TextStyle(fontSize: 13, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, size: 14, color: Colors.black),
                          Text('${astrologer.videoCallPerMinuters}/min', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AstrologerDetailScreen(
                                astrologer: astrologer,
                                profileImageUrl: PROFILE_IMAGE_URL,
                                serviceType: 'video',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: astrologer.status.toLowerCase() == 'online' ? const Color(0xFFFF7213) : const Color(0xFF797676),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(width: 35, height: 35, padding: const EdgeInsets.only(left: 9), child: const Icon(Icons.videocam, size: 18, color: Colors.white)),
                              const SizedBox(width: 6),
                              const Text('Video', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeChips() {
    if (_serviceTypes.isEmpty) return const SizedBox(height: 45);

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _serviceTypes.length,
        itemBuilder: (context, index) {
          final serviceType = _serviceTypes[index];
          final isSelected = _selectedCategory == serviceType.name;

          return GestureDetector(
            onTap: () {
              if (serviceType.name.toLowerCase() == 'filter') {
                _showFilterBottomSheet();
              } else {
                onItemClicked(serviceType.name);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF7213) : const Color(0xFFFA4033).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFAF7F6), width: 1),
              ),
              child: Row(
                children: [
                  if (serviceType.imageUrl.isNotEmpty)
                    Image.network(
                      '$SERVICE_TYPE_IMAGE_URL${serviceType.imageUrl}',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, size: 20, color: Colors.white),
                    )
                  else
                    const Icon(Icons.star, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(serviceType.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: showLanguagePopup,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFA4033).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFAF7F6), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.language, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Language', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}