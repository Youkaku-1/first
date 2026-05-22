import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/saved_conversion.dart';
import '../services/local_auth_service.dart';
import '../services/saved_conversion_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/brand_mark.dart';
import 'converter_screen.dart';
import 'login_screen.dart';
import 'rates_screen.dart';
import 'saved_conversions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = LocalAuthService();
  final _storage = SavedConversionStorage();
  int _selectedIndex = 0;
  int _savedScreenVersion = 0;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
  }

  Future<void> _handleSavedConversion(SavedConversion conversion) async {
    await _storage.add(conversion);
    if (!mounted) return;
    setState(() => _savedScreenVersion++);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conversion saved locally.')));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ConverterScreen(onSave: _handleSavedConversion),
      const RatesScreen(),
      SavedConversionsScreen(version: _savedScreenVersion),
    ];

    final titles = ['Convert', 'Markets', 'Saved'];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: _DashboardTopBar(
                  title: titles[_selectedIndex],
                  userName: _currentUser?.name ?? 'Currency User',
                  onLogout: _logout,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: pages[_selectedIndex],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        decoration: BoxDecoration(
          color: AppTheme.bgDark,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.violet.withValues(alpha: 0.32),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_rounded, color: Colors.white70),
              selectedIcon: Icon(Icons.swap_horiz_rounded, color: Colors.white),
              label: 'Convert',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_rounded, color: Colors.white70),
              selectedIcon: Icon(Icons.show_chart_rounded, color: Colors.white),
              label: 'Rates',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_rounded, color: Colors.white70),
              selectedIcon: Icon(Icons.bookmark_rounded, color: Colors.white),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({
    required this.title,
    required this.userName,
    required this.onLogout,
  });

  final String title;
  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              Text(
                'Hello, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
        ),
      ],
    );
  }
}
