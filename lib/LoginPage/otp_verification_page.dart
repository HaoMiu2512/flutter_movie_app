import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  // Resend OTP countdown
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  String _currentVerificationId = '';

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleResendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _currentVerificationId = verificationId;
            _isLoading = false;
          });

          _startResendTimer();

          if (mounted) {
            CustomSnackBar.showSuccess(context, 'OTP code has been resent!');
          }
        },
        verificationFailed: (String error) {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            CustomSnackBar.showError(context, error);
          }
        },
        verificationCompleted: (credential) async {
          // Auto-verification (usually on Android)
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            setState(() {
              _isLoading = false;
            });

            if (mounted) {
              String username = FirebaseAuth.instance.currentUser?.phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? 'User';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(username: username),
                ),
                (route) => false,
              );
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verify OTP and sign in
        final userCredential = await _authService.signInWithPhoneNumber(
          verificationId: _currentVerificationId,
          smsCode: _otpController.text.trim(),
        );

        // Get username from phone number or user data
        String username = userCredential.user?.displayName ??
                          userCredential.user?.phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '') ??
                          'User';

        if (mounted) {
          // Show success message
          CustomSnackBar.showSuccess(context, 'Phone verification successful!');

          // Navigate to MainScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(username: username),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.cyan[400]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Icon
                    Icon(
                      Icons.message_rounded,
                      size: 80,
                      color: Colors.cyan[400],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'We sent a verification code to\n'),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: TextStyle(
                                color: Colors.cyan[300],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // OTP Input Field
                    TextFormField(
                      controller: _otpController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Enter 6-digit code',
                        labelStyle: TextStyle(color: Colors.cyan[300]),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.cyan.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.cyan,
                            width: 2,
                          ),
                        ),
                        hintText: '• • • • • •',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter OTP code';
                        }
                        if (value.length != 6) {
                          return 'OTP must be 6 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Only numbers allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan[600],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.cyan[600]?.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.cyan.withValues(alpha: 0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_user, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'VERIFY & SIGN IN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resend Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if (_canResend)
                          TextButton(
                            onPressed: _isLoading ? null : _handleResendOTP,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: Colors.cyan[400],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: null,
                            child: Text(
                              'Resend in ${_resendCountdown}s',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.cyan[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The code may take a few moments to arrive. Check your messages.',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
