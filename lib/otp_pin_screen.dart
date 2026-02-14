// otp_pin_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_dashboard.dart';

class OtpPinScreen extends StatefulWidget {
  final String phoneNumber; // E.164, e.g. +9198xxxxxx
  final String verificationId;
  final int? resendToken;
  final bool isForRegistration;
  final Map<String, dynamic>? userData;

  const OtpPinScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.isForRegistration = false,
    this.userData,
  }) : super(key: key);

  @override
  State<OtpPinScreen> createState() => _OtpPinScreenState();
}

class _OtpPinScreenState extends State<OtpPinScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  late String _currentVerificationId;
  int? _currentResendToken;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';
  static const String USER_REGISTER_ENDPOINT = '/User';

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _currentResendToken = widget.resendToken;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _showError('Please enter 6 digit OTP');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: code,
      );

      await _auth.signInWithCredential(credential);

      if (widget.isForRegistration && widget.userData != null) {
        final result = await _registerUser(widget.userData!);

        if (result != null && result['record'] != null) {
          await _saveUserSession(result['record']);
          _showSuccess('Registration successful!');

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(
                userName: result['record']['fullName'] ?? 'User',
                walletAmount: '₹0',
              ),
            ),
                (route) => false,
          );
        } else {
          _showError('Registration failed. Please try again.');
        }
      } else {
        _showSuccess('OTP Verified');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Invalid OTP');
    } catch (e) {
      _showError('Verification failed');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _currentResendToken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          _showError(e.message ?? 'Failed to resend OTP');
          setState(() => _isResending = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _currentVerificationId = verificationId;
          _currentResendToken = resendToken;
          setState(() => _isResending = false);
          _showSuccess('OTP resent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      _showError('Failed to resend OTP');
      setState(() => _isResending = false);
    }
  }

  Future<Map<String, dynamic>?> _registerUser(
      Map<String, dynamic> user) async {
    try {
      final url = Uri.parse('$API_BASE_URL$USER_REGISTER_ENDPOINT');

      // Dynamic regDate in required format: yyyy-MM-ddTHH:mm:ss
      final String regDate =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());

      final body = {
        "fullName": user["name"] ?? "",
        "profileImage": "string",
        "emailId": user["email"] ?? "",
        "phoneNo": user["phone"] ?? "",
        "password": user["password"] ?? "",
        "dob": user["dob"] ?? "",
        "gender": user["gender"] ?? "",
        "placeOfBirth": user["pob"] ?? "",
        "currentAddress": user["address"] ?? "",
        "district": user["district"] ?? "",
        "state": user["state"] ?? "",
        "country": "India",
        "pincode": user["pincode"] ?? "",
        "isMobileVerified": "Y", // ✅ after OTP success
        "isEmailVerified": "N",
        "regDate": regDate,
        "userType": "USER",
        "userStatus": "Active",
        "firebaseID": "",
        "chatStatus": "",
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Registration error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration exception: $e');
      return null;
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userData['userId'] ?? '');
    await prefs.setString('fullName', userData['fullName'] ?? '');
    await prefs.setString('phoneNo', userData['phoneNo'] ?? '');
    await prefs.setString('uniqueUserID', userData['uniqueUserID'] ?? '');
    await prefs.setString('userType', userData['userType'] ?? 'USER');
    await prefs.setString('email', userData['emailId'] ?? '');
    await prefs.setString('gender', userData['gender'] ?? 'Male');
  }

  @override
  Widget build(BuildContext context) {
    // Simple UI, matching your gradient style (new screen, no conflict)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5E6),
              Color(0xFFFFE6D6),
              Color(0xFFFFD4C4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'OTP sent to',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.phoneNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Enter 6 digit OTP',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isVerifying
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Verify & Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isResending ? null : _resendOtp,
              child: _isResending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                'Resend OTP',
                style: TextStyle(
                  color: Color(0xFFC32F00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
