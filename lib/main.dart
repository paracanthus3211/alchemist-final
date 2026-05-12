import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const MyApp());
}

// Tambahkan class ini untuk mengaktifkan geser dengan mouse (drag)
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Alchemist',
          debugShowCheckedModeBanner: false,
          // Gunakan ScrollBehavior kustom di sini
          scrollBehavior: MyCustomScrollBehavior(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B0CC)),
            useMaterial3: true,
            textTheme: GoogleFonts.spaceGroteskTextTheme(),
          ),
          builder: (context, child) {
            final double scale = SettingsService().fontSizeMultiplier;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
