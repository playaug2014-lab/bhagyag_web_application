import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'language_provider.dart';
import 'app_translations.dart';
import 'language_toggle_button.dart';

// AI Astrology Chat Screen - Fetches API key from backend
class AIAstrologyChatScreen extends StatefulWidget {
  final String userId;

  const AIAstrologyChatScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AIAstrologyChatScreen> createState() => _AIAstrologyChatScreenState();
}

class _AIAstrologyChatScreenState extends State<AIAstrologyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _userBirthChart;

  // ✅ NEW: Dynamic API key fetched from backend
  String? _apiKey;
  bool _isLoadingApiKey = true;
  String? _apiKeyError;

  // Backend API endpoint to get Gemini key
  static const String _apiKeyUrl = 'https://test.bhagyag.com/api/BhagyagAIToken';

  // Gemini API URL
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';

  @override
  void initState() {
    super.initState();
    print('🔵 AIAstrologyChatScreen initialized');
    print('🔵 Gemini API URL: $_geminiApiUrl');
    print('🔵 Backend API URL: $_apiKeyUrl');
    _fetchApiKey(); // Fetch API key first
    _loadBirthChart();
  }

  // ✅ NEW: Fetch API key from your backend
  Future<void> _fetchApiKey() async {
    try {
      print('🔑 Fetching API key from backend...');

      final response = await http.get(Uri.parse(_apiKeyUrl));

      print('📥 Backend response status: ${response.statusCode}');
      print('📥 Backend response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['key'] != null && data['key'].isNotEmpty) {
          setState(() {
            _apiKey = data['key'];
            _isLoadingApiKey = false;
          });
          print('✅ API key fetched successfully');
          print('🔵 API Key (first 15 chars): ${_apiKey!.substring(0, 15)}...');
        } else {
          throw Exception('No key found in response');
        }
      } else {
        throw Exception('Failed to fetch API key: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching API key: $e');
      setState(() {
        _isLoadingApiKey = false;
        _apiKeyError = e.toString();
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load AI configuration: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    final birthChartJson = prefs.getString('user_birth_chart_${widget.userId}');

    if (birthChartJson != null) {
      setState(() {
        _userBirthChart = jsonDecode(birthChartJson);
      });
      print('✅ Birth chart loaded: ${_userBirthChart!['name']}');
      _addWelcomeMessage();
    } else {
      print('⚠️ No birth chart found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetupDialog();
      });
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFF7213)),
            SizedBox(width: 12),
            Text('Setup Your Birth Chart'),
          ],
        ),
        content: const Text(
          'To get personalized AI astrology insights, please set up your birth chart first.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIBirthChartSetupScreen(
                    userId: widget.userId,
                  ),
                ),
              ).then((_) => _loadBirthChart());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7213),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Setup Now'),
          ),
        ],
      ),
    );
  }

  void _addWelcomeMessage() {
    if (_userBirthChart == null) return;

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLanguage;
    final userName = _userBirthChart!['name'] ?? (lang == 'hi' ? 'वहाँ' : 'there');

    final welcomeText = AppTranslations.get('ai_chat_welcome', lang, params: {
      'name': userName,
      'sunSign': _userBirthChart!['sunSign'] ?? '',
      'moonSign': _userBirthChart!['moonSign'] ?? (lang == 'hi' ? 'अज्ञात' : 'Unknown'),
      'dob': _userBirthChart!['dob'] ?? '',
      'tob': _userBirthChart!['tob'] ?? (lang == 'hi' ? 'अज्ञात' : 'Unknown'),
      'pob': _userBirthChart!['pob'] ?? (lang == 'hi' ? 'अज्ञात' : 'Unknown'),
    });

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _buildContext() {
    if (_userBirthChart == null) return '';

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLanguage;
    final recentMessages = _messages.length > 6
        ? _messages.sublist(_messages.length - 6)
        : _messages;

    String contextText = lang == 'hi'
        ? """
आप एक अनुभवी, दयालु ज्योतिषी हैं।
उपयोगकर्ता की कुंडली: सूर्य राशि ${_userBirthChart!['sunSign']}, चंद्र राशि ${_userBirthChart!['moonSign'] ?? 'अज्ञात'}
केवल हिंदी में 2-3 वाक्यों में उत्तर दें।
"""
        : """
You are an experienced astrologer.
User's chart: Sun ${_userBirthChart!['sunSign']}, Moon ${_userBirthChart!['moonSign'] ?? 'Unknown'}
Answer in English in 2-3 sentences only.
""";

    return contextText;
  }

  Future<void> _sendMessage() async {
    // ✅ Check if API key is loaded
    if (_apiKey == null) {
      print('⚠️ Cannot send: API key not loaded yet');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, loading AI configuration...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty || _userBirthChart == null) {
      print('⚠️ Cannot send: empty message or no birth chart');
      return;
    }

    final userMessage = _messageController.text.trim();
    print('📤 Sending message: $userMessage');

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final conversationContext = _buildContext();
      final fullPrompt = '$conversationContext\n\nUser asks: $userMessage';

      print('📝 Full prompt length: ${fullPrompt.length} characters');

      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': fullPrompt}
            ]
          }
        ]
      };

      print('📦 Request prepared');
      print('🌐 Sending POST to Gemini API...');

      // ✅ Use dynamically fetched API key
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Response decoded successfully');

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {

          final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
          print('✅ AI Response extracted: ${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}...');

          if (aiResponse != null && aiResponse.isNotEmpty) {
            setState(() {
              _messages.add(ChatMessage(
                text: aiResponse,
                isUser: false,
                timestamp: DateTime.now(),
              ));
              _isLoading = false;
            });
            print('✅ Message added to UI');
          } else {
            throw Exception('Empty AI response');
          }
        } else {
          print('❌ Invalid response structure');
          throw Exception('Invalid response structure from API');
        }
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please wait a moment.');
      } else if (response.statusCode == 400) {
        print('❌ Bad Request (400)');
        print('Response: ${response.body}');
        throw Exception('Bad request: ${response.body}');
      } else if (response.statusCode == 404) {
        print('❌ Not Found (404)');
        print('Response: ${response.body}');
        throw Exception('Model not found');
      } else {
        print('❌ API Error ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Exception caught: $e');
      print('Stack trace: $stackTrace');

      String errorMessage = "Sorry, I encountered an error. Please try again.";

      if (e.toString().contains('Rate limit')) {
        errorMessage = "Too many requests. Please wait a moment.";
      } else if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (e.toString().contains('401')) {
        errorMessage = "API key error. Please check configuration.";
      } else if (e.toString().contains('404')) {
        errorMessage = "Model not found error. Please contact support.";
      } else if (e.toString().contains('400')) {
        errorMessage = "Request error. Please try a shorter message.";
      }

      setState(() {
        _messages.add(ChatMessage(
          text: errorMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;

    // ✅ Show loading if API key is being fetched
    if (_isLoadingApiKey) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5E6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7213),
          title: const Text(
            'AI Astrology Chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFF7213),
              ),
              SizedBox(height: 16),
              Text(
                'Loading AI configuration...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Show error if API key fetch failed
    if (_apiKeyError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5E6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7213),
          title: const Text(
            'AI Astrology Chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Load AI Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _apiKeyError!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoadingApiKey = true;
                      _apiKeyError = null;
                    });
                    _fetchApiKey();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7213),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        title: Text(
          AppTranslations.get('ai_chat_title', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_userBirthChart != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIBirthChartSetupScreen(
                      userId: widget.userId,
                    ),
                  ),
                ).then((_) => _loadBirthChart());
              },
            ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: _userBirthChart == null
          ? _buildSetupPrompt()
          : Column(
        children: [
          // Birth Chart Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7213).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('your_birth_chart', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_userBirthChart!['name']} • ${_userBirthChart!['sunSign']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7213)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslations.get('ai_thinking', lang),
                    style: const TextStyle(color: Color(0xFFFF7213)),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.black87),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: AppTranslations.get('type_message', lang),
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Setup Your Birth Chart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter your birth details to get personalized AI astrology insights.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIBirthChartSetupScreen(
                      userId: widget.userId,
                    ),
                  ),
                ).then((_) => _loadBirthChart());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7213),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Setup Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFFFF7213)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7213).withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.person, color: Color(0xFFFF7213), size: 20),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Birth Chart Setup Screen (keeping your existing implementation)
