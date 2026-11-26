import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../widgets/org_logo_avatar.dart';
import 'create_post_screen.dart';
import 'event_details_screen.dart';
import 'login_screen.dart';

class OfficerDashboardScreen extends StatefulWidget {
  final String userRole;
  final String orgCode;

  const OfficerDashboardScreen({
    super.key,
    required this.userRole,
    this.orgCode = 'JPCS',
  });

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  bool _showDrafts = false;
  bool _eventReminders = true;
  bool _merchAlerts = true;

  // Editable Student Profile State
  String _studentName = 'CICS Student';
  String _studentNumber = '2024-00142';
  String _program = 'BSIT';
  String _yearLevel = '3rd Year';

  // Interactive Membership & Dues Tracker State (no angle brackets for safe pasting)
  final _orgMemberships = [
    {
      'code': 'JPCS',
      'name': 'Junior Philippine Computer Society',
      'status': 'Paid • SY 2026–2027',
      'statusType': 'paid',
      'feeAmount': '₱150.00',
      'notes': 'Official member with workshop & summit priority.',
    },
    {
      'code': 'ACCESS',
      'name': 'ACCESS Organization',
      'status': 'Fee Due Dec 01',
      'statusType': 'due',
      'feeAmount': '₱120.00',
      'notes': 'Annual dues pending settlement at Room 204 or online.',
    },
    {
      'code': 'CICS SC',
      'name': 'CICS Student Council',
      'status': 'Enrolled',
      'statusType': 'paid',
      'feeAmount': 'Included',
      'notes': 'Automatic college-wide representation for all CICS students.',
    },
    {
      'code': 'INTESS',
      'name': 'INTESS',
      'status': 'Not Joined',
      'statusType': 'none',
      'feeAmount': '₱100.00',
      'notes': 'Join for IT infrastructure & cybersecurity lab sessions.',
    },
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'CS';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _openMembershipSheet(int index) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final org = _orgMemberships[index];
    final code = org['code']!;
    final statusType = org['statusType']!;

    CampusPost? feePost;
    for (final post in sampleCampusPosts) {
      if (post.orgCode == code && post.category == 'Membership Fee') {
        feePost = post;
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  OrgLogoAvatar(orgCode: code, size: 46),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                        Text(
                          org['name']!,
                          style: const TextStyle(fontSize: 12, color: slateSub),
                        ),
                      ],
                    ),
                  ),
                  _MembershipBadge(
                    label: org['status']!,
                    type: statusType,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Annual Membership Dues',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: slateSub,
                          ),
                        ),
                        Text(
                          org['feeAmount']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      org['notes']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (feePost != null && statusType == 'due') ...[
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(post: feePost!),
                      ),
                    );
                    setState(() {
                      if (feePost!.isDone) {
                        _orgMemberships[index]['status'] =
                        'Paid • SY 2026–2027';
                        _orgMemberships[index]['statusType'] = 'paid';
                      }
                    });
                  },
                  icon: const Icon(Icons.receipt_long, size: 18, color: gold),
                  label: const Text(
                    'View Fee Notice & Payment Form',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (statusType == 'none')
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _orgMemberships[index]['status'] = 'Fee Due Dec 15';
                      _orgMemberships[index]['statusType'] = 'due';
                      _orgMemberships[index]['notes'] =
                      'Application submitted. Settle membership dues to finalize.';
                    });
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.person_add_alt_1,
                      size: 18, color: gold),
                  label: Text(
                    'Join $code',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              else if (statusType == 'due')
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _orgMemberships[index]['status'] = 'Paid • SY 2026–2027';
                      _orgMemberships[index]['statusType'] = 'paid';
                      _orgMemberships[index]['notes'] =
                      'Dues marked as settled for SY 2026–2027.';
                      if (feePost != null) feePost.isDone = true;
                    });
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.check_circle_outline,
                      size: 18, color: Color(0xFF16A34A)),
                  label: const Text(
                    'Mark Membership Fee as Paid',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              else if (code != 'CICS SC')
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _orgMemberships[index]['status'] = 'Not Joined';
                        _orgMemberships[index]['statusType'] = 'none';
                      });
                      Navigator.pop(sheetContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: slateSub,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('Leave $code'),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _openEditProfileSheet() {
    const navy = Color(0xFF0F2547);
    const cardBorder = Color(0xFFE2E8F0);

    final nameCtrl = TextEditingController(text: _studentName);
    final idCtrl = TextEditingController(text: _studentNumber);
    String tempProgram = _program;
    String tempYear = _yearLevel;

    final programs = ['BSIT', 'BSCS', 'BSIS'];
    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cardBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Edit Student ID',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Update your academic details shown on your digital pass.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Juan Dela Cruz',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Student Number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: idCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. 2024-00142',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Program',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: tempProgram,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                              ),
                              items: programs
                                  .map((p) => DropdownMenuItem(
                                  value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => tempProgram = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Year Level',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: tempYear,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                              ),
                              items: years
                                  .map((y) => DropdownMenuItem(
                                  value: y, child: Text(y)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => tempYear = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        if (nameCtrl.text.trim().isNotEmpty) {
                          _studentName = nameCtrl.text.trim();
                        }
                        if (idCtrl.text.trim().isNotEmpty) {
                          _studentNumber = idCtrl.text.trim();
                        }
                        _program = tempProgram;
                        _yearLevel = tempYear;
                      });
                      Navigator.pop(sheetContext);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Profile Changes',
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditor([CampusPost? post]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          orgCode: widget.orgCode,
          existingPost: post,
        ),
      ),
    );
    if (changed == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final isOfficer = widget.userRole == 'officer';

    final publishedPosts =
    sampleCampusPosts.where((p) => p.isPublished).toList();
    final completedTasks = publishedPosts.where((p) => p.isDone).length;
    final pendingTasks = publishedPosts.length - completedTasks;

    final orgPosts = sampleCampusPosts
        .where((p) => p.orgCode == widget.orgCode)
        .toList();
    final activePosts = orgPosts.where((p) => p.isPublished).toList();
    final draftPosts = orgPosts.where((p) => !p.isPublished).toList();
    final visiblePosts = _showDrafts ? draftPosts : activePosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: isOfficer
          ? FloatingActionButton(
        backgroundColor: navy,
        foregroundColor: gold,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOfficer ? 'Officer dashboard' : 'My profile',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, size: 18, color: navy),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!isOfficer) ...[
              // Tap-to-Edit Navy & Gold Student Digital ID Card
              InkWell(
                onTap: _openEditProfileSheet,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2547), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(_studentName),
                                style: const TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _studentName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: $_studentNumber • student@cics.edu',
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: gold,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_program • $_yearLevel',
                              style: const TextStyle(
                                color: gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tap card to edit details',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'College of Information & Computing Sciences',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(Icons.verified, color: gold, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'CAMPUS ACTIVITY AT A GLANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: slateSub,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      count: '$completedTasks',
                      label: 'Tasks completed',
                      accentColor: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      count: '$pendingTasks',
                      label: 'Upcoming to-dos',
                      accentColor: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MEMBERSHIP & DUES TRACKER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: slateSub,
                    ),
                  ),
                  Text(
                    'Tap org to manage',
                    style: TextStyle(fontSize: 11, color: slateSub),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Interactive Membership & Dues Tracker Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: List.generate(_orgMemberships.length, (index) {
                    final org = _orgMemberships[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _openMembershipSheet(index),
                          borderRadius: BorderRadius.vertical(
                            top: index == 0
                                ? const Radius.circular(18)
                                : Radius.zero,
                            bottom: index == _orgMemberships.length - 1
                                ? const Radius.circular(18)
                                : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                OrgLogoAvatar(
                                    orgCode: org['code']!, size: 38),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        org['code']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: navy,
                                        ),
                                      ),
                                      Text(
                                        org['name']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: slateSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _MembershipBadge(
                                  label: org['status']!,
                                  type: org['statusType']!,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < _orgMemberships.length - 1)
                          const Divider(height: 1, color: cardBorder),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'NOTIFICATION PREFERENCES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: slateSub,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Event & workshop reminders',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: navy,
                        ),
                      ),
                      subtitle: const Text(
                        'Get alerted before registration closes',
                        style: TextStyle(fontSize: 12, color: slateSub),
                      ),
                      value: _eventReminders,
                      activeThumbColor: navy,
                      onChanged: (v) => setState(() => _eventReminders = v),
                    ),
                    const Divider(height: 1, color: cardBorder),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Merch & membership fee deadlines',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: navy,
                        ),
                      ),
                      subtitle: const Text(
                        'Track shirt pre-orders and org dues',
                        style: TextStyle(fontSize: 12, color: slateSub),
                      ),
                      value: _merchAlerts,
                      activeThumbColor: navy,
                      onChanged: (v) => setState(() => _merchAlerts = v),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Managing As Officer Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MANAGING AS OFFICER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orgCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Verified Officer',
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'YOUR ORGANIZATION AT A GLANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: slateSub,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      count: '${activePosts.length}',
                      label: 'Active posts',
                      accentColor: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      count: '${draftPosts.length}',
                      label: 'Saved draft',
                      accentColor: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _FilterPill(
                      label: 'Active ${activePosts.length}',
                      selected: !_showDrafts,
                      onTap: () => setState(() => _showDrafts = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterPill(
                      label: 'Drafts ${draftPosts.length}',
                      selected: _showDrafts,
                      onTap: () => setState(() => _showDrafts = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showDrafts ? 'Saved drafts' : 'Published posts',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const Text(
                    'Newest first',
                    style: TextStyle(fontSize: 12, color: slateSub),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...visiblePosts.map((post) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _openEditor(post),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: post.isPublished
                                            ? const Color(0xFF16A34A)
                                            : gold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      post.isPublished
                                          ? 'LIVE ${post.publishedDateLabel}'
                                          : 'DRAFT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: post.isPublished
                                            ? const Color(0xFF166534)
                                            : slateSub,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    post.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: navy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined,
                              size: 20, color: slateSub),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),
              Text(
                'Only ${widget.orgCode} officers can manage these posts.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: slateSub),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  final String label;
  final String type; // 'paid', 'due', 'none'

  const _MembershipBadge({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (type == 'paid') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (type == 'due') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color accentColor;

  const _StatCard({
    required this.count,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F2547),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? navy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : navy,
          ),
        ),
      ),
    );
  }
}