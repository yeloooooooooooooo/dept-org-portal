import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  String _selectedRole = 'student';
  String _selectedOrg = 'JPCS';
  String _selectedProgram = 'BSIT';
  String _selectedYear = '3rd Year';
  bool _obscurePassword = true;

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

  void _submitAuth() {
    final enteredName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : (_selectedRole == 'officer'
        ? '$_selectedOrg Officer'
        : 'CICS Student');
    final enteredId = _studentIdCtrl.text.trim().isNotEmpty
        ? _studentIdCtrl.text.trim()
        : '2024-00142';

    PortalRepository.instance.currentUser = UserProfile(
      uid: 'local_user_1',
      fullName: enteredName,
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : 'student@cics.edu',
      studentNumber: enteredId,
      program: _selectedProgram,
      yearLevel: _selectedYear,
      role: _selectedRole,
      orgCode: _selectedOrg,
    );

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
      body: Container(
        // Rich Two-Tone Light Canvas Backdrop (Soft Ice-Blue to Warm Gold Tint)
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
            // --- LIGHT-SIDE INVERSE ARCHITECTURAL DESIGN ---
            // 1. Crisp Blueprint Grid + Diagonal Tech Lines
            Positioned.fill(
              child: CustomPaint(
                painter: _InverseBlueprintPainter(),
              ),
            ),
            // 2. Large Decorative Concentric Rings (Bottom-Left)
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
            // 3. Soft Navy Decorative Ring (Bottom-Right)
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

            // --- FOREGROUND SCROLLABLE CONTENT ---
            ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                // Dark Navy & Gold Hero Header
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
                                // Primary CICS Crest at the Top
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
                                    'COLLEGE OF INFORMATION & COMPUTING SCIENCES',
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
                                      ? 'Create your student or officer pass in seconds.'
                                      : 'One unified portal for events, merch drops, and org tasks.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Connected Orgs Strip with Org Logos
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    'JPCS',
                                    'ACCESS',
                                    'INTESS',
                                    'CICS SC'
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

                // Clean Elevated White Auth Card (No Colored Top Line)
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
                              const Text(
                                'CONTINUE AS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: slateSub,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleTile(
                                      title: 'Student',
                                      subtitle: 'Events & tasks',
                                      icon: Icons.school_rounded,
                                      selected: _selectedRole == 'student',
                                      onTap: () => setState(
                                              () => _selectedRole = 'student'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _RoleTile(
                                      title: 'Org Officer',
                                      subtitle: 'Manage posts',
                                      icon: Icons.admin_panel_settings_rounded,
                                      selected: _selectedRole == 'officer',
                                      onTap: () => setState(
                                              () => _selectedRole = 'officer'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              if (_selectedRole == 'officer') ...[
                                const Text(
                                  'ORGANIZATION',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: slateSub,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedOrg,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
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
                                  items: ['JPCS', 'ACCESS', 'INTESS', 'CICS SC']
                                      .map((o) => DropdownMenuItem(
                                      value: o, child: Text(o)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedOrg = v);
                                    }
                                  },
                                ),
                                const SizedBox(height: 14),
                              ],

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
                                        items: ['BSIT', 'BSCS', 'BSIS']
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
                                          '4th Year'
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
                                label: 'University Email',
                                hint: '12-34567@g.batstate-u.edu.ph',
                                icon: Icons.alternate_email_rounded,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
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
                              const SizedBox(height: 22),

                              FilledButton(
                                onPressed: _submitAuth,
                                style: FilledButton.styleFrom(
                                  backgroundColor: navy,
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 18, color: gold),
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
                                    onPressed: () =>
                                        setState(() => _isSignUp = !_isSignUp),
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

                // Subtle Campus Footer Pill on the Lower Light Canvas
                Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

class _InverseBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0F2547).withValues(alpha: 0.045)
      ..strokeWidth = 1.0;

    // Subtle architectural grid lines across the lower light canvas
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Diagonal gold accent rays on the lower right
    final goldRayPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.14)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.65, size.height),
      Offset(size.width, size.height * 0.55),
      goldRayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height),
      Offset(size.width, size.height * 0.68),
      goldRayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? navy : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? gold : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? gold.withValues(alpha: 0.2)
                    : navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? gold : navy,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : navy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
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

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}