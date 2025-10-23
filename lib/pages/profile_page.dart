import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../services/recently_viewed_service.dart';
import '../models/movie.dart';
import '../details/moviesdetail.dart';
import '../details/tvseriesdetail.dart';
import 'change_password_page.dart';
import 'recently_viewed_all_page.dart';
import 'settings_page.dart';
import '../LoginPage/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final RecentlyViewedService _recentlyViewedService = RecentlyViewedService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isUploadingAvatar = false;

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
      // Update display name
      await currentUser?.updateDisplayName(_displayNameController.text.trim());

      // Reload to get fresh data
      await currentUser?.reload();

      // Force refresh the auth state
      await FirebaseAuth.instance.currentUser?.reload();

      // Update in Firestore
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'displayName': _displayNameController.text.trim(),
          'email': userEmail,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      }

      // Refresh UI
      if (mounted) {
        setState(() {
          _isEditingName = false;
        });
      }

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

      _showSnackBar('Avatar updated successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating avatar: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploadingAvatar = true);

      String downloadURL;

      if (kIsWeb) {
        // For Web
        final bytes = await image.readAsBytes();
        final ref = _storage.ref().child('avatars/${currentUser!.uid}.jpg');
        await ref.putData(bytes);
        downloadURL = await ref.getDownloadURL();
      } else {
        // For Mobile
        final File file = File(image.path);
        final ref = _storage.ref().child('avatars/${currentUser!.uid}.jpg');
        await ref.putFile(file);
        downloadURL = await ref.getDownloadURL();
      }

      // Update Firebase Auth profile
      await currentUser?.updatePhotoURL(downloadURL);
      await currentUser?.reload();

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'photoURL': downloadURL,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      setState(() {});

      _showSnackBar('Avatar uploaded successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error uploading avatar: $e', Colors.red);
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  void _showAvatarOptionsDialog() {
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
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose how you want to update your avatar:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Option 1: Upload File
            _buildAvatarOptionCard(
              icon: Icons.upload_file,
              title: 'Upload File',
              subtitle: 'Select an image from your device',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAvatar();
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Enter URL
            _buildAvatarOptionCard(
              icon: Icons.link,
              title: 'Enter URL',
              subtitle: 'Paste an image URL from the internet',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _showAvatarUrlDialog();
              },
            ),
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

  Widget _buildAvatarOptionCard({
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
            width: 1.5,
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
              child: Icon(icon, color: color, size: 28),
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
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarUrlDialog() {
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
          'Enter Image URL',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste the image URL below:',
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
        automaticallyImplyLeading: false,
        actions: [
          // Settings button ở góc phải
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 26,
            ),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
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

                    // Recently Viewed Section
                    _buildRecentlyViewedSection(),
                    const SizedBox(height: 20),

                    // Action Buttons Card (Security)
                    _buildActionButtonsCard(),
                    const SizedBox(height: 20),

                    // Account Stats Card
                    _buildAccountStatsCard(),
                    const SizedBox(height: 30),

                    // Logout Button ở dưới cùng
                    _buildLogoutButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  // Logout Button Widget
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF0A1929),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                ),
                title: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[300], size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.cyan[400]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            // Perform logout
            await _authService.signOut();

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, size: 22),
        label: const Text(
          'LOGOUT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.red.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
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
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.cyan[300],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recently Viewed',
                      style: TextStyle(
                        color: Colors.cyan[300],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // See All button
                    TextButton(
                      onPressed: _showAllRecentlyViewed,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.cyan[300],
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.cyan[300],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.cyan[300],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Clear button
                    IconButton(
                      onPressed: _confirmClearRecentlyViewed,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[300],
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'Clear all',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Movie>>(
              stream: _recentlyViewedService.getRecentlyViewedStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading recently viewed',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  );
                }

                final movies = snapshot.data ?? [];

                if (movies.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recently viewed movies',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Movies you view will appear here',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: 245,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length > 10 ? 10 : movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return _buildRecentlyViewedItem(movie);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedItem(Movie movie) {
    // Ensure posterPath starts with /
    final posterUrl = movie.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath.startsWith('/') ? movie.posterPath : '/${movie.posterPath}'}'
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => movie.mediaType == 'tv'
                ? TvSeriesDetail(id: movie.id)
                : MoviesDetail(id: movie.id),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 170,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.movie,
                            color: Colors.grey,
                            size: 50,
                          ),
                  ),
                ),
                // Media type badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: movie.mediaType == 'tv'
                          ? Colors.purple[700]
                          : Colors.blue[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      movie.mediaType == 'tv' ? 'TV' : 'MOVIE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Movie Title
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Rating
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show all recently viewed movies
  void _showAllRecentlyViewed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecentlyViewedAllPage(),
      ),
    );
  }

  // Confirm before clearing all recently viewed
  Future<void> _confirmClearRecentlyViewed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1929),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Clear History?',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all recently viewed movies? This action cannot be undone.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await _recentlyViewedService.clearAllRecentlyViewed();
      setState(() => _isLoading = false);

      if (mounted) {
        _showSnackBar(
          success
              ? 'Recently viewed cleared successfully'
              : 'Failed to clear recently viewed',
          success ? Colors.green[700]! : Colors.red[700]!,
        );
      }
    }
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
                onTap: _isLoading ? null : _showAvatarOptionsDialog,
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
    // Check if user has email/password provider
    final hasPasswordProvider = currentUser?.providerData
        .any((info) => info.providerId == 'password') ?? false;

    // Get the login method for display
    String loginMethod = 'Unknown';
    if (currentUser?.providerData.isNotEmpty ?? false) {
      final providerId = currentUser!.providerData.first.providerId;
      switch (providerId) {
        case 'password':
          loginMethod = 'Email/Password';
          break;
        case 'google.com':
          loginMethod = 'Google';
          break;
        case 'facebook.com':
          loginMethod = 'Facebook';
          break;
        case 'phone':
          loginMethod = 'Phone Number';
          break;
        default:
          loginMethod = providerId;
      }
    }

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

            // Login Method Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loginMethod,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Change Password Button (only for email/password users)
            if (hasPasswordProvider)
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
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_outline, color: Colors.grey, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Change Password',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Not available for $loginMethod login',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.block,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
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
