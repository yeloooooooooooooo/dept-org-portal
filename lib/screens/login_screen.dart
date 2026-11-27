import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  String _selectedProgram = 'BSIT';
  String _selectedYear = '3rd Year';
  bool _obscurePassword = true;
  String? _errorMessage;

  final _nameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Incorrect email or password. Please double-check both and try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Your email address is not verified yet. Check your inbox for the confirmation link.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already exists')) {
      return 'An account with this email already exists. Switch to Sign in instead.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a minute and try again.';
    }
    return e.message;
  }

Future<void> _submitAuth() async {
    setState(() => _errorMessage = null);

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (email.isEmpty && password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(
        () => _errorMessage =
            'Please enter a valid email address (e.g., @g.batstate-u.edu.ph).',
      );
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    if (_isSignUp && !email.endsWith('@g.batstate-u.edu.ph')) {
      setState(
        () => _errorMessage =
            'Registration requires a valid @g.batstate-u.edu.ph university email.',
      );
      return;
    }
    if (_isSignUp && password.length < 6) {
      setState(
        () => _errorMessage = 'Password must be at least 6 characters long.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String role;

      if (_isSignUp) {
        final fullName = _nameCtrl.text.trim().isNotEmpty
            ? _nameCtrl.text.trim()
            : 'CICS Student';
        final studentId = _studentIdCtrl.text.trim().isNotEmpty
            ? _studentIdCtrl.text.trim()
            : '2024-00142';

        // Creates the Auth user, inserts the 'student' profile, and loads it in one step
        role = await PortalRepository.instance.signUpStudent(
          email: email,
          password: password,
          fullName: fullName,
          studentNumber: studentId,
          program: _selectedProgram,
          yearLevel: _selectedYear,
        );
      } else {
        // Role ('student' or 'officer') is resolved purely from the database
        role = await PortalRepository.instance.signInAndLoadProfile(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavShell(userRole: role),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _mapAuthError(e));
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Profile record error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'Unable to sign in. Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
  final email = _emailCtrl.text.trim().toLowerCase();
  if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
    setState(
      () => _errorMessage =
          'Enter your account email above first so we can send a reset link.',
    );
    return;
  }

  setState(() {
    _errorMessage = null;
    _isLoading = true;
  });

  try {
    await PortalRepository.instance.sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: const Color(0xFF0F2547),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Password reset link sent to $email',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
  } on AuthException catch (e) {
    if (!mounted) return;
    setState(() => _errorMessage = _mapAuthError(e));
  } catch (_) {
    if (!mounted) return;
    setState(
      () => _errorMessage =
          'Could not send password reset email. Check your connection.',
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8EEF9),
              Color(0xFFF3F6FC),
              Color(0xFFFAF6EB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _InverseBlueprintPainter(),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -110,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.28),
                    width: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -90,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: navy.withValues(alpha: 0.045),
                  border: Border.all(
                    color: navy.withValues(alpha: 0.08),
                    width: 2,
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF071124),
                        Color(0xFF0F2547),
                        Color(0xFF1B3F7A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(36)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -70,
                        right: -50,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                gold.withValues(alpha: 0.22),
                                gold.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        left: -40,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF3B82F6).withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 28,
                        bottom: 18,
                        child: Icon(
                          Icons.hub_rounded,
                          size: 150,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          MediaQuery.of(context).padding.top + 20,
                          24,
                          48,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.14),
                                    border: Border.all(color: gold, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gold.withValues(alpha: 0.30),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/cics_logo.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.shield_rounded,
                                        color: gold,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.09),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: gold.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: const Text(
                                    'COLLEGE OF INFORMATICS & COMPUTING SCIENCES',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _isSignUp
                                      ? 'Join the CICS Hub'
                                      : 'Welcome back, Innovator',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.15,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isSignUp
                                      ? 'Create your student pass in seconds.'
                                      : 'One unified portal for events, merch drops, and org tasks.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    'JPCS',
                                    'ACCESS',
                                    'INTESS',
                                    'CICS SC',
                                  ]
                                      .map(
                                        (org) => Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          6, 4, 11, 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.10),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.14),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OrgLogoAvatar(
                                            orgCode: org,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            org,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isSignUp) ...[
                                _InputField(
                                  controller: _nameCtrl,
                                  label: 'Full Name',
                                  hint: 'e.g. Juan Dela Cruz',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 12),
                                _InputField(
                                  controller: _studentIdCtrl,
                                  label: 'Student ID',
                                  hint: 'e.g. 2024-00142',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedProgram,
                                        decoration: InputDecoration(
                                          labelText: 'Program',
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                                color: cardBorder),
                                          ),
                                        ),
                                        items: ['BSIT', 'BSCS']
                                            .map((p) => DropdownMenuItem(
                                            value: p, child: Text(p)))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(
                                                    () => _selectedProgram = v);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedYear,
                                        decoration: InputDecoration(
                                          labelText: 'Year',
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                                color: cardBorder),
                                          ),
                                        ),
                                        items: [
                                          '1st Year',
                                          '2nd Year',
                                          '3rd Year',
                                          '4th Year',
                                        ]
                                            .map((y) => DropdownMenuItem(
                                            value: y, child: Text(y)))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => _selectedYear = v);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              _InputField(
                                controller: _emailCtrl,
                                label: 'University or Org Email',
                                hint: '12-34567@g.batstate-u.edu.ph',
                                icon: Icons.alternate_email_rounded,
                                onChanged: (_) {
                                  if (_errorMessage != null) {
                                    setState(() => _errorMessage = null);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                onChanged: (_) {
                                  if (_errorMessage != null) {
                                    setState(() => _errorMessage = null);
                                  }
                                },
                                onSubmitted: (_) =>
                                _isLoading ? null : _submitAuth(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                      color: slateSub),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: slateSub,
                                    ),
                                    onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                    const BorderSide(color: cardBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                    const BorderSide(color: cardBorder),
                                  ),
                                ),
                              ),
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _isLoading ? null : _handleForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 1),
                                        child: Icon(
                                          Icons.error_outline_rounded,
                                          size: 18,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF991B1B),
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _isLoading ? null : _submitAuth,
                                style: FilledButton.styleFrom(
                                  backgroundColor: navy,
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: gold,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isSignUp
                                          ? 'Create Account'
                                          : 'Enter CICS Portal',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: gold),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp
                                        ? 'Already have a pass?'
                                        : 'New to CICS Portal?',
                                    style: const TextStyle(
                                        fontSize: 13, color: slateSub),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _isSignUp = !_isSignUp;
                                      _errorMessage = null;
                                    }),
                                    child: Text(
                                      _isSignUp ? 'Sign in' : 'Sign up',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: navy.withValues(alpha: 0.08)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 13, color: navy),
                        SizedBox(width: 6),
                        Text(
                          'CICS Student Portal • Events • Clearance • Merch',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: slateSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: slateSub),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
      ),
    );
  }
}

class _InverseBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0F2547).withValues(alpha: 0.045)
      ..strokeWidth = 1.0;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final goldRayPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.14)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width * 0.55, size.height),
      Offset(size.width, size.height * 0.65),
      goldRayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.78),
      goldRayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}