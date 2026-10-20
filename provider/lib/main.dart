import 'package:flutter/material.dart';
import 'services/password_reset_link_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'views/auth_gate.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.authService});
  final AuthService? authService;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigatorKey,
    builder: (context, child) => PasswordResetLinkHandler(
      navigatorKey: _navigatorKey, child: child ?? const SizedBox.shrink()),
    debugShowCheckedModeBanner: false,
    title: 'سير - مزود الخدمة',
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.data,
    home: AuthGate(authService: widget.authService),
  );
}
