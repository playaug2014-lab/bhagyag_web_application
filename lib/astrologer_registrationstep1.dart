import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'astrologer_login_screen.dart';

/// Astrologer Registration - Step 2 (Professional Details)
/// Features:
/// - Multi-language support
/// - Languages selection
/// - Specialization selection
/// - Experience dropdown
/// - Address details
/// - PDF resume upload
/// - API integration with loading states
class AstrologerRegistrationStep2 extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;
  final Map<String, dynamic> step1Data;

  const AstrologerRegistrationStep2({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
    required this.step1Data,
  }) : super(key: key);

  @override
  State<AstrologerRegistrationStep2> createState() =>
      _AstrologerRegistrationStep2State();
}

class _AstrologerRegistrationStep2State
    extends State<AstrologerRegistrationStep2> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _minimumHoursController = TextEditingController();
  final _daysAvailabilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _aboutMeController = TextEditingController();

  // Selected values
  List<String> _selectedLanguages = [];
  List<String> _selectedSpecializations = [];
  String? _selectedExperience;
  String? _selectedShift;
  String? _selectedAddressStatus;
  String? _selectedAddressType;
  String? _selectedState;
  String? _selectedCertification;
  String? _pdfFileName;
  File? _pdfFile;
  bool _isLoading = false;

  // Available options
  final List<String> _availableLanguages = [
    'Hindi', 'English', 'Punjabi', 'Gujarati', 'Bengali',
    'Marathi', 'Telugu', 'Tamil', 'Odia', 'Rajasthani',
    'Marwari', 'Assamese'
  ];

  final List<String> _specializations = [
    'Vedic Astrology', 'Numerology', 'Tarot Reading',
    'Palmistry', 'Vastu Shastra', 'Face Reading',
    'Kundali Matching', 'Horoscope', 'Gemology',
    'Prashna Kundali', 'Lal Kitab', 'KP Astrology'
  ];

  final List<String> _experiences = [
    '0-1 years', '1-3 years', '3-5 years',
    '5-10 years', '10+ years'
  ];

  final List<String> _shifts = [
    'Morning', 'Afternoon', 'Evening', 'Night', 'Flexible'
  ];

  final List<String> _addressStatuses = [
    'Permanent', 'Temporary', 'Rental'
  ];

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Delhi', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  // Translations
  Map<String, Map<String, String>> translations = {
    'English': {
      'title': 'Astrologer Registration',
      'step2': 'Step 2: Professional Details',
      'knownLanguages': 'Known Languages',
      'selectLanguages': 'Select Languages',
      'specializedIn': 'Specialized In',
      'selectSpecialization': 'Select Specializations',
      'experience': 'Experience',
      'selectExperience': 'Select Experience',
      'minimumHours': 'Minimum Hours',
      'enterHours': 'e.g., 4 hours',
      'daysAvailability': 'Days Availability',
      'enterDays': 'e.g., 7 days',
      'availabilityShift': 'Availability Shift',
      'selectShift': 'Select Shift',
      'addressStatus': 'Address Status',
      'selectAddressStatus': 'Select Address Status',
      'addressType': 'Address Type',
      'owned': 'Owned',
      'rented': 'Rented',
      'address': 'Address',
      'enterAddress': 'Enter your full address',
      'city': 'City/District',
      'enterCity': 'Enter city/district',
      'state': 'State',
      'selectState': 'Select State',
      'pincode': 'Pincode',
      'enterPincode': 'Enter pincode',
      'certification': 'Certification',
      'yes': 'Yes',
      'no': 'No',
      'aboutMe': 'About Me',
      'tellAbout': 'Tell us about yourself',
      'resumeUpload': 'Resume Upload',
      'uploadPdf': 'Upload PDF (Max 1MB)',
      'noFile': 'No file selected',
      'submit': 'Submit',
      'submitting': 'Submitting...',
    },
    'Hindi': {
      'title': 'ज्योतिषी पंजीकरण',
      'step2': 'चरण 2: व्यावसायिक विवरण',
      'knownLanguages': 'ज्ञात भाषाएँ',
      'selectLanguages': 'भाषाएँ चुनें',
      'specializedIn': 'विशेषज्ञता',
      'selectSpecialization': 'विशेषज्ञता चुनें',
      'experience': 'अनुभव',
      'selectExperience': 'अनुभव चुनें',
      'minimumHours': 'न्यूनतम घंटे',
      'enterHours': 'जैसे, 4 घंटे',
      'daysAvailability': 'दिन उपलब्धता',
      'enterDays': 'जैसे, 7 दिन',
      'availabilityShift': 'उपलब्धता शिफ्ट',
      'selectShift': 'शिफ्ट चुनें',
      'addressStatus': 'पता स्थिति',
      'selectAddressStatus': 'पता स्थिति चुनें',
      'addressType': 'पता प्रकार',
      'owned': 'स्वामित्व',
      'rented': 'किराए पर',
      'address': 'पता',
      'enterAddress': 'अपना पूरा पता दर्ज करें',
      'city': 'शहर/जिला',
      'enterCity': 'शहर/जिला दर्ज करें',
      'state': 'राज्य',
      'selectState': 'राज्य चुनें',
      'pincode': 'पिनकोड',
      'enterPincode': 'पिनकोड दर्ज करें',
      'certification': 'प्रमाणन',
      'yes': 'हाँ',
      'no': 'नहीं',
      'aboutMe': 'मेरे बारे में',
      'tellAbout': 'अपने बारे में बताएं',
      'resumeUpload': 'रिज्यूमे अपलोड',
      'uploadPdf': 'पीडीएफ अपलोड करें (अधिकतम 1MB)',
      'noFile': 'कोई फ़ाइल चयनित नहीं',
      'submit': 'जमा करें',
      'submitting': 'जमा हो रहा है...',
    },
  };

  @override
  void dispose() {
    _minimumHoursController.dispose();
    _daysAvailabilityController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return translations[widget.selectedLanguageName]?[key] ??
        translations['English']![key]!;
  }

  void _showMultiSelect(
      String title,
      List<String> items,
      List<String> selectedItems,
      Function(List<String>) onConfirm,
      ) {
    List<String> tempSelected = List.from(selectedItems);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) {
                    return CheckboxListTile(
                      title: Text(item),
                      value: tempSelected.contains(item),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                      activeColor: const Color(0xFFE63946),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDropdown(
      String title,
      List<String> items,
      Function(String) onSelected,
      ) {
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
              Expanded(
                child: ListView(
                  children: items
                      .map((item) => ListTile(
                    title: Text(item),
                    onTap: () {
                      onSelected(item);
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

  Future<void> _pickPdfFile() async {
    try {
      final ImagePicker picker = ImagePicker();

      // For PDF, we'll use gallery to let user select files
      // Note: On mobile, users typically upload images or use gallery
      // For actual PDF selection, you might want to use platform-specific file managers

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Resume'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE63946)),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    File file = File(image.path);
                    int fileSize = await file.length();
                    if (fileSize > 1048576) {
                      _showError('File size exceeds 1MB. Please try again.');
                      return;
                    }
                    setState(() {
                      _pdfFile = file;
                      _pdfFileName = image.name;
                    });
                    _showSuccess('Document uploaded successfully!');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE63946)),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    File file = File(image.path);
                    int fileSize = await file.length();
                    if (fileSize > 1048576) {
                      _showError('File size exceeds 1MB. Please try again.');
                      return;
                    }
                    setState(() {
                      _pdfFile = file;
                      _pdfFileName = image.name;
                    });
                    _showSuccess('Document uploaded successfully!');
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to pick file: ${e.toString()}');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLanguages.isEmpty) {
        _showError('Please select at least one language');
        return;
      }
      if (_selectedSpecializations.isEmpty) {
        _showError('Please select at least one specialization');
        return;
      }
      if (_selectedExperience == null) {
        _showError('Please select experience');
        return;
      }
      if (_selectedShift == null) {
        _showError('Please select availability shift');
        return;
      }
      if (_selectedAddressStatus == null) {
        _showError('Please select address status');
        return;
      }
      if (_selectedAddressType == null) {
        _showError('Please select address type');
        return;
      }
      if (_selectedState == null) {
        _showError('Please select state');
        return;
      }
      if (_selectedCertification == null) {
        _showError('Please select certification status');
        return;
      }

      // Show loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Convert date from DD/MM/YYYY to ISO 8601 format
        String dobFromStep1 = widget.step1Data['dob'] ?? '';
        String formattedDob = '';

        if (dobFromStep1.isNotEmpty) {
          // Parse DD/MM/YYYY
          List<String> dateParts = dobFromStep1.split('/');
          if (dateParts.length == 3) {
            String day = dateParts[0].padLeft(2, '0');
            String month = dateParts[1].padLeft(2, '0');
            String year = dateParts[2];
            // Convert to ISO 8601: YYYY-MM-DDTHH:mm:ss
            formattedDob = '$year-$month-${day}T00:00:00';
          }
        }

        // Prepare API parameters
        final response = await _apiService.submitProfile(
          fullName: widget.step1Data['name'] ?? '',
          dateOfBirth: formattedDob,
          placeOfBirth: widget.step1Data['pob'] ?? '',
          gender: widget.step1Data['gender'] ?? '',
          knownLanguages: _selectedLanguages.join(', '),
          specializedIns: _selectedSpecializations.join(', '),
          experience: _selectedExperience ?? '',
          emailId: widget.step1Data['email'] ?? '',
          phone: widget.step1Data['phone'] ?? '',
          addressStatus: _selectedAddressStatus ?? '',
          address: _addressController.text,
          emergencyContact: widget.step1Data['emergencyContact'] ?? '',
          emergencyContactName: widget.step1Data['emergencyName'] ?? '',
          passport: widget.step1Data['passport'] ?? '',
          dl: widget.step1Data['drivingLicense'] ?? '',
          aadhaarCard: widget.step1Data['aadhaar'] ?? '',
          whatsappNo: widget.step1Data['whatsapp'] ?? '',
          bloodGroup: widget.step1Data['bloodGroup'] ?? '',
          familyMembersCount: widget.step1Data['familyMembers'] ?? '',
          kids: widget.step1Data['kidsCount'] ?? '',
          maritalStatus: widget.step1Data['maritalStatus'] ?? '',
          minimumHours: _minimumHoursController.text,
          daysAvailability: _daysAvailabilityController.text,
          availabilityShift: _selectedShift ?? '',
          aboutMe: _aboutMeController.text,
          certification: _selectedCertification ?? '',
          district: _districtController.text,
          state: _selectedState ?? '',
          pincode: _pincodeController.text,
          resumeFile: _pdfFile,
        );

        // Hide loading
        setState(() {
          _isLoading = false;
        });

        // Show success message
        _showSuccess(response.message);

        // Wait a moment before navigating
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to login screen and remove all previous routes
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AstrologerRegistrationSuccessScreen(),
            ),
                (route) => false,
          );
        }
      } on ApiException catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError(e.message);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('An unexpected error occurred. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation while loading
        return !_isLoading;
      },
      child: Stack(
        children: [
          Scaffold(
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
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE63946),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getText('submitting'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please wait...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
            _getText('step2'),
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
          _buildMultiSelectField(
            label: _getText('knownLanguages'),
            hint: _getText('selectLanguages'),
            selectedItems: _selectedLanguages,
            items: _availableLanguages,
            onTap: () => _showMultiSelect(
              _getText('knownLanguages'),
              _availableLanguages,
              _selectedLanguages,
                  (selected) => setState(() => _selectedLanguages = selected),
            ),
          ),
          const SizedBox(height: 20),

          _buildMultiSelectField(
            label: _getText('specializedIn'),
            hint: _getText('selectSpecialization'),
            selectedItems: _selectedSpecializations,
            items: _specializations,
            onTap: () => _showMultiSelect(
              _getText('specializedIn'),
              _specializations,
              _selectedSpecializations,
                  (selected) => setState(() => _selectedSpecializations = selected),
            ),
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('experience'),
            value: _selectedExperience,
            hint: _getText('selectExperience'),
            items: _experiences,
            onSelected: (value) => setState(() => _selectedExperience = value),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _minimumHoursController,
            label: _getText('minimumHours'),
            hint: _getText('enterHours'),
            icon: Icons.access_time,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _daysAvailabilityController,
            label: _getText('daysAvailability'),
            hint: _getText('enterDays'),
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('availabilityShift'),
            value: _selectedShift,
            hint: _getText('selectShift'),
            items: _shifts,
            onSelected: (value) => setState(() => _selectedShift = value),
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('addressStatus'),
            value: _selectedAddressStatus,
            hint: _getText('selectAddressStatus'),
            items: _addressStatuses,
            onSelected: (value) => setState(() => _selectedAddressStatus = value),
          ),
          const SizedBox(height: 20),

          _buildAddressTypeSelector(),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _addressController,
            label: _getText('address'),
            hint: _getText('enterAddress'),
            icon: Icons.home,
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _districtController,
            label: _getText('city'),
            hint: _getText('enterCity'),
            icon: Icons.location_city,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('state'),
            value: _selectedState,
            hint: _getText('selectState'),
            items: _states,
            onSelected: (value) => setState(() => _selectedState = value),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _pincodeController,
            label: _getText('pincode'),
            hint: _getText('enterPincode'),
            icon: Icons.pin_drop,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            label: _getText('certification'),
            value: _selectedCertification,
            hint: _getText('yes') + ' / ' + _getText('no'),
            items: [_getText('yes'), _getText('no')],
            onSelected: (value) => setState(() => _selectedCertification = value),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _aboutMeController,
            label: _getText('aboutMe'),
            hint: _getText('tellAbout'),
            icon: Icons.person_outline,
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          _buildPdfUploader(),
          const SizedBox(height: 40),

          _buildSubmitButton(),
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
                      color: value == null ? Colors.grey.shade600 : Colors.black,
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

  Widget _buildMultiSelectField({
    required String label,
    required String hint,
    required List<String> selectedItems,
    required List<String> items,
    required VoidCallback onTap,
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
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedItems.isEmpty
                ? Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFE63946),
                ),
              ],
            )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: const Color(0xFFE63946).withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFFE63946),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFFE63946),
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedItems.remove(item);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('addressType'),
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
              child: _buildAddressTypeOption(_getText('owned'), 'Owned'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAddressTypeOption(_getText('rented'), 'Rented'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressTypeOption(String label, String value) {
    final isSelected = _selectedAddressType == value;
    return InkWell(
      onTap: () => setState(() => _selectedAddressType = value),
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

  Widget _buildPdfUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('resumeUpload'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickPdfFile,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE63946).withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _pdfFileName != null ? Icons.picture_as_pdf : Icons.upload_file,
                  size: 50,
                  color: const Color(0xFFE63946),
                ),
                const SizedBox(height: 12),
                Text(
                  _pdfFileName ?? _getText('uploadPdf'),
                  style: TextStyle(
                    fontSize: 14,
                    color: _pdfFileName != null
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_pdfFileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
          onTap: _isLoading ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getText('submit'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle,
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