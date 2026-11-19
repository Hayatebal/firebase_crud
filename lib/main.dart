import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Firebase Balila-on',
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.copyWith(
          displayLarge: baseTheme.textTheme.displayLarge?.copyWith(fontSize: 14),
          displayMedium: baseTheme.textTheme.displayMedium?.copyWith(fontSize: 14),
          displaySmall: baseTheme.textTheme.displaySmall?.copyWith(fontSize: 14),
          headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(fontSize: 14),
          headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(fontSize: 14),
          headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(fontSize: 14),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: 14),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 14),
          titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontSize: 14),
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(fontSize: 14),
          labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontSize: 14),
          labelMedium: baseTheme.textTheme.labelMedium?.copyWith(fontSize: 14),
          labelSmall: baseTheme.textTheme.labelSmall?.copyWith(fontSize: 14),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Firebase Balila-on'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            // User is logged in
            return const HomePage();
          } else {
            // User is not logged in
            return const LoginPage();
          }
        },
      ),
    );
  }
}
