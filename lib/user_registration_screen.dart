import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'otp_screen.dart';
import 'user_dashboard.dart';

class UserRegistrationScreen extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;
  final String phoneNumber;

  const UserRegistrationScreen({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _tobController = TextEditingController();
  final _pobController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _selectedGender;
  String? _selectedState;
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;

  bool _isSubmitting = false;

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';
  static const String REGISTER_ENDPOINT = '/User';

  final List<String> _states = [
    'ANDAMAN & NICOBAR', 'ANDHRA PRADESH', 'ARUNACHAL PRADESH', 'ASSAM', 'BIHAR',
    'CHANDIGARH', 'DADRA & NAGAR HAVELI', 'DAMAN & DIU', 'DELHI', 'GOA',
    'GUJARAT', 'HARYANA', 'HIMACHAL PRADESH', 'JAMMU & KASHMIR', 'JHARKHAND',
    'KARNATAKA', 'KERALA', 'LAKSHADWEEP', 'MADHYA PRADESH', 'MAHARASHTRA',
    'MANIPUR', 'MEGHALAYA', 'MIZORAM', 'NAGALAND', 'ODISHA', 'PUDUCHERRY',
    'PUNJAB', 'RAJASTHAN', 'SIKKIM', 'TAMIL NADU', 'TRIPURA', 'UTTAR PRADESH',
    'UTTARAKHAND', 'WEST BENGAL', 'TELANGANA'
  ];

  Map<String, Map<String, String>> translations = {
    'English': {
      'title': 'Registration',
      'name': 'Name',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'email': 'Email ID',
      'phone': 'Phone Number',
      'password': 'Password',
      'dob': 'Date of Birth',
      'tob': 'Time of Birth',
      'pob': 'Place of Birth',
      'currentAddress': 'Current Address',
      'district': 'District',
      'state': 'State',
      'selectState': 'Select State',
      'pincode': 'Pincode',
      'submit': 'Submit',
      'enterName': 'Enter your name',
      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter password',
      'selectDob': 'Select Date of Birth',
      'selectTob': 'Select Time of Birth',
    },
    'Hindi': {
      'title': 'पंजीकरण',
      'name': 'नाम',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'email': 'ईमेल आईडी',
      'phone': 'फोन नंबर',
      'password': 'पासवर्ड',
      'dob': 'जन्म तिथि',
      'tob': 'जन्म समय',
      'pob': 'जन्म स्थान',
      'currentAddress': 'वर्तमान पता',
      'district': 'जिला',
      'state': 'राज्य',
      'selectState': 'राज्य चुनें',
      'pincode': 'पिनकोड',
      'submit': 'जमा करें',
      'enterName': 'अपना नाम दर्ज करें',
      'enterEmail': 'अपना ईमेल दर्ज करें',
      'enterPassword': 'पासवर्ड दर्ज करें',
      'selectDob': 'जन्म तिथि चुनें',
      'selectTob': 'जन्म समय चुनें',
    },
  };

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return translations[widget.selectedLanguageName]?[key] ??
        translations['English']![key]!;
  }

  Future<void> _selectDate() async {
    final DateTime initialDate = DateTime.now().subtract(const Duration(days: 6570));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeOfBirth = picked;
        _tobController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _showStateDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getText('state'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _states
                      .map((state) => ListTile(
                    title: Text(state),
                    onTap: () {
                      setState(() => _selectedState = state);
                      Navigator.pop(context);
                    },
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateInputs() {
    if (!_formKey.currentState!.validate()) return false;

    if (_selectedGender == null) {
      _showError('Please select gender');
      return false;
    }

    if (_selectedState == null) {
      _showError('Please select state');
      return false;
    }

    if (_dobController.text.isEmpty) {
      _showError('Please select date of birth');
      return false;
    }

    if (_tobController.text.isEmpty) {
      _showError('Please select time of birth');
      return false;
    }

    return true;
  }

  void _showOtpConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Number Verification'),
        content: Text('We will send an OTP to verify your phone number: ${_phoneController.text}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSubmitState();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToOTPScreen();
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  void _navigateToOTPScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpScreen(
          phoneNumber: _phoneController.text,
          isForRegistration: true,
          isForPasswordReset: false,
          onVerificationComplete: _handleRegistrationAPI,
        ),
      ),
    );
  }

  Future<void> _handleRegistrationAPI() async {
    setState(() => _isSubmitting = true);

    try {
      final dob = '${_dobController.text}T${_tobController.text}:00.000';
      final currentDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now());

      final url = Uri.parse('$API_BASE_URL$REGISTER_ENDPOINT');
      final requestBody = {
        'fullName': _nameController.text,
        'profileImage': 'string',
        'emailId': _emailController.text,
        'phoneNo': _phoneController.text,
        'password': _passwordController.text,
        'dob': dob,
        'gender': _selectedGender,
        'placeOfBirth': _pobController.text,
        'currentAddress': _addressController.text,
        'district': _districtController.text,
        'state': _selectedState,
        'country': 'India',
        'pincode': _pincodeController.text,
        'isMobileVerified': 'Y',
        'isEmailVerified': 'Y',
        'regDate': currentDateTime,
        'userType': 'USER',
        'userStatus': 'Active',
        'firebaseID': '',
        'chatStatus': '',
      };

      print('Registration Request: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Registration Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        await _saveUserSession(responseData['record']);
        _showRegistrationSuccessDialog(responseData['record']);
      } else {
        final errorBody = response.body;
        _showError('Registration failed: $errorBody');
      }
    } catch (e) {
      print('Registration Error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      _resetSubmitState();
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', userData['userId'] ?? '');
    await prefs.setString('username', userData['fullName'] ?? '');
    await prefs.setString('contact', userData['phoneNo'] ?? '');
    await prefs.setString('uniqueid', userData['uniqueUserID'] ?? '');
    await prefs.setBool('myboolean', true);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userType', 'USER');
  }

  void _showRegistrationSuccessDialog(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful!'),
        content: Text('Welcome ${userData['fullName']}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => UserDashboard(
                    userName: userData['fullName'] ?? 'User',
                    walletAmount: '₹0',
                  ),
                ),
                    (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetSubmitState() {
    setState(() {
      _isSubmitting = false;
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) {
      _showError('Please wait...');
      return;
    }

    if (_validateInputs()) {
      setState(() => _isSubmitting = true);
      _showOtpConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF5E6),
              const Color(0xFFFFE6D6),
              const Color(0xFFFFD4C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            _getText('title'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildStepIndicator(_getText('name')),
          _buildTextField(
            controller: _nameController,
            hint: _getText('enterName'),
            inputType: TextInputType.name,
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('gender')),
          _buildGenderSelector(),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('email')),
          _buildTextField(
            controller: _emailController,
            hint: _getText('enterEmail'),
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('phone')),
          _buildTextField(
            controller: _phoneController,
            hint: _getText('phone'),
            inputType: TextInputType.phone,
            maxLength: 10,
            enabled: false,
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('password')),
          _buildTextField(
            controller: _passwordController,
            hint: _getText('enterPassword'),
            obscureText: true,
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('dob')),
          _buildDateField(),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('tob')),
          _buildTimeField(),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('pob')),
          _buildTextField(
            controller: _pobController,
            hint: _getText('pob'),
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('currentAddress')),
          _buildTextField(
            controller: _addressController,
            hint: _getText('currentAddress'),
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('district')),
          _buildTextField(
            controller: _districtController,
            hint: _getText('district'),
          ),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('state')),
          _buildStateField(),
          const SizedBox(height: 20),

          _buildStepIndicator(_getText('pincode')),
          _buildTextField(
            controller: _pincodeController,
            hint: _getText('pincode'),
            inputType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 40),

          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? inputType,
    int? maxLength,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        maxLength: maxLength,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: Text(_getText('male')),
              value: 'Male',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
              activeColor: const Color(0xFF1A237E),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: Text(_getText('female')),
              value: 'Female',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
              activeColor: const Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      child: InkWell(
        onTap: _selectDate,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          child: Text(
            _dobController.text.isEmpty
                ? _getText('selectDob')
                : _dobController.text,
            style: TextStyle(
              color: _dobController.text.isEmpty
                  ? Colors.grey.shade600
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      child: InkWell(
        onTap: _selectTime,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          child: Text(
            _tobController.text.isEmpty
                ? _getText('selectTob')
                : _tobController.text,
            style: TextStyle(
              color: _tobController.text.isEmpty
                  ? Colors.grey.shade600
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateField() {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      child: InkWell(
        onTap: _showStateDropdown,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
          child: Text(
            _selectedState ?? _getText('selectState'),
            style: TextStyle(
              color: _selectedState == null
                  ? Colors.grey.shade600
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF0D47A1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
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
          onTap: _isSubmitting ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              _getText('submit'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}