import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/org_member_directory_card.dart'; 
import '../widgets/portal_background.dart';
import 'login_screen.dart';

class _OrgAffiliation {
  final String code;
  final String name;
  final String role;

  const _OrgAffiliation({
    required this.code,
    required this.name,
    required this.role,
  });
}

String _formatBatStateUEmail(String studentNumber) {
  final cleaned = studentNumber.trim().replaceFirst(RegExp(r'^20'), '');
  return '$cleaned@g.batstate-u.edu.ph';
}

String _officialOrgEmail(String orgCode) {
  final slug = orgCode.toLowerCase().replaceAll(' ', '');
  return '$slug.alangilan@g.batstate-u.edu.ph';
}

String _officialOrgFullName(String orgCode) {
  switch (orgCode) {
    case 'JPCS':
      return 'Junior Philippine Computer Society';
    case 'ACCESS':
      return 'Association of Committed Computer Science Students';
    case 'INTESS':
      return 'Integrated Information Technology Student Society';
    case 'CICS SC':
      return 'CICS Alangilan - Student Council';
    default:
      return orgCode;
  }
}

class OfficerDashboardScreen extends StatelessWidget {
  final String userRole;

  const OfficerDashboardScreen({super.key, required this.userRole});

  Future<void> _confirmSignOut(BuildContext context) async {
    await PortalRepository.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

    final repo = PortalRepository.instance;
    final user = repo.currentUser;
    final isOfficer = userRole == 'officer';
    final formattedId = user.studentNumber.replaceFirst(RegExp(r'^20'), '');
    final studentEmail = _formatBatStateUEmail(user.studentNumber);
    final orgEmail = _officialOrgEmail(user.orgCode);
    final orgFullName = _officialOrgFullName(user.orgCode);

    final prog = user.program.toUpperCase();
    final affiliatedOrgs = <_OrgAffiliation>[
      const _OrgAffiliation(
        code: 'CICS SC',
        name: 'CICS Alangilan - Student Council',
        role: 'Member',
      ),
      if (prog.contains('IT'))
        const _OrgAffiliation(
          code: 'INTESS',
          name: 'Integrated Information Technology Student Society',
          role: 'Program Member',
        )
      else if (prog.contains('CS'))
        const _OrgAffiliation(
          code: 'ACCESS',
          name: 'Association of Committed Computer Science Students',
          role: 'Program Member',
        ),
      const _OrgAffiliation(
        code: 'JPCS',
        name: 'Junior Philippine Computer Society',
        role: 'Chapter Member',
      ),
    ];

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<List<CampusPost>>(
          stream: repo.watchPosts(),
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? const <CampusPost>[];

            final activePosts = allPosts
                .where((p) => p.isPublished && !p.isArchived)
                .toList();
            final completedTasks =
                activePosts.where((p) => repo.isPostDone(p.id)).length;
            final pendingTasks = activePosts.length - completedTasks;

            final orgPosts =
            allPosts.where((p) => p.orgCode == user.orgCode).toList();
            final orgActivePosts = orgPosts
                .where((p) => p.isPublished && !p.isArchived)
                .length;
            final orgArchivedPosts =
                orgPosts.where((p) => p.isArchived).length;

            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                PortalHeroHeader(
                  bottomPadding: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: gold.withValues(alpha: 0.45)),
                            ),
                            child: Text(
                              isOfficer
                                  ? 'OFFICIAL ORGANIZATION ACCOUNT'
                                  : 'CICS STUDENT ACCOUNT',
                              style: const TextStyle(
                                color: gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _confirmSignOut(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout_rounded,
                                      size: 15, color: gold),
                                  SizedBox(width: 6),
                                  Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.14),
                              border: Border.all(color: gold, width: 2.2),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Center(
                              child: isOfficer
                                  ? OrgLogoAvatar(
                                  orgCode: user.orgCode, size: 46)
                                  : const Icon(
                                Icons.person_rounded,
                                size: 34,
                                color: gold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOfficer ? user.orgCode : user.fullName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isOfficer
                                      ? orgFullName
                                      : '${user.program} • ${user.yearLevel} • SR Code $formattedId',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                PortalResponsiveGrid(
                  spacing: 16,
                  children: [
                    // Card 1: Credentials
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  isOfficer
                                      ? 'ORGANIZATION PROFILE'
                                      : 'CAMPUS CREDENTIALS',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: slateSub,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isOfficer ? 'Accredited' : 'Enrolled',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (isOfficer) ...[
                            _InfoRow(
                              icon: Icons.groups_outlined,
                              label: 'Organization',
                              value: user.orgCode,
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.alternate_email_rounded,
                              label: 'Official Email',
                              value: orgEmail,
                            ),
                            const SizedBox(height: 14),
                            const _InfoRow(
                              icon: Icons.account_balance_outlined,
                              label: 'Department',
                              value: 'CICS • Alangilan',
                            ),
                            const SizedBox(height: 14),
                            const _InfoRow(
                              icon: Icons.admin_panel_settings_outlined,
                              label: 'Access Level',
                              value: 'Org Publisher',
                            ),
                          ] else ...[
                            _InfoRow(
                              icon: Icons.badge_outlined,
                              label: 'SR Code',
                              value: formattedId,
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.school_outlined,
                              label: 'Program & Year',
                              value: '${user.program} • ${user.yearLevel}',
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.alternate_email_rounded,
                              label: 'G-Suite Email',
                              value: studentEmail,
                            ),
                            const SizedBox(height: 14),
                            const _InfoRow(
                              icon: Icons.verified_user_outlined,
                              label: 'Portal Role',
                              value: 'CICS Student',
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Card 2: Pure Activity Metrics
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOfficer
                                    ? 'PUBLICATION METRICS'
                                    : 'PORTAL ACTIVITY',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: slateSub,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatBox(
                                      label: isOfficer
                                          ? 'Active Posts'
                                          : 'Completed',
                                      value: isOfficer
                                          ? '$orgActivePosts'
                                          : '$completedTasks',
                                      icon: isOfficer
                                          ? Icons.campaign_rounded
                                          : Icons.check_circle_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatBox(
                                      label:
                                      isOfficer ? 'Archived' : 'Pending',
                                      value: isOfficer
                                          ? '$orgArchivedPosts'
                                          : '$pendingTasks',
                                      icon: isOfficer
                                          ? Icons.archive_rounded
                                          : Icons.pending_actions_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isOfficer
                                      ? 'Total Announcements'
                                      : 'Total Tasks',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: slateSub,
                                  ),
                                ),
                                Text(
                                  isOfficer
                                      ? '${orgPosts.length} records'
                                      : '${activePosts.length} items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
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
                // Officer-Only Student Member Directory
                if (isOfficer) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: OrgMemberDirectoryCard(orgCode: user.orgCode),
                      ),
                    ),
                  ),
                ],
                // Student-Only Affiliated Organizations List
                if (!isOfficer) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'MY ORGANIZATIONS',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: slateSub,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: navy.withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${affiliatedOrgs.length} affiliated',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...affiliatedOrgs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final org = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == affiliatedOrgs.length - 1
                                        ? 0
                                        : 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        OrgLogoAvatar(
                                            orgCode: org.code, size: 38),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    org.code,
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w900,
                                                      color: navy,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 7,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFCBD5E1)),
                                                      ),
                                                      child: Text(
                                                        org.role,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                          FontWeight.w800,
                                                          color: slateSub,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                org.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: slateSub,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 18,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: gold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: navy,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F2547),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}