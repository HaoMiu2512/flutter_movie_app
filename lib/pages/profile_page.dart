import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingAvatar = false;

  User? get currentUser => _authService.currentUser;
  String? get userEmail => currentUser?.email;
  String? get displayName => currentUser?.displayName;
  String? get photoURL => currentUser?.photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      _displayNameController.text = displayName ?? userEmail?.split('@')[0] ?? '';
      _avatarUrlController.text = photoURL ?? '';
    }
  }

  Future<void> _updateDisplayName() async {
    if (_displayNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a name', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await currentUser?.updateDisplayName(_displayNameController.text.trim());
      await currentUser?.reload();

      // Update in Firestore
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'displayName': _displayNameController.text.trim(),
          'email': userEmail,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      }

      setState(() {
        _isEditingName = false;
      });
      _showSnackBar('Name updated successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating name: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAvatarUrl() async {
    final url = _avatarUrlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please enter a valid URL', Colors.red);
      return;
    }

    // Simple URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showSnackBar('URL must start with http:// or https://', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update Firebase Auth profile
      await currentUser?.updatePhotoURL(url);
      await currentUser?.reload();

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'photoURL': url,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      setState(() {
        _isEditingAvatar = false;
      });

      _showSnackBar('Avatar updated successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating avatar: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAvatarDialog() {
    _avatarUrlController.text = photoURL ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1929),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Text(
          'Update Avatar',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter image URL:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _avatarUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://example.com/avatar.jpg',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Right-click an image online and copy its URL',
              style: TextStyle(
                color: Colors.cyan[300],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAvatarUrl();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E3C),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1929),
              Color(0xFF001E3C),
              Color(0xFF000000),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.cyan),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar Section
                    _buildAvatarSection(),
                    const SizedBox(height: 30),

                    // User Info Card
                    _buildUserInfoCard(),
                    const SizedBox(height: 20),

                    // Action Buttons Card
                    _buildActionButtonsCard(),
                    const SizedBox(height: 20),

                    // Account Stats Card
                    _buildAccountStatsCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.tealAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : ClipOval(
                      child: photoURL != null && photoURL!.isNotEmpty
                          ? Image.network(
                              photoURL!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isLoading ? null : _showAvatarDialog,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.tealAccent],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName ?? userEmail?.split('@')[0] ?? 'User',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail ?? '',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.cyan.withValues(alpha: 0.3),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      color: const Color(0xFF0A1929),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    color: Colors.cyan[300],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEditingName)
                  IconButton(
                    onPressed: () {
                      setState(() => _isEditingName = true);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.cyan[400],
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Display Name
            const Text(
              'Display Name',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditingName)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _displayNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _updateDisplayName,
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isEditingName = false);
                      _loadUserData();
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayName ?? userEmail?.split('@')[0] ?? 'Not set',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Email (Read-only)
            const Text(
              'Email',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      userEmail ?? 'Not available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard() {
    return Card(
      color: const Color(0xFF0A1929),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                color: Colors.cyan[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Change Password Button
            _buildActionButton(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
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

  Widget _buildAccountStatsCard() {
    return Card(
      color: const Color(0xFF0A1929),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                color: Colors.cyan[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              value: _formatDate(currentUser?.metadata.creationTime),
            ),
            const Divider(height: 32, color: Colors.grey),
            _buildStatRow(
              icon: Icons.login,
              label: 'Last Login',
              value: _formatDate(currentUser?.metadata.lastSignInTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.cyan, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
