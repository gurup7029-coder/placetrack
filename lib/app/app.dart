import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../services/theme_service.dart';
import 'theme.dart';

class PlaceTrackApp extends StatelessWidget {
  const PlaceTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final themeService = ThemeService();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PlaceTrack — Placement & Training Console',
          // Distinct Web-Exclusive Theme for Web, Original Theme for Mobile
          theme: kIsWeb ? PlaceTrackTheme.webLight() : PlaceTrackTheme.light(),
          darkTheme: kIsWeb ? PlaceTrackTheme.webDark() : PlaceTrackTheme.dark(),
          themeMode: kIsWeb ? ThemeMode.dark : themeService.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
