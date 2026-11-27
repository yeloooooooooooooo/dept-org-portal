import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'org_details_screen.dart';

class CicsOrgProfile {
  final String code;
  final String fullName;
  final String focus;
  String motto;
  String about;
  String adviser;
  String officeLocation;

  CicsOrgProfile({
    required this.code,
    required this.fullName,
    required this.focus,
    required this.motto,
    required this.about,
    required this.adviser,
    required this.officeLocation,
  });

  String get officialEmail {
    final slug = code.toLowerCase().replaceAll(' ', '');
    return '$slug.alangilan@g.batstate-u.edu.ph';
  }
}

final cicsOrgProfiles = <String, CicsOrgProfile>{
  'JPCS': CicsOrgProfile(
    code: 'JPCS',
    fullName: 'Junior Philippine Computer Society',
    focus: 'Computing & Tech Innovation',
    motto: 'Connecting Future IT Leaders Across the Nation',
    about:
    'The official student chapter of the Junior Philippine Computer Society at BatStateU Alangilan, empowering CICS students through hackathons, coding bootcamps, and industry tech talks.',
    adviser: 'Engr. Mark Anthony Reyes, MIT',
    officeLocation: 'CICS Building, 2nd Floor • Org Room A',
  ),
  'ACCESS': CicsOrgProfile(
    code: 'ACCESS',
    fullName: 'Association of Committed Computer Science Students',
    focus: 'Computer Science & Algorithms',
    motto: 'Innovating Through Logic, Research, and Code',
    about:
    'The premier academic organization for Bachelor of Science in Computer Science students, spearheading algorithmic workshops, research colloquiums, and software engineering sprints.',
    adviser: 'Prof. Clarissa Mae Mendoza, MSCS',
    officeLocation: 'CICS Building, 2nd Floor • Org Room B',
  ),
  'INTESS': CicsOrgProfile(
    code: 'INTESS',
    fullName: 'Integrated Information Technology Student Society',
    focus: 'Information Technology & Systems',
    motto: 'Bridging Systems, Enterprise, and Digital Solutions',
    about:
    'The official program organization for BS Information Technology students at BatStateU Alangilan, focused on web/mobile development, networking labs, and IT industry readiness.',
    adviser: 'Prof. Jerome Patrick Villanueva, MIT',
    officeLocation: 'CICS Building, 3rd Floor • IT Hub',
  ),
  'CICS SC': CicsOrgProfile(
    code: 'CICS SC',
    fullName: 'CICS Alangilan - Student Council',
    focus: 'Student Governance & Welfare',
    motto: 'Service, Integrity, and Excellence for Every CICS Student',
    about:
    'The highest student governing body of the College of Informatics and Computing Sciences at BatStateU Alangilan, championing student welfare, college-wide assemblies, and institutional representation.',
    adviser: 'Dr. Elena Santos-Bautista',
    officeLocation: 'CICS Building, Ground Floor • Student Council Office',
  ),
};

class OrganizationsScreen extends StatefulWidget {
  final ValueChanged<String> onSelectOrg;

  const OrganizationsScreen({super.key, required this.onSelectOrg});

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  static const _orgOrder = ['JPCS', 'ACCESS', 'INTESS', 'CICS SC'];

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

    final repo = PortalRepository.instance;
    final currentUser = repo.currentUser;
    final isOfficerAccount = currentUser.role == 'officer' ||
        currentUser.email
            .toLowerCase()
            .contains('alangilan@g.batstate-u.edu.ph') ||
        currentUser.fullName.toLowerCase().contains('officer');

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<List<CampusPost>>(
          stream: repo.watchPosts(),
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? const <CampusPost>[];
            final activePosts = allPosts
                .where((p) => p.isPublished && !p.isArchived)
                .toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                PortalHeroHeader(
                  bottomPadding: 30,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: gold.withValues(alpha: 0.45)),
                          ),
                          child: const Text(
                            'BATSTATEU ALANGILAN • CICS',
                            style: TextStyle(
                              color: gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Student Organizations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Explore accredited CICS student organizations and council hubs.',
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PortalResponsiveGrid(
                  spacing: 16,
                  children: _orgOrder.map((code) {
                    final org = cicsOrgProfiles[code]!;
                    final isOwnOrg =
                        isOfficerAccount && currentUser.orgCode == org.code;
                    final postCount = activePosts
                        .where((p) => p.orgCode == org.code)
                        .length;

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrgDetailsScreen(
                              orgCode: org.code,
                              onViewFeed: () => widget.onSelectOrg(org.code),
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isOwnOrg
                                ? gold.withValues(alpha: 0.75)
                                : Colors.transparent,
                            width: 1.6,
                          ),
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
                                Row(
                                  children: [
                                    OrgLogoAvatar(orgCode: org.code, size: 50),
                                    const SizedBox(width: 12),
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
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: navy,
                                                ),
                                              ),
                                              if (isOwnOrg) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2.5),
                                                  decoration: BoxDecoration(
                                                    color: navy,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                  child: const Text(
                                                    'Your Org',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                      color: gold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            org.focus,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: slateSub,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  org.fullName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${org.motto}"',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: slateSub,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                          !snapshot.hasData
                                          ? 'Loading posts...'
                                          : '$postCount active ${postCount == 1 ? 'post' : 'posts'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        isOwnOrg ? 'Manage & View' : 'View Org',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: navy,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 16, color: navy),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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