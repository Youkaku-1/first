import 'package:flutter/material.dart';

import 'models/rate_detail_args.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/rate_detail_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void runCurrencyApp() {
  runApp(const CurrencyCompassApp());
}

class CurrencyCompassApp extends StatelessWidget {
  const CurrencyCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Compass',
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
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
