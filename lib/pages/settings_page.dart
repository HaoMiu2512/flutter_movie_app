import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/custom_snackbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() => _notificationsEnabled = value);
    _showSnackBar(
      value ? 'You will receive updates and notifications' : 'Notifications have been turned off',
      title: value ? 'Notifications Enabled' : 'Notifications Disabled',
      icon: Icons.notifications,
      iconColor: Colors.orange,
    );
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    setState(() => _selectedLanguage = value);
    _showSnackBar(
      'Please restart the app to see changes',
      title: 'Language Updated',
      icon: Icons.language,
      iconColor: Colors.blue,
    );
  }

  void _showSnackBar(String message, {String? title, Color? iconColor, IconData? icon}) {
    if (mounted) {
      // Use CustomSnackBar based on icon color
      if (iconColor == Colors.orange) {
        CustomSnackBar.showWarning(context, message);
      } else if (iconColor == Colors.blue) {
        CustomSnackBar.showInfo(context, message);
      } else if (iconColor == Colors.green) {
        CustomSnackBar.showSuccess(context, message);
      } else if (iconColor == Colors.red) {
        CustomSnackBar.showError(context, message);
      } else {
        CustomSnackBar.showInfo(context, message);
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1929),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Text(
          'Select Language',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇺🇸'),
            const SizedBox(height: 8),
            _buildLanguageOption('vi', 'Tiếng Việt', '🇻🇳'),
            const SizedBox(height: 8),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
            const SizedBox(height: 8),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            const SizedBox(height: 8),
            _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _saveLanguage(code);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyan.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.cyan
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.cyan : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.cyan, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Flick',
      applicationVersion: '$_appVersion ($_buildNumber)',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/Flick.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A beautiful movie app built with Flutter and Firebase.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2024 Flick',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 25, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(Icons.people_outline, color: Colors.cyan, size: 28),
            SizedBox(width: 12),
            Text(
              'About Us',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/Flick.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Welcome Text
              const Text(
                'Welcome to Flick!',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Flick is your ultimate movie companion, designed to help you discover, track, and enjoy your favorite films and TV series.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Features Section
              const Text(
                'Features:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('🎬', 'Browse thousands of movies and TV shows'),
              _buildFeatureItem('⭐', 'Track your favorites and watchlists'),
              _buildFeatureItem('💬', 'Share reviews and comments'),
              _buildFeatureItem('🔥', 'Discover trending content'),
              _buildFeatureItem('📱', 'Beautiful, modern interface'),
              const SizedBox(height: 16),
              
              // Team Section
              const Text(
                'Our Mission:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We believe that everyone deserves easy access to quality entertainment. Flick was created to bring movie lovers together and make discovering your next favorite film simple and enjoyable.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Contact
              const Text(
                'Get in Touch:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildContactItem(Icons.email_outlined, 'support@flick.app'),
              _buildContactItem(Icons.language, 'www.flick.app'),
              const SizedBox(height: 16),
              
              // Footer
              Center(
                child: Text(
                  'Made with ❤️ by Haotonn',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.cyan,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 25, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: Colors.purple, size: 28),
            SizedBox(width: 12),
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: November 2024',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              
              // Introduction
              const Text(
                '1. Introduction',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to Flick. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Data Collection
              const Text(
                '2. Data We Collect',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPrivacyItem('Account Information', 'Email, name, and profile picture when you sign up'),
              _buildPrivacyItem('Usage Data', 'Movies you watch, favorites, and watchlists'),
              _buildPrivacyItem('Device Information', 'Device type, OS version, and app version'),
              _buildPrivacyItem('Reviews & Comments', 'Content you post in the app'),
              const SizedBox(height: 16),
              
              // How We Use Data
              const Text(
                '3. How We Use Your Data',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPrivacyItem('Personalization', 'To provide personalized movie recommendations'),
              _buildPrivacyItem('Account Management', 'To manage your account and preferences'),
              _buildPrivacyItem('Communication', 'To send important updates about the service'),
              _buildPrivacyItem('Analytics', 'To improve our app and user experience'),
              const SizedBox(height: 16),
              
              // Data Protection
              const Text(
                '4. Data Protection',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We implement industry-standard security measures to protect your data. Your information is encrypted in transit and at rest. We use Firebase Authentication and secure cloud storage.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Third-Party Services
              const Text(
                '5. Third-Party Services',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPrivacyItem('TMDB', 'Movie and TV show data from The Movie Database'),
              _buildPrivacyItem('Firebase', 'Authentication and cloud storage'),
              _buildPrivacyItem('Google Sign-In', 'For easy account creation'),
              _buildPrivacyItem('Facebook Login', 'Alternative sign-in option'),
              const SizedBox(height: 16),
              
              // Your Rights
              const Text(
                '6. Your Rights',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have the right to:\n\n'
                '• Access your personal data\n'
                '• Update or correct your information\n'
                '• Delete your account and data\n'
                '• Export your data\n'
                '• Opt-out of communications',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Contact
              const Text(
                '7. Contact Us',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you have questions about this Privacy Policy, please contact us at:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildContactItem(Icons.email_outlined, 'privacy@flick.app'),
              const SizedBox(height: 16),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'By using Flick, you agree to this Privacy Policy. We may update this policy from time to time, and we will notify you of significant changes.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section (Coming Soon)
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Always on (Light mode coming soon)',
                value: true,
                onChanged: (value) {
                  _showSnackBar(
                    'We are working on light mode. Stay tuned for updates!',
                    title: 'Coming Soon',
                    icon: Icons.info_outline,
                    iconColor: Colors.purple,
                  );
                },
                color: Colors.purple,
              ),
            ]),

            const SizedBox(height: 24),

            // Language Section
            _buildSectionTitle('Language'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.language,
                title: 'App Language',
                subtitle: _getLanguageName(_selectedLanguage),
                color: Colors.blue,
                onTap: _showLanguageDialog,
              ),
            ]),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive updates and news',
                value: _notificationsEnabled,
                onChanged: _saveNotifications,
                color: Colors.orange,
              ),
            ]),

            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '$_appVersion ($_buildNumber)',
                color: Colors.green,
                onTap: _showAboutDialog,
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildActionTile(
                icon: Icons.people_outline,
                title: 'About Us',
                subtitle: 'Learn more about our team',
                color: Colors.blue,
                onTap: _showAboutUsDialog,
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                color: Colors.purple,
                onTap: _showPrivacyPolicyDialog,
              ),
            ]),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/Flick.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Flick',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $_appVersion',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with Haotonn using Flutter',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.cyan[300],
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English 🇺🇸';
      case 'vi':
        return 'Tiếng Việt 🇻🇳';
      case 'es':
        return 'Español 🇪🇸';
      case 'fr':
        return 'Français 🇫🇷';
      case 'de':
        return 'Deutsch 🇩🇪';
      default:
        return 'English 🇺🇸';
    }
  }
}
