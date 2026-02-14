import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'astrologer_registrationstep1.dart';

/// Astrologer Registration - Step 1 (Personal Details)
/// Features:
/// - Multi-language support
/// - Beautiful orange-red gradient theme
/// - Form validation
/// - Date picker for DOB
/// - Dropdowns for selections
class AstrologerRegistrationStep1 extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;

  const AstrologerRegistrationStep1({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
  }) : super(key: key);

  @override
  State<AstrologerRegistrationStep1> createState() =>
      _AstrologerRegistrationStep1State();
}

class _AstrologerRegistrationStep1State
    extends State<AstrologerRegistrationStep1> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _pobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _familyMembersController = TextEditingController();
  final _kidsCountController = TextEditingController(text: '0');
  final _emergencyNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedMaritalStatus;
  String? _selectedPassport;
  String? _selectedDrivingLicense;
  String? _selectedAadhaar;

  DateTime? _dateOfBirth;

  // Translations
  Map<String, Map<String, String>> translations = {
    'English': {
      'title': 'Astrologer Registration',
      'step1': 'Step 1: Personal Details',
      'fullName': 'Full Name',
      'enterName': 'Enter your full name',
      'dob': 'Date of Birth',
      'selectDob': 'Select Date of Birth',
      'pob': 'Place of Birth',
      'enterPob': 'Enter place of birth',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'email': 'Email ID',
      'enterEmail': 'Enter your email',
      'phone': 'Phone Number',
      'enterPhone': 'Enter phone number',
      'whatsapp': 'WhatsApp Number',
      'enterWhatsapp': 'Enter WhatsApp number',
      'bloodGroup': 'Blood Group',
      'selectBlood': 'Select Blood Group',
      'maritalStatus': 'Marital Status',
      'selectMarital': 'Select Marital Status',
      'familyMembers': 'Number of Family Members',
      'enterFamily': 'Enter number',
      'kidsCount': 'Number of Kids',
      'enterKids': 'Enter number',
      'emergencyName': 'Emergency Contact Name',
      'enterEmergencyName': 'Enter contact name',
      'emergencyPhone': 'Emergency Contact Number',
      'enterEmergencyPhone': 'Enter contact number',
      'passport': 'Passport',
      'drivingLicense': 'Driving License',
      'aadhaar': 'Aadhaar Card',
      'yes': 'Yes',
      'no': 'No',
      'next': 'Next',
      'single': 'Single',
      'married': 'Married',
      'divorced': 'Divorced',
      'widowed': 'Widowed',
    },
    'Hindi': {
      'title': 'ज्योतिषी पंजीकरण',
      'step1': 'चरण 1: व्यक्तिगत विवरण',
      'fullName': 'पूरा नाम',
      'enterName': 'अपना पूरा नाम दर्ज करें',
      'dob': 'जन्म तिथि',
      'selectDob': 'जन्म तिथि चुनें',
      'pob': 'जन्म स्थान',
      'enterPob': 'जन्म स्थान दर्ज करें',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'email': 'ईमेल आईडी',
      'enterEmail': 'अपना ईमेल दर्ज करें',
      'phone': 'फोन नंबर',
      'enterPhone': 'फोन नंबर दर्ज करें',
      'whatsapp': 'व्हाट्सएप नंबर',
      'enterWhatsapp': 'व्हाट्सएप नंबर दर्ज करें',
      'bloodGroup': 'रक्त समूह',
      'selectBlood': 'रक्त समूह चुनें',
      'maritalStatus': 'वैवाहिक स्थिति',
      'selectMarital': 'वैवाहिक स्थिति चुनें',
      'familyMembers': 'परिवार के सदस्यों की संख्या',
      'enterFamily': 'संख्या दर्ज करें',
      'kidsCount': 'बच्चों की संख्या',
      'enterKids': 'संख्या दर्ज करें',
      'emergencyName': 'आपातकालीन संपर्क नाम',
      'enterEmergencyName': 'संपर्क नाम दर्ज करें',
      'emergencyPhone': 'आपातकालीन संपर्क नंबर',
      'enterEmergencyPhone': 'संपर्क नंबर दर्ज करें',
      'passport': 'पासपोर्ट',
      'drivingLicense': 'ड्राइविंग लाइसेंस',
      'aadhaar': 'आधार कार्ड',
      'yes': 'हाँ',
      'no': 'नहीं',
      'next': 'अगला',
      'single': 'अविवाहित',
      'married': 'विवाहित',
      'divorced': 'तलाकशुदा',
      'widowed': 'विधवा',
    },
  };

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _pobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _familyMembersController.dispose();
    _kidsCountController.dispose();
    _emergencyNameController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return translations[widget.selectedLanguageName]?[key] ??
        translations['English']![key]!;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE63946),
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
        // Format date manually as DD/MM/YYYY
        String day = picked.day.toString().padLeft(2, '0');
        String month = picked.month.toString().padLeft(2, '0');
        String year = picked.year.toString();
        _dobController.text = '$day/$month/$year';
      });
    }
  }

  void _showDropdown(String title, List<String> items, Function(String) onSelected) {
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
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) => ListTile(
                title: Text(item),
                onTap: () {
                  onSelected(item);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        _showError('Please select gender');
        return;
      }

      // Navigate to step 2
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AstrologerRegistrationStep2(
            selectedLanguageId: widget.selectedLanguageId,
            selectedLanguageName: widget.selectedLanguageName,
            step1Data: {
              'name': _nameController.text,
              'dob': _dobController.text,
              'pob': _pobController.text,
              'gender': _selectedGender,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'whatsapp': _whatsappController.text,
              'bloodGroup': _selectedBloodGroup,
              'maritalStatus': _selectedMaritalStatus,
              'familyMembers': _familyMembersController.text,
              'kidsCount': _kidsCountController.text,
              'emergencyName': _emergencyNameController.text,
              'emergencyContact': _emergencyContactController.text,
              'passport': _selectedPassport,
              'drivingLicense': _selectedDrivingLicense,
              'aadhaar': _selectedAadhaar,
            },
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFE63946),
              const Color(0xFFD62828),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            _getText('title'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('step1'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
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
          _buildTextField(
            controller: _nameController,
            label: _getText('fullName'),
            hint: _getText('enterName'),
            icon: Icons.person,
          ),
          const SizedBox(height: 20),

          _buildDateField(),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _pobController,
            label: _getText('pob'),
            hint: _getText('enterPob'),
            icon: Icons.location_on,
          ),
          const SizedBox(height: 20),

          _buildGenderSelector(),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _emailController,
            label: _getText('email'),
            hint: _getText('enterEmail'),
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _phoneController,
            label: _getText('phone'),
            hint: _getText('enterPhone'),
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _whatsappController,
            label: _getText('whatsapp'),
            hint: _getText('enterWhatsapp'),
            icon: Icons.chat_bubble,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('bloodGroup'),
            value: _selectedBloodGroup,
            hint: _getText('selectBlood'),
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
            onSelected: (value) => setState(() => _selectedBloodGroup = value),
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('maritalStatus'),
            value: _selectedMaritalStatus,
            hint: _getText('selectMarital'),
            items: [
              _getText('single'),
              _getText('married'),
              _getText('divorced'),
              _getText('widowed'),
            ],
            onSelected: (value) => setState(() => _selectedMaritalStatus = value),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _familyMembersController,
            label: _getText('familyMembers'),
            hint: _getText('enterFamily'),
            icon: Icons.family_restroom,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _kidsCountController,
            label: _getText('kidsCount'),
            hint: _getText('enterKids'),
            icon: Icons.child_care,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _emergencyNameController,
            label: _getText('emergencyName'),
            hint: _getText('enterEmergencyName'),
            icon: Icons.emergency,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _emergencyContactController,
            label: _getText('emergencyPhone'),
            hint: _getText('enterEmergencyPhone'),
            icon: Icons.phone_in_talk,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('passport'),
            value: _selectedPassport,
            hint: _getText('yes') + ' / ' + _getText('no'),
            items: [_getText('yes'), _getText('no')],
            onSelected: (value) => setState(() => _selectedPassport = value),
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('drivingLicense'),
            value: _selectedDrivingLicense,
            hint: _getText('yes') + ' / ' + _getText('no'),
            items: [_getText('yes'), _getText('no')],
            onSelected: (value) => setState(() => _selectedDrivingLicense = value),
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('aadhaar'),
            value: _selectedAadhaar,
            hint: _getText('yes') + ' / ' + _getText('no'),
            items: [_getText('yes'), _getText('no')],
            onSelected: (value) => setState(() => _selectedAadhaar = value),
          ),
          const SizedBox(height: 40),

          _buildNextButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFE63946)),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE63946),
                width: 2,
              ),
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
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('dob'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFE63946)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _dobController.text.isEmpty
                        ? _getText('selectDob')
                        : _dobController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _dobController.text.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('gender'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(_getText('male'), 'Male'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption(_getText('female'), 'Female'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE63946) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE63946) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDropdown(label, items, onSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: value == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFE63946),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFE63946),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE63946).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleNext,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getText('next'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_rounded,
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