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

class OfficerDashboardScreen extends StatefulWidget {
  final String userRole;

  const OfficerDashboardScreen({super.key, required this.userRole});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  List<JsonRow> _pendingRequests = [];
  bool _loadingRequests = false;
  final Set<String> _processingRequestIds = {};

  Map<String, String> _studentMembershipStatuses = {};
  bool _loadingStudentOrgs = false;

  int _directoryRefreshSeed = 0;

  @override
  void initState() {
    super.initState();
    _loadMembershipData();
  }

  Future<void> _loadMembershipData() async {
    final repo = PortalRepository.instance;
    if (!repo.isLoggedIn) return;

    if (widget.userRole == 'officer') {
      setState(() => _loadingRequests = true);
      try {
        final rows =
        await repo.fetchPendingOrgRequests(repo.currentUser.orgCode);
        if (!mounted) return;
        setState(() => _pendingRequests = rows);
      } catch (_) {
        // Keep dashboard usable if offline
      } finally {
        if (mounted) setState(() => _loadingRequests = false);
      }
    } else {
      setState(() => _loadingStudentOrgs = true);
      try {
        final statuses = await repo.fetchMyMembershipStatuses();
        if (!mounted) return;
        setState(() => _studentMembershipStatuses = statuses);
      } catch (_) {
        // Keep dashboard usable if offline
      } finally {
        if (mounted) setState(() => _loadingStudentOrgs = false);
      }
    }
  }

  Future<void> _handleReviewRequest({
    required String membershipId,
    required String studentName,
    required bool approve,
    VoidCallback? onModalRefresh,
  }) async {
    setState(() => _processingRequestIds.add(membershipId));
    onModalRefresh?.call();

    try {
      await PortalRepository.instance.reviewMembershipRequest(
        membershipId: membershipId,
        approve: approve,
      );
      await _loadMembershipData();
      if (!mounted) return;
      setState(() => _directoryRefreshSeed++);
      onModalRefresh?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Approved $studentName\'s membership request.'
                : 'Rejected $studentName\'s membership request.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update request: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingRequestIds.remove(membershipId));
        onModalRefresh?.call();
      }
    }
  }

  void _openPendingRequestsModal(String orgCode) {
    const navy = Color(0xFF0F2547);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 540,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.78,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$orgCode Join Requests',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                ),
                                Text(
                                  '${_pendingRequests.length} awaiting officer approval',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: slateSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _loadingRequests
                                ? null
                                : () async {
                              await _loadMembershipData();
                              if (dialogContext.mounted) {
                                setModalState(() {});
                              }
                            },
                            tooltip: 'Refresh',
                            icon: const Icon(Icons.refresh_rounded,
                                size: 20, color: navy),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded,
                                color: slateSub),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: cardBorder),
                      if (_loadingRequests && _pendingRequests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: CircularProgressIndicator(color: navy),
                          ),
                        )
                      else if (_pendingRequests.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.how_to_reg_rounded,
                                  size: 30,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'All caught up!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No pending join requests for $orgCode right now.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: slateSub,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _pendingRequests.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final req = _pendingRequests[index];
                              final membershipId = req['id'].toString();
                              final profile = req['profiles'] is Map
                                  ? Map<String, dynamic>.from(
                                  req['profiles'] as Map)
                                  : <String, dynamic>{};

                              final fullName =
                                  profile['full_name']?.toString() ??
                                      'CICS Student';
                              final srCode = profile['student_number']
                                  ?.toString()
                                  .replaceFirst(RegExp(r'^20'), '') ??
                                  '';
                              final program =
                                  profile['program']?.toString() ?? '';
                              final yearLevel =
                                  profile['year_level']?.toString() ?? '';
                              final isBusy =
                              _processingRequestIds.contains(membershipId);

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                      navy.withValues(alpha: 0.08),
                                      child: Text(
                                        fullName.isNotEmpty
                                            ? fullName[0].toUpperCase()
                                            : 'S',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: navy,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: navy,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'SR $srCode • $program • $yearLevel',
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
                                    const SizedBox(width: 8),
                                    if (isBusy)
                                      const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.2),
                                      )
                                    else ...[
                                      IconButton(
                                        onPressed: () => _handleReviewRequest(
                                          membershipId: membershipId,
                                          studentName: fullName,
                                          approve: false,
                                          onModalRefresh: () {
                                            if (dialogContext.mounted) {
                                              setModalState(() {});
                                            }
                                          },
                                        ),
                                        tooltip: 'Reject',
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFFFEE2E2),
                                          foregroundColor:
                                          const Color(0xFFB91C1C),
                                        ),
                                        icon: const Icon(Icons.close_rounded,
                                            size: 18),
                                      ),
                                      const SizedBox(width: 6),
                                      FilledButton.icon(
                                        onPressed: () => _handleReviewRequest(
                                          membershipId: membershipId,
                                          studentName: fullName,
                                          approve: true,
                                          onModalRefresh: () {
                                            if (dialogContext.mounted) {
                                              setModalState(() {});
                                            }
                                          },
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF16A34A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        icon: const Icon(Icons.check_rounded,
                                            size: 16),
                                        label: const Text(
                                          'Approve',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

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
    final isOfficer = widget.userRole == 'officer';
    final formattedId = user.studentNumber.replaceFirst(RegExp(r'^20'), '');
    final studentEmail = _formatBatStateUEmail(user.studentNumber);
    final orgEmail = _officialOrgEmail(user.orgCode);
    final orgFullName = _officialOrgFullName(user.orgCode);

    final approvedOrgCodes = repo.allowedOrgCodes
        .where((code) => _studentMembershipStatuses[code] == 'approved')
        .toList();

    final affiliatedOrgs = approvedOrgCodes
        .map(
          (code) => _OrgAffiliation(
        code: code,
        name: _officialOrgFullName(code),
        role: 'Approved Member',
      ),
    )
        .toList();

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
              padding: const EdgeInsets.only(bottom: 120),
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

                    // Card 2: Activity Metrics + Officer Membership Queue Trigger
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
                              if (isOfficer) ...[
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () =>
                                      _openPendingRequestsModal(user.orgCode),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 13),
                                    decoration: BoxDecoration(
                                      color: _pendingRequests.isNotEmpty
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _pendingRequests.isNotEmpty
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _pendingRequests.isNotEmpty
                                                ? const Color(0xFFB45309)
                                                : navy,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.how_to_reg_rounded,
                                            size: 16,
                                            color: _pendingRequests.isNotEmpty
                                                ? Colors.white
                                                : gold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _pendingRequests.isNotEmpty
                                                    ? '${_pendingRequests.length} Pending Join ${_pendingRequests.length == 1 ? 'Request' : 'Requests'}'
                                                    : 'Membership Queue',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: _pendingRequests
                                                      .isNotEmpty
                                                      ? const Color(0xFF92400E)
                                                      : navy,
                                                ),
                                              ),
                                              Text(
                                                _pendingRequests.isNotEmpty
                                                    ? 'Tap to approve or reject applicants'
                                                    : 'No pending join requests',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: slateSub,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: slateSub,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

                // Officer-Only Scalable Student Member Directory
                if (isOfficer) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: OrgMemberDirectoryCard(
                          key: ValueKey(
                              '${user.orgCode}_$_directoryRefreshSeed'),
                          orgCode: user.orgCode,
                        ),
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
                              if (_loadingStudentOrgs && affiliatedOrgs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              else if (affiliatedOrgs.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Text(
                                    'You have no approved organization memberships yet. Visit the Organizations tab to request to join.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: slateSub,
                                    ),
                                  ),
                                )
                              else
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
                                                        fontWeight:
                                                        FontWeight.w900,
                                                        color: navy,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 7,
                                                            vertical: 2),
                                                        decoration:
                                                        BoxDecoration(
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
                                                          style:
                                                          const TextStyle(
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
                                                  overflow:
                                                  TextOverflow.ellipsis,
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
    const navy = Color(0xFF0F2547);
    const slateSub = Color(0xFF64748B);

    return Row(
      children: [
        Icon(icon, size: 18, color: slateSub),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: slateSub,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}