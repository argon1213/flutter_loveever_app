import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_scanner_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
  }

  Future<void> _redirectToWebsite(String idToken, String email) async {
    try {
      // Split display name into first name and last name
      final displayName = _authService.currentGoogleUser?.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final url = Uri.parse('https://loveevertagapps.com/api/auth/firebase-login')
          .replace(queryParameters: {
        'token': idToken,
        'provider': 'google',
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch website. Please try again later.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error redirecting to website: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        final idToken = await _authService.getIdToken();
        if (idToken != null && mounted) {
          await _redirectToWebsite(idToken, userCredential.user?.email ?? '');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Google: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F5),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      const Text(
                        'Every Story\nMatters.',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'One place to honor, remember,\nand share.',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Playfair_Display',
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          fontStyle: FontStyle.italic,
                          color: Color.fromARGB(255, 54, 54, 54),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      if (user == null && snapshot.connectionState == ConnectionState.active) ...[
                        // Show Sign-in buttons
                        _buildAuthButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const QRScannerPage()),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Scan a LoveEver Tag',
                        ),
                        const SizedBox(height: 12),
                        _buildAuthButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Image.asset(
                                  'assets/images/google-logo.png',
                                  height: 24,
                                  width: 24,
                                ),
                          label: _isLoading ? 'Signing in...' : 'Sign in with Google',
                        ),
                        const SizedBox(height: 12),
                        _buildAuthButton(
                          onPressed: _isLoading ? null : () async {
                            const url = 'https://loveevertagapps.com/Account/Login';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not launch URL')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.email_outlined, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Sign in with Email',
                        ),
                        const SizedBox(height: 12),
                        _buildAuthButton(
                          onPressed: _isLoading ? null : () async {
                            const url = 'https://loveevertagapps.com/Account/Register';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not launch URL')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.person_add_outlined, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Sign Up',
                        ),
                      ] else if (user != null) ...[
                        // Show Logged-in buttons
                        _buildAuthButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const QRScannerPage()),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Scan QR Code',
                        ),
                        const SizedBox(height: 12),
                        _buildAuthButton(
                          onPressed: () async {
                            final idToken = await _authService.getIdToken();
                            if (idToken != null && mounted) {
                              await _redirectToWebsite(idToken, user.email ?? '');
                            }
                          },
                          icon: const Icon(Icons.dashboard_outlined, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Dashboard',
                        ),
                        const SizedBox(height: 12),
                        _buildAuthButton(
                          onPressed: () async {
                            await _authService.signOut();
                          },
                          icon: const Icon(Icons.logout_outlined, size: 28, color: Color(0xFF1A1A1A)),
                          label: 'Sign Out (${user.displayName ?? 'User'})',
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDC8C0), width: 1),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: icon,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 