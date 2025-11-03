import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'otp_verification_page.dart';
import '../widgets/custom_snackbar.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String _selectedCountryCode = '+84'; // Vietnam country code

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String fullPhoneNumber = _selectedCountryCode + _phoneController.text.trim();

      try {
        await _authService.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
            });

            if (mounted) {
              // Navigate to OTP verification page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpVerificationPage(
                    verificationId: verificationId,
                    phoneNumber: fullPhoneNumber,
                  ),
                ),
              );
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
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification completed (Android only)
            try {
              await FirebaseAuth.instance.signInWithCredential(credential);
              setState(() {
                _isLoading = false;
              });

              if (mounted) {
                CustomSnackBar.showSuccess(context, 'Phone verification successful!');
                Navigator.pop(context);
              }
            } catch (e) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-retrieval timeout
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
                      Icons.phone_android_rounded,
                      size: 80,
                      color: Colors.cyan[400],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Phone Sign-In',
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
                      child: Text(
                        'Enter your phone number to receive a verification code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Phone Number Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              dropdownColor: Color(0xFF001E3C),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.cyan[400]),
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              items: [
                                DropdownMenuItem(value: '+84', child: Text('+84')),
                                DropdownMenuItem(value: '+1', child: Text('+1')),
                                DropdownMenuItem(value: '+44', child: Text('+44')),
                                DropdownMenuItem(value: '+91', child: Text('+91')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountryCode = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Phone Number Input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.cyan[300]),
                              prefixIcon: Icon(Icons.phone, color: Colors.cyan[400]),
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
                              hintText: '123456789',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length < 9) {
                                return 'Phone number is too short';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Only numbers allowed';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendOTP,
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
                                  Icon(Icons.sms, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SEND OTP',
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
                              'You will receive a 6-digit verification code via SMS',
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
