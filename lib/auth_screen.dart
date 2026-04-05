import 'package:flutter/material.dart';
import 'main.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late TabController _tabController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(bool isLogin) async {
    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Color(0xFF6b6b7e),
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure && _obscurePassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFd8d8e8), fontSize: 14),
          decoration: InputDecoration(
            hintText: label == 'Password' ? '••••••••' : 'Enter your $label',
            hintStyle: const TextStyle(color: Color(0xFF3a3a52)),
            filled: true,
            fillColor: const Color(0xFF13131f),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF4a4a62),
                        size: 18),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : Icon(icon, color: const Color(0xFF4a4a62), size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2a2a3e)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2a2a3e)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFc9a84c)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(String text, bool isLogin) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleAuth(isLogin),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: const Color(0xFFc9a84c),
          foregroundColor: const Color(0xFF0a0a0f),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFb8920e), Color(0xFFf0d080), Color(0xFFb8920e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Text('💎', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 14),
              const Text('Gem Store',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFf0d080),
                      letterSpacing: 1)),
              const SizedBox(height: 4),
              const Text('PREMIUM COLLECTION',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Color(0xFF6b6b7e))),
              const SizedBox(height: 28),
              // Tab Bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color(0xFF13131f),
                    borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                      color: const Color(0xFF1f1f30),
                      borderRadius: BorderRadius.circular(9)),
                  labelColor: const Color(0xFFf0d080),
                  unselectedLabelColor: const Color(0xFF5a5a72),
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Login Panel
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 18),
                        _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: true),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Forgot password?',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8a7a3a),
                                    letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMainButton('Sign In', true),
                        const SizedBox(height: 20),
                        Row(children: [
                          const Expanded(
                              child: Divider(color: Color(0xFF1e1e2e))),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or continue with',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF3a3a52)))),
                          const Expanded(
                              child: Divider(color: Color(0xFF1e1e2e))),
                        ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: _socialBtn('G')),
                          const SizedBox(width: 12),
                          Expanded(child: _socialBtn('⌘')),
                        ]),
                      ],
                    ),
                    // Register Panel
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline),
                        const SizedBox(height: 18),
                        _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 18),
                        _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: true),
                        const SizedBox(height: 24),
                        _buildMainButton('Create Account', false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialBtn(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF13131f),
          border: Border.all(color: const Color(0xFF2a2a3e)),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFFd8d8e8)))),
    );
  }
}