// lib/screens/astrologer_dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'service_fragment.dart';
import 'profile_service_fragment.dart';
import 'settings_fragment.dart';

class AstrologerDashboardScreen extends StatefulWidget {
  const AstrologerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AstrologerDashboardScreen> createState() =>
      _AstrologerDashboardScreenState();
}

class _AstrologerDashboardScreenState extends State<AstrologerDashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _dbRef;

  String? _userId;
  String? _userName;
  String? _firebaseUid;

  final GlobalKey<ServiceFragmentState> _serviceFragmentKey =
  GlobalKey<ServiceFragmentState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateStatusOnExit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed');
        if (_firebaseUid != null) {
          _updateFirebaseStatus('offline');
        }
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 App paused');
        if (_firebaseUid != null) {
          _updateFirebaseStatus('offline');
        }
        break;
      case AppLifecycleState.inactive:
        debugPrint('📱 App inactive');
        break;
      case AppLifecycleState.detached:
        debugPrint('📱 App detached');
        if (_firebaseUid != null) {
          _updateFirebaseStatus('offline');
        }
        break;
      case AppLifecycleState.hidden:
        debugPrint('📱 App hidden');
        break;
    }
  }

  Future<void> _updateFirebaseStatus(String status) async {
    if (_firebaseUid == null) return;

    final ref = FirebaseDatabase.instance.ref('user/$_firebaseUid');
    await ref.update({
      'call': _firebaseUid,
      'videocall': status,
      'voicecall': status,
    });

    if (_userId != null) {
      await _updateFirebaseIdAPI(_userId!, _firebaseUid!, status);
    }
  }

  Future<void> _updateFirebaseIdAPI(
      String userId, String firebaseId, String status) async {
    try {
      final url = Uri.parse(
          'https://test.bhagyag.com/api/User/UpdateFirebaseID?UserId=$userId&FirebaseID=$firebaseId&ChatStatus=$status');
      await http.post(url).timeout(const Duration(seconds: 10));
      debugPrint('✅ Firebase ID updated in API');
    } catch (e) {
      debugPrint('❌ Update Firebase ID API error: $e');
    }
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getString('userId');
    _userName = prefs.getString('fullName');

    if (_userId == null || _userName == null) {
      debugPrint('⚠️ No user session found, redirecting to login');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {});

    // ✅ FIXED: Use proper Firebase authentication
    await _authenticateWithFirebase();
  }

  // ✅ NEW: Proper Firebase Authentication
  Future<void> _authenticateWithFirebase() async {
    try {
      // Check if already signed in
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Already signed in, check if it's linked to this user
        final prefs = await SharedPreferences.getInstance();
        final savedFirebaseUid = prefs.getString('firebaseUid');

        if (savedFirebaseUid == currentUser.uid) {
          // Same user, use existing auth
          setState(() {
            _firebaseUid = currentUser.uid;
          });
          debugPrint('✅ Using existing Firebase auth: $_firebaseUid');
          await _ensureUserInDatabase();
          await _updateFirebaseStatus('offline');
          return;
        } else {
          // Different user, sign out first
          await _auth.signOut();
        }
      }

      // Try to get saved credentials
      final prefs = await SharedPreferences.getInstance();
      final savedFirebaseUid = prefs.getString('firebaseUid');
      final savedEmail = prefs.getString('firebaseEmail');
      final savedPassword = prefs.getString('firebasePassword');

      if (savedEmail != null && savedPassword != null) {
        // Try to sign in with saved credentials
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );

          setState(() {
            _firebaseUid = userCredential.user?.uid;
          });

          debugPrint('✅ Signed in with saved credentials: $_firebaseUid');
          await _ensureUserInDatabase();
          await _updateFirebaseStatus('offline');
          return;
        } catch (e) {
          debugPrint('⚠️ Saved credentials failed, creating new account');
        }
      }

      // Create new Firebase account
      await _createNewFirebaseAccount();

    } catch (e) {
      debugPrint('❌ Firebase authentication error: $e');
      _showErrorDialog('Authentication failed. Please try again.');
    }
  }

  Future<void> _createNewFirebaseAccount() async {
    try {
      // Generate unique email and strong password
      final email = 'astrologer_${_userId}_${DateTime.now().millisecondsSinceEpoch}@bhagyag.com';
      final password = _generateSecurePassword();

      debugPrint('📝 Creating Firebase account with email: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        _firebaseUid = userCredential.user?.uid;
      });

      // Save credentials for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebaseUid', _firebaseUid!);
      await prefs.setString('firebaseEmail', email);
      await prefs.setString('firebasePassword', password);

      debugPrint('✅ Firebase account created: $_firebaseUid');

      await _ensureUserInDatabase();
      await _updateFirebaseStatus('offline');

    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase create account error: ${e.code} - ${e.message}');

      if (e.code == 'email-already-in-use') {
        // This shouldn't happen with timestamp, but handle it
        debugPrint('⚠️ Email conflict, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
        await _createNewFirebaseAccount(); // Retry
      } else {
        _showErrorDialog('Failed to create account: ${e.message}');
      }
    }
  }

  String _generateSecurePassword() {
    // Generate a secure password
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'Astro_${_userId}_$timestamp\$Secure';
  }

  Future<void> _ensureUserInDatabase() async {
    if (_firebaseUid == null || _userName == null) return;

    _dbRef = FirebaseDatabase.instance.ref('user/$_firebaseUid');

    // Check if user exists
    final snapshot = await _dbRef!.get();

    if (!snapshot.exists) {
      // Create user in database
      await _dbRef!.set({
        'name': _userName,
        'email': 'astrologer_$_userId@bhagyag.com',
        'uid': _firebaseUid,
        'status': 'offline',
        'profileImage': '',
        'comswitch': 'offline',
        'videocall': 'offline',
        'voicecall': 'offline',
        'type': 'disable',
      });
      debugPrint('✅ User added to Firebase Database');
    } else {
      debugPrint('✅ User already exists in Firebase Database');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatusOnExit() async {
    if (_firebaseUid == null) return;

    final ref = FirebaseDatabase.instance.ref('user/$_firebaseUid');
    await ref.update({
      'videocall': 'offline',
      'voicecall': 'offline',
      'status': 'offline',
      'comswitch': 'offline',
    });

    if (_userId != null) {
      await _updateFirebaseIdAPI(_userId!, _firebaseUid!, 'offline');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 0 && _serviceFragmentKey.currentState != null) {
      if (_serviceFragmentKey.currentState!.isAnyServiceOn()) {
        _showServiceOffDialog(index);
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showServiceOffDialog(int nextIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Close Service'),
          ],
        ),
        content: const Text(
          'Your active services (Chat, Call, or Video Call) will be turned off. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _serviceFragmentKey.currentState?.turnOffAllServices();
              setState(() {
                _selectedIndex = nextIndex;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD6E62),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog() ?? false;
      },
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return ServiceFragment(
          key: _serviceFragmentKey,
          userId: _userId,
          firebaseUid: _firebaseUid,
        );
      case 1:
        return ProfileServiceFragment(userId: _userId);
      case 2:
        return const SettingsFragment();
      default:
        return ServiceFragment(
          key: _serviceFragmentKey,
          userId: _userId,
          firebaseUid: _firebaseUid,
        );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFD6E62),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    if (_serviceFragmentKey.currentState != null &&
        _serviceFragmentKey.currentState!.isAnyServiceOn()) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              SizedBox(width: 12),
              Text('Exit App'),
            ],
          ),
          content: const Text(
            'Some services are running. Stop them and exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _serviceFragmentKey.currentState?.turnOffAllServices();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange),
            SizedBox(width: 12),
            Text('Exit App'),
          ],
        ),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD6E62),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}