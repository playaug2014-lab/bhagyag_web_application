import 'package:bhagyag/user_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Reset Password Screen - Opens after OTP verification success
class ResetPasswordScreen extends StatefulWidget {
  final String? userId; // Optional: pass from OTP screen or fetch from SharedPreferences

  const ResetPasswordScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;
  String? _userId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';
  static const String UPDATE_PASSWORD_ENDPOINT = '/User/UpdateUserPassword';///api/User/UpdateUserPassword

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Load userId from SharedPreferences or use the passed value
  Future<void> _loadUserId() async {
    try {
      if (widget.userId != null) {
        setState(() {
          _userId = widget.userId;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // Try to get from "MyReg" first (as in Android code)
      String? id = prefs.getString('userId');

      // Fallback to UserDetails (as used in Login.kt)
      if (id == null || id.isEmpty) {
        id = prefs.getString('userid');
      }

      setState(() {
        _userId = id;
      });

      print('✅ Loaded userId: $_userId');

      if (_userId == null || _userId!.isEmpty) {
        _showError('User ID not found. Please login again.');
      }
    } catch (e) {
      print('❌ Error loading userId: $e');
      _showError('Failed to load user data');
    }
  }

  /// Handle password reset submission
  // Add this method to _ResetPasswordScreenState class in reset_password_screen.dart

  Future<void> _handleResetPassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // Check if fields are empty
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showError('Please enter Password');
      return;
    }

    // Get userId and current password from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid') ?? '';
    final storedPassword = prefs.getString('password') ?? '';

    // Check if user data exists
    if (userId.isEmpty || storedPassword.isEmpty) {
      _showError('User data not found.');
      return;
    }

    // Verify current password matches stored password
    if (currentPassword != storedPassword) {
      _showError('Current password is incorrect');
      return;
    }

    // Validate new password
    if (newPassword.length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _updatePasswordAPI(userId, currentPassword, newPassword);

      if (success) {
        _showSuccess('Password updated successfully!');

        // Update stored password in SharedPreferences
        await prefs.setString('password', newPassword);

        // Wait for success message, then navigate back to login
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => EnhancedLoginScreen(
              selectedLanguageId: 1, // Pass appropriate values
              selectedLanguageName: 'English',
              accountType: 2,
            )),
                (route) => false,
          );
        }
      } else {
        _showError('Invalid password. Could not update!');
      }
    } catch (e) {
      print('❌ Reset Password Error: $e');
      _showError('Something went wrong. Try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _updatePasswordAPI(
      String userId,
      String currentPassword,
      String newPassword,
      ) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 UPDATE PASSWORD API CALL');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final url = Uri.parse(
        '$API_BASE_URL$UPDATE_PASSWORD_ENDPOINT'
            '?UserId=$userId'
            '&CurrentPassword=$currentPassword'
            '&NewPassword=$newPassword',
      );

      print('URL: $url');
      print('UserId: $userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        print('✅ Password update successful');
        return true;
      }

      print('⚠️ Password update failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Update Password API Error: $e');
      return false;
    }
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
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeaderImage(),
                        const SizedBox(height: 32),
                        const Text(
                          'Reset Your Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your current and new password',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _buildCurrentPasswordField(),
                        const SizedBox(height: 24),
                        _buildNewPasswordField(),
                        const SizedBox(height: 40),
                        _buildSubmitButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF1A237E),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Updating password...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 100,
        color: Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildCurrentPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC32F00).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _currentPasswordController,
        obscureText: _obscureCurrentPassword,
        decoration: InputDecoration(
          hintText: 'Current Password',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF1A237E),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureCurrentPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: const Color(0xFFC32F00),
            ),
            onPressed: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter current password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC32F00).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _newPasswordController,
        obscureText: _obscureNewPassword,
        decoration: InputDecoration(
          hintText: 'New Password',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.lock,
            color: Color(0xFF1A237E),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: const Color(0xFFC32F00),
            ),
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter new password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
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
          onTap: _isLoading ? null : _handleResetPassword,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}