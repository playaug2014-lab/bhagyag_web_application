import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'splash_screen.dart';
import 'language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase init (Web + Mobile safe)
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAxicelGR9YL3QHjGLxYQmctQ_JLS2OKgk",
        authDomain: "bhagyag-dd89b.firebaseapp.com",
        databaseURL: "https://bhagyag-dd89b-default-rtdb.firebaseio.com",
        projectId: "bhagyag-dd89b",
        storageBucket: "bhagyag-dd89b.appspot.com",
        messagingSenderId: "274139082899",
        appId: "1:274139082899:web:d4b3be4cc0022fc1651d66",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        title: 'Bhagya G',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFA61C0A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA61C0A),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
