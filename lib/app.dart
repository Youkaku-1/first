import 'package:flutter/material.dart';

import 'models/rate_detail_args.dart';
import 'screens/home_screen.dart';
import 'screens/rate_detail_screen.dart';
import 'screens/splash_screen.dart';

void runCurrencyApp() {
  runApp(const CurrencyCompassApp());
}

class CurrencyCompassApp extends StatelessWidget {
  const CurrencyCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B6E4F),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F1E8),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8D2C2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0B6E4F), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Compass',
      theme: theme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == RateDetailScreen.routeName) {
          final args = settings.arguments;
          if (args is RateDetailArgs) {
            return MaterialPageRoute<void>(
              builder: (_) => RateDetailScreen(args: args),
            );
          }
        }

        return null;
      },
    );
  }
}
