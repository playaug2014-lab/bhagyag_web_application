// otp_screen_updated.dart - WITH RESET PASSWORD NAVIGATION

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'reset_password_screen.dart'; // Import the reset password screen

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isForRegistration;
  final bool isForPasswordReset;
  final Function? onVerificationComplete;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.isForRegistration,
    required this.isForPasswordReset,
    this.onVerificationComplete,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  String? _verificationId;
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOTP() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      print('📞 Starting phone verification for: +91${widget.phoneNumber}');

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${widget.phoneNumber}',
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed');
          try {
            await _auth.signInWithCredential(credential);
            _handleVerificationSuccess();
          } catch (e) {
            print('❌ Auto-verification sign-in failed: $e');
            if (mounted) setState(() => _isLoading = false);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => _isLoading = false);

          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('❌ PHONE VERIFICATION FAILED');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('Error Code: ${e.code}');
          print('Error Message: ${e.message}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later';
          } else if (e.code == 'network-request-failed') {
            errorMessage = 'Network error. Please check your connection';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again later';
          } else if (e.code == 'internal-error') {
            errorMessage = 'Internal error: ${e.message ?? "Unknown"}';
          }

          _showError(errorMessage);
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('✅ OTP SENT SUCCESSFULLY');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('Verification ID: $verificationId');
          print('Phone Number: +91${widget.phoneNumber}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });

          _showSuccess('OTP sent successfully to +91${widget.phoneNumber}');
          _startTimer();
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          print('⏱️ Auto retrieval timeout: $verificationId');
          _verificationId = verificationId;
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ EXCEPTION IN SEND OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Exception: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      setState(() => _isLoading = false);
      _showError('Failed to send OTP. Please try again');
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Please enter complete 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showError('Verification ID not found. Please resend OTP');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      print('🔍 Verifying OTP: $otp');

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      print('✅ OTP verification successful');
      _handleVerificationSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      print('❌ OTP verification failed: ${e.code} - ${e.message}');

      String errorMessage = 'Invalid OTP';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP. Please try again';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP expired. Please request a new one';
      }

      _showError(errorMessage);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError('Verification failed. Please try again');
    }
  }

  void _handleVerificationSuccess() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ VERIFICATION SUCCESS HANDLER');
    print('isForPasswordReset: ${widget.isForPasswordReset}');
    print('isForRegistration: ${widget.isForRegistration}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    _showSuccess('Phone number verified successfully!');

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // ✅ Navigate to Reset Password if this is for password reset
      if (widget.isForPasswordReset) {
        print('🔄 Navigating to Reset Password Screen...');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
          ),
        );
      }
      // For registration flow
      else if (widget.isForRegistration &&
          widget.onVerificationComplete != null) {
        widget.onVerificationComplete!();
        Navigator.pop(
            context, {'verifiedPhoneNumber': widget.phoneNumber});
      }
      // Default: just pop back
      else {
        Navigator.pop(
            context, {'verifiedPhoneNumber': widget.phoneNumber});
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      appBar: AppBar(
        title: Text(
          widget.isForPasswordReset
              ? 'Verify for Password Reset'
              : 'OTP Verification',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF1A237E),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.message,
                size: 40,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verify Your Phone',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter the 6-digit OTP sent to',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '+91 ${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC32F00),
              ),
            ),
            if (widget.isForPasswordReset) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'After verification, you\'ll be able to reset your password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOTPField(index)),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _verifyOTP,
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive OTP?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _resendTimer == 0
                      ? () {
                    _sendOTP();
                  }
                      : null,
                  child: Text(
                    _resendTimer > 0
                        ? 'Resend in ${_resendTimer}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _resendTimer > 0
                          ? Colors.grey.shade500
                          : const Color(0xFFC32F00),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? const Color(0xFF1A237E)
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          if (index == 5 && value.isNotEmpty) {
            final allFilled = _otpControllers.every((c) => c.text.isNotEmpty);
            if (allFilled) {
              _verifyOTP();
            }
          }

          setState(() {});
        },
      ),
    );
  }
}