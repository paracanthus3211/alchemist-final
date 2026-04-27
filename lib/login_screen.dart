import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_button.dart';
import 'widgets/custom_back_button.dart';
import 'signup_screen.dart';
import 'main_scaffold.dart';
import 'admin_dashboard_screen.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final result = await ApiService().login(
      _emailController.text,
      _passwordController.text,
    );
    
    final user = result['user'];
    final error = result['error'];
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
    return BackgroundWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const CustomBackButton(),
            const SizedBox(height: 32),
            
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Welcome '),
                    TextSpan(
                      text: 'Back',
                      style: TextStyle(color: Color(0xFF00E5FF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SocialButton(
              text: 'CONTINUE WITH FACEBOOK',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
              onPressed: () {},
            ),
            SocialButton(
              text: 'CONTINUE WITH GOOGLE',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              icon: _googleIcon(),
              onPressed: () {},
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Text(
                'LOG IN MANUALLY',
                style: TextStyle(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildLoginFormCard(context),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          // Subtle glow top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFFCCFF00).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('USERNAME'),
                CustomTextField(
                  hintText: 'Nikola Tesla',
                  prefixIconData: Icons.person_outline,
                  controller: _emailController, // Using email controller for username/email login
                ),
                const SizedBox(height: 16),
                
                _buildLabel('PASSWORD'),
                CustomTextField(
                  hintText: '••••••••••',
                  obscureText: true,
                  prefixIconData: Icons.lock_outline,
                  controller: _passwordController,
                ),
                
                const SizedBox(height: 32),
                
                // Login Button with Gradient
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF008B99)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Color(0xFF0B1214), strokeWidth: 2)
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Color(0xFF0B1214),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Divider(color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(height: 24),
                
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up →',
                          style: TextStyle(
                            color: Color(0xFFCCFF00), // Lime accent
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))), // Google Blue
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))), // Google Red
          TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))), // Google Yellow
          TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))), // Google Blue
          TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))), // Google Green
          TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))), // Google Red
        ],
      ),
    );
  }
}
