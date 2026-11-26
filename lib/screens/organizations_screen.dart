import 'package:flutter/material.dart';
import '../widgets/org_logo_avatar.dart';
import 'org_details_screen.dart';

class OrganizationsScreen extends StatelessWidget {
  final ValueChanged<String> onSelectOrg;

  const OrganizationsScreen({super.key, required this.onSelectOrg});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final orgList = [
      {
        'code': 'JPCS',
        'name': 'JPCS',
        'fullName': 'Junior Philippine Computer Society',
        'tagline':
        'Code, collaborate, and grow with a community of student developers.',
        'about':
        'JPCS is the premier student organization for aspiring software engineers, web/mobile developers, and competitive programmers in CICS. We host hackathons, coding bootcamps, and industry tech talks.',
        'president': 'Andrea Reyes',
        'email': 'jpcs@cics.edu',
        'officeLocation': 'CICS Building, Room 202',
        'tags': ['Software Dev', 'Hackathons', 'Tech Talks'],
        'isMember': true,
      },
      {
        'code': 'ACCESS',
        'name': 'ACCESS',
        'fullName': 'Association of Committed Computer Science Students',
        'tagline':
        'Connect through student-led activities, shared learning, and campus initiatives.',
        'about':
        'ACCESS fosters peer mentorship, research colloquiums, and community outreach programs designed to help computing students thrive academically and socially.',
        'president': 'Claire Mendoza',
        'email': 'access@cics.edu',
        'officeLocation': 'CICS Building, Room 204',
        'tags': ['Peer Mentoring', 'Community', 'Research'],
        'isMember': true,
      },
      {
        'code': 'INTESS',
        'name': 'INTESS',
        'fullName': 'Information Technology Society of Students',
        'tagline':
        'Turn curiosity into skills through technology projects and workshops.',
        'about':
        'INTESS bridges classroom theory and hands-on IT infrastructure, cybersecurity, UI/UX design, and systems administration through practical lab workshops.',
        'president': 'Liam Cruz',
        'email': 'intess@cics.edu',
        'officeLocation': 'CICS Computer Lab Wing, 3F',
        'tags': ['IT Infrastructure', 'Cybersecurity', 'Workshops'],
        'isMember': false,
      },
      {
        'code': 'CICS SC',
        'name': 'CICS Student Council',
        'fullName': 'CICS Student Council',
        'tagline':
        'Your voice in CICS. Discover student services, campus updates, and advocacy.',
        'about':
        'The official student governing body of the College of Information and Computing Sciences, representing student welfare, college-wide assemblies, and official department merchandise.',
        'president': 'Marco Santos',
        'email': 'sc@cics.edu',
        'officeLocation': 'CICS Student Lounge, Ground Floor',
        'tags': ['Student Governance', 'Campus Events', 'Official Merch'],
        'isMember': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const Row(
              children: [
                Icon(Icons.business_outlined, size: 16, color: navy),
                SizedBox(width: 6),
                Text(
                  'Organizations',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Find your people.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: navy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap any organization to explore its profile and announcements.',
              style: TextStyle(fontSize: 14, color: slateSub),
            ),
            const SizedBox(height: 20),
            const Text(
              'EXPLORE YOUR ORGANIZATIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: slateSub,
              ),
            ),
            const SizedBox(height: 12),
            ...orgList.map((org) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrgDetailsScreen(orgData: org),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrgLogoAvatar(
                                orgCode: org['code'].toString(), size: 48),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          org['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: navy,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          color: slateSub, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    org['tagline'].toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: slateSub,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrgDetailsScreen(orgData: org),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: navy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Explore Org & Announcements',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}