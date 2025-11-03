import 'package:flutter/material.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
import 'HomePage/HomePage.dart';
import 'pages/favorites_page.dart';
import 'pages/profile_page.dart';
import 'pages/my_lists_page.dart';

class MainScreen extends StatefulWidget {
  final String? username;
  const MainScreen({super.key, this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(username: widget.username),
      const FavoritesPage(),
      const MyListsPage(),
      const ProfilePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: ResponsiveNavigationBar(
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          navigationBarButtons: <NavigationBarButton>[
            NavigationBarButton(
              text: 'Home',
              icon: Icons.home_rounded,
              backgroundGradient: LinearGradient(
                colors: [
                  const Color(0xFF1E88E5),
                  const Color(0xFF1565C0),
                ],
              ),
            ),
            NavigationBarButton(
              text: 'Favorites',
              icon: Icons.favorite_rounded,
              backgroundGradient: LinearGradient(
                colors: [
                  const Color(0xFFFF0080),
                  const Color(0xFFFF1744),
                ],
              ),
            ),
            NavigationBarButton(
              text: 'My Lists',
              icon: Icons.bookmark_rounded,
              backgroundGradient: LinearGradient(
                colors: [
                  const Color(0xFF00BCD4),
                  const Color(0xFF00ACC1),
                ],
              ),
            ),
            NavigationBarButton(
              text: 'Profile',
              icon: Icons.person_rounded,
              backgroundGradient: LinearGradient(
                colors: [
                  const Color(0xFFB100FF),
                  const Color(0xFF8E00FF),
                ],
              ),
            ),
          ],
          // Màu nền sáng hơn
          backgroundColor: const Color(0xFF0F2744),

          // Màu khi được chọn - Xanh dương đậm
          activeIconColor: const Color(0xFF2196F3),
          inactiveIconColor: Colors.grey.shade400,

          // Font size - tăng lên để icon cũng to hơn
          fontSize: 15,

          // Border radius - chỉ nhận double
          borderRadius: 32,

          // Padding
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          // Active button style
          activeButtonFlexFactor: 150,
          inactiveButtonsFlexFactor: 100,

          // Shadow
          showActiveButtonText: true,
          ),
        ),
      ),
    );
  }
}