class AIBirthChartSetupScreen extends StatefulWidget {
  final String userId;

  const AIBirthChartSetupScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AIBirthChartSetupScreen> createState() => _AIBirthChartSetupScreenState();
}

class _AIBirthChartSetupScreenState extends State<AIBirthChartSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final prefs = await SharedPreferences.getInstance();
    final birthChartJson = prefs.getString('user_birth_chart_${widget.userId}');

    if (birthChartJson != null) {
      final data = jsonDecode(birthChartJson);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _placeController.text = data['pob'] ?? '';

        if (data['dob'] != null) {
          _selectedDate = DateTime.parse(data['dob']);
        }

        if (data['tob'] != null) {
          final timeParts = data['tob'].split(':');
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      });
    }
  }

  Future<void> _saveBirthChart() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }
    if (_selectedTime == null) {
      _showError('Please select your time of birth');
      return;
    }
    if (_placeController.text.trim().isEmpty) {
      _showError('Please enter your place of birth');
      return;
    }

    final birthChart = {
      'name': _nameController.text.trim(),
      'dob': _selectedDate!.toIso8601String().split('T')[0],
      'tob': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      'pob': _placeController.text.trim(),
      'sunSign': _calculateSunSign(_selectedDate!),
      'moonSign': _calculateMoonSign(_selectedDate!),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_birth_chart_${widget.userId}', jsonEncode(birthChart));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Birth chart saved successfully!'),
          backgroundColor: Color(0xFFFF7213),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _calculateSunSign(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini ♊';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra ♎';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius ♐';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn ♑';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius ♒';
    return 'Pisces ♓';
  }

  String _calculateMoonSign(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final signs = ['Aries ♈', 'Taurus ♉', 'Gemini ♊', 'Cancer ♋', 'Leo ♌',
      'Virgo ♍', 'Libra ♎', 'Scorpio ♏', 'Sagittarius ♐',
      'Capricorn ♑', 'Aquarius ♒', 'Pisces ♓'];
    return signs[(dayOfYear * 12 / 365).floor()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        title: const Text('Setup Birth Chart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            const Text('Full Name *'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 16),

            // Date field
            const Text('Date of Birth *'),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time field
            const Text('Time of Birth *'),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedTime == null
                      ? 'Select time'
                      : _selectedTime!.format(context),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Place field
            const Text('Place of Birth *'),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(hintText: 'City, Country'),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBirthChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7213),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Birth Chart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }
}