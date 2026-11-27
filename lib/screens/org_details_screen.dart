import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'event_details_screen.dart';
import 'organizations_screen.dart';

class OrgDetailsScreen extends StatefulWidget {
  final String orgCode;
  final VoidCallback? onViewFeed;

  const OrgDetailsScreen({
    super.key,
    required this.orgCode,
    this.onViewFeed,
  });

  @override
  State<OrgDetailsScreen> createState() => _OrgDetailsScreenState();
}

class _OrgDetailsScreenState extends State<OrgDetailsScreen> {
  void _openEditOrgSheet(CicsOrgProfile org) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final mottoCtrl = TextEditingController(text: org.motto);
    final aboutCtrl = TextEditingController(text: org.about);
    final adviserCtrl = TextEditingController(text: org.adviser);
    final officeCtrl = TextEditingController(text: org.officeLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
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
                    Row(
                      children: [
                        OrgLogoAvatar(orgCode: org.code, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit ${org.code} Details',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),
                              Text(
                                org.officialEmail,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: slateSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _EditField(
                      label: 'ORGANIZATION MOTTO / TAGLINE',
                      controller: mottoCtrl,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 14),
                    _EditField(
                      label: 'ABOUT ORGANIZATION',
                      controller: aboutCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    _EditField(
                      label: 'FACULTY ADVISER',
                      controller: adviserCtrl,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 14),
                    _EditField(
                      label: 'CAMPUS OFFICE LOCATION',
                      controller: officeCtrl,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: navy,
                              side: const BorderSide(color: cardBorder),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                if (mottoCtrl.text.trim().isNotEmpty) {
                                  org.motto = mottoCtrl.text.trim();
                                }
                                if (aboutCtrl.text.trim().isNotEmpty) {
                                  org.about = aboutCtrl.text.trim();
                                }
                                if (adviserCtrl.text.trim().isNotEmpty) {
                                  org.adviser = adviserCtrl.text.trim();
                                }
                                if (officeCtrl.text.trim().isNotEmpty) {
                                  org.officeLocation = officeCtrl.text.trim();
                                }
                              });
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${org.code} organization details updated.'),
                                  backgroundColor: navy,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 18, color: gold),
                            label: const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.w800),
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
        );
      },
    );
  }

  Widget _centeredBody(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

    final org = cicsOrgProfiles[widget.orgCode] ??
        CicsOrgProfile(
          code: widget.orgCode,
          fullName: widget.orgCode,
          focus: 'CICS Student Organization',
          motto: 'Excellence in Computing and Service',
          about: 'Accredited student organization at BatStateU Alangilan.',
          adviser: 'CICS Faculty Adviser',
          officeLocation: 'CICS Building, Alangilan Campus',
        );

    final repo = PortalRepository.instance;
    final currentUser = repo.currentUser;
    final canEditThisOrg =
        currentUser.role == 'officer' && currentUser.orgCode == org.code;

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<List<CampusPost>>(
          stream: repo.watchPosts(),
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? const <CampusPost>[];
            final orgPosts = allPosts
                .where((p) =>
            p.orgCode == org.code && p.isPublished && !p.isArchived)
                .toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 60),
              children: [
                PortalHeroHeader(
                  bottomPadding: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_rounded,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'All Orgs',
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
                          if (canEditThisOrg)
                            FilledButton.icon(
                              onPressed: () => _openEditOrgSheet(org),
                              style: FilledButton.styleFrom(
                                backgroundColor: gold,
                                foregroundColor: navy,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text(
                                'Edit Org Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.14),
                              border: Border.all(color: gold, width: 2),
                            ),
                            child: OrgLogoAvatar(orgCode: org.code, size: 60),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org.code,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  org.fullName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${org.motto}"',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: gold,
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
                    // Card 1: About & Focus
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
                          const Text(
                            'ABOUT ORGANIZATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: slateSub,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            org.about,
                            style: const TextStyle(
                              fontSize: 13,
                              color: navy,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card 2: Official Contact & Directory Info
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
                              const Text(
                                'OFFICIAL DIRECTORY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: slateSub,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _OrgMetaRow(
                                icon: Icons.alternate_email_rounded,
                                label: 'G-Suite Email',
                                value: org.officialEmail,
                              ),
                              const SizedBox(height: 11),
                              _OrgMetaRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Adviser',
                                value: org.adviser,
                              ),
                              const SizedBox(height: 11),
                              _OrgMetaRow(
                                icon: Icons.location_on_outlined,
                                label: 'Office',
                                value: org.officeLocation,
                              ),
                            ],
                          ),
                          if (widget.onViewFeed != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onViewFeed!();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: navy,
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.filter_list_rounded,
                                    size: 17),
                                label: Text(
                                  'Filter Discover Feed by ${org.code}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _centeredBody(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Published by ${org.code}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                      Text(
                        '${orgPosts.length} ${orgPosts.length == 1 ? 'post' : 'posts'}',
                        style: const TextStyle(fontSize: 12, color: slateSub),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  _centeredBody(
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: CircularProgressIndicator(color: navy),
                      ),
                    ),
                  )
                else if (orgPosts.isEmpty)
                  _centeredBody(
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Text(
                        'No active announcements or events posted yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: slateSub),
                      ),
                    ),
                  )
                else
                  PortalResponsiveGrid(
                    spacing: 14,
                    children: orgPosts.map((post) {
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(post: post),
                            ),
                          );
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.07),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: navy,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  post.dateBadge,
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      post.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: navy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${post.category} • ${post.location}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: slateSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: slateSub),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrgMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OrgMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
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

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _EditField({
    required this.label,
    required this.controller,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: navy,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}