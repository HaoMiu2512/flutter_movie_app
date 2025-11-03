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
                icon: Icons.code,
                title: 'Open Source Licenses',
                subtitle: 'View licenses',
                color: Colors.cyan,
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Flick',
                    applicationVersion: _appVersion,
                  );
                },
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
