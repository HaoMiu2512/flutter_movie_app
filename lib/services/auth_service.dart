import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  AuthService() {
    // Configure GoogleSignIn based on platform
    if (kIsWeb) {
      // For Web, don't use serverClientId (it's not supported)
      _googleSignIn = GoogleSignIn(
        clientId: '1049565528209-s5e3g3feme8t939d0ho9p17bms65plrh.apps.googleusercontent.com',
      );
    } else {
      // For Mobile (Android/iOS), use serverClientId
      _googleSignIn = GoogleSignIn(
        serverClientId: '1049565528209-s5e3g3feme8t939d0ho9p17bms65plrh.apps.googleusercontent.com',
      );
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }

  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get username from email
  String? getUsername() {
    final email = _auth.currentUser?.email;
    if (email != null) {
      return email.split('@')[0];
    }
    return null;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw 'Google Sign-In was cancelled';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google Sign-In failed: ${e.toString()}';
    }
  }

  // Sign out from both Firebase and Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Phone Authentication - Send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(_handleAuthException(e));
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      verificationFailed('Phone verification failed: ${e.toString()}');
    }
  }

  // Phone Authentication - Verify OTP and Sign In
  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Invalid OTP code. Please try again.';
    }
  }

  // Link phone number to existing account
  Future<void> linkPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the Facebook Sign-In flow
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      // Check if login was successful
      if (loginResult.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = loginResult.accessToken!;

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in to Firebase with the Facebook credential
        return await _auth.signInWithCredential(facebookAuthCredential);
      } else if (loginResult.status == LoginStatus.cancelled) {
        throw 'Facebook Sign-In was cancelled';
      } else {
        throw 'Facebook Sign-In failed: ${loginResult.message ?? "Unknown error"}';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Facebook Sign-In failed: ${e.toString()}';
    }
  }

  // Sign out from both Firebase and Facebook
  Future<void> signOutFacebook() async {
    await _facebookAuth.logOut();
    await _auth.signOut();
  }

  // Get Facebook user data
  Future<Map<String, dynamic>?> getFacebookUserData() async {
    try {
      final userData = await _facebookAuth.getUserData();
      return userData;
    } catch (e) {
      return null;
    }
  }

  // Check if logged in with Facebook
  Future<bool> isLoggedInWithFacebook() async {
    final accessToken = await _facebookAuth.accessToken;
    return accessToken != null;
  }
}
