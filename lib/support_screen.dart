import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _phoneNumber = '';
  String _emailAddress = '';
  bool _isLoading = true;
  String? _responseMessage;
  bool _isSuccess = false;

  static const String BASE_URL = 'https://test.bhagyag.com';

  @override
  void initState() {
    super.initState();
    _fetchSupportData();
  }

  Future<void> _fetchSupportData() async {
    try {
      final url = Uri.parse('$BASE_URL/api/Support');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _phoneNumber = data[0]['phoneNo'] ?? '';
            _emailAddress = data[0]['emailAddress'] ?? '';
            _isLoading = false;
          });
          debugPrint('✅ Support data loaded');
        }
      } else {
        setState(() => _isLoading = false);
        debugPrint('❌ Failed to load support data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Support data error: $e');
    }
  }

  Future<void> _makePhoneCall() async {
    final uri = Uri.parse('tel:$_phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:$_emailAddress');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showReasonDialog() {
    final reasonController = TextEditingController();
    int charCount = 0;
    const maxChars = 250;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Reason for: Technical Problem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reasonController,
                  maxLength: maxChars,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe your issue...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setDialogState(() {
                      charCount = text.length;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '$charCount/$maxChars',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateResponseMessage('Request cancelled.', false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reason cannot be empty')),
                    );
                  } else {
                    Navigator.pop(context);
                    _sendUserRequest('support', reason);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                ),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendUserRequest(String requestType, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        _updateResponseMessage('User ID not found. Please log in again.', false);
        return;
      }

      final url = Uri.parse('$BASE_URL/api/CustomerSupport/submit-request');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'reason': reason,
          'requestType': requestType,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateResponseMessage('Support request submitted successfully!', true);
      } else {
        final errorBody = response.body;
        _updateResponseMessage(errorBody.isNotEmpty ? errorBody : 'Failed to submit request', false);
      }
    } catch (e) {
      _updateResponseMessage('Network error: ${e.toString()}', false);
      debugPrint('❌ Request error: $e');
    }
  }

  void _updateResponseMessage(String message, bool isSuccess) {
    setState(() {
      _responseMessage = message;
      _isSuccess = isSuccess;
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _responseMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Support Chat',
          style: TextStyle(
            color: Color(0xFFFF5722),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dateFormat.format(now),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Chat Bubble
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hi, Please select the option that best describes your concern 😉',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          timeFormat.format(now),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Divider(height: 24),

                      // Option Button
                      InkWell(
                        onTap: () {
                          setState(() => _responseMessage = null);
                          _showReasonDialog();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            'I am experiencing a technical problem',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Support Call Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Support Call',
                    style: TextStyle(
                      color: const Color(0xFFFF5722),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Info
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _makePhoneCall,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Color(0xFFFF5722),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _phoneNumber,
                                    style: const TextStyle(
                                      color: Color(0xFFFF5722),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _sendEmail,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Color(0xFFFF5722),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _emailAddress,
                                    style: const TextStyle(
                                      color: Color(0xFFFF5722),
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Response Message
          if (_responseMessage != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _responseMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}