import 'package:flutter/material.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  String _selectedRole = 'student';
  String _selectedOrg = 'JPCS';

  final List<String> _orgs = ['JPCS', 'ACCESS', 'INTESS', 'CICS SC'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavShell(userRole: _selectedRole),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Pill matching your mockup headers
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: navy),
                      SizedBox(width: 6),
                      Text(
                        'CICS Portal',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Editorial Headline matching "Find your next campus moment."
                Text(
                  _isLogin
                      ? 'Welcome back\nto CICS.'
                      : 'Join your\ncampus community.',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: navy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Stay in the loop. Sign in to track events & checklists.'
                      : 'One account for JPCS, ACCESS, INTESS, and CICS SC.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: slateSub,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Main White Card Container matching your mockup cards
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Selector Pills
                        const Text(
                          'SIGN IN AS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: slateSub,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _RolePill(
                                label: 'Student',
                                icon: Icons.school_outlined,
                                selected: _selectedRole == 'student',
                                onTap: () =>
                                    setState(() => _selectedRole = 'student'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RolePill(
                                label: 'Officer',
                                icon: Icons.admin_panel_settings_outlined,
                                selected: _selectedRole == 'officer',
                                onTap: () =>
                                    setState(() => _selectedRole = 'officer'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (!_isLogin) ...[
                          _buildLabel('Full name'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              hint: 'e.g. Andrea Reyes',
                              icon: Icons.person_outline,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Enter your full name'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          if (_selectedRole == 'officer') ...[
                            _buildLabel('Managing organization'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedOrg,
                              decoration: _inputDecoration(
                                hint: 'Select organization',
                                icon: Icons.groups_outlined,
                              ),
                              items: _orgs
                                  .map((org) => DropdownMenuItem(
                                  value: org, child: Text(org)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedOrg = val!),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],

                        _buildLabel('University email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hint: 'name@cics.edu',
                            icon: Icons.email_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter your university email';
                            }
                            if (!val.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: slateSub,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Minimum 6 characters required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Primary Navy CTA Button matching "Open Official Form"
                        FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin ? 'Continue to Portal' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward,
                                  size: 18, color: gold),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Switch between Sign In & Register
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: slateSub),
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? 'New to CICS Portal? '
                                : 'Already have an account? ',
                          ),
                          TextSpan(
                            text: _isLogin ? 'Register' : 'Sign in',
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F2547),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F2547), width: 1.5),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RolePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? navy : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? navy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : const Color(0xFF0F2547),
              ),
            ),
          ],
        ),
      ),
    );
  }
}