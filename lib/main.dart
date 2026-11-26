import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/campus_post.dart';
import 'screens/checklist_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/login_screen.dart';
import 'screens/officer_dashboard_screen.dart';
import 'screens/organizations_screen.dart';
import 'widgets/org_logo_avatar.dart';

void main() {
  runApp(const DeptOrgPortalApp());
}

class DeptOrgPortalApp extends StatelessWidget {
  const DeptOrgPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CICS Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2547),
          primary: const Color(0xFF0F2547),
          secondary: const Color(0xFFD4AF37),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoginScreen(),
    );
  }
}

class MainNavShell extends StatefulWidget {
  final String userRole;
  const MainNavShell({super.key, required this.userRole});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _selectedIndex = 0;
  String _homeOrgFilter = 'All';

  void _openOrgInFeed(String orgCode) {
    setState(() {
      _homeOrgFilter = orgCode;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CampusHomeScreen(
        initialOrg: _homeOrgFilter,
        onOrgChanged: (org) => setState(() => _homeOrgFilter = org),
      ),
      OrganizationsScreen(onSelectOrg: _openOrgInFeed),
      const ChecklistScreen(),
      OfficerDashboardScreen(userRole: widget.userRole),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: widget.userRole == 'officer' && _selectedIndex == 0
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F2547),
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(orgCode: 'JPCS'),
            ),
          );
          if (created == true) setState(() {});
        },
        icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
        label: const Text('New Post'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Organizations',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_turned_in_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in),
            label: 'Checklist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CampusHomeScreen extends StatefulWidget {
  final String initialOrg;
  final ValueChanged<String> onOrgChanged;

  const CampusHomeScreen({
    super.key,
    required this.initialOrg,
    required this.onOrgChanged,
  });

  @override
  State<CampusHomeScreen> createState() => _CampusHomeScreenState();
}

class _CampusHomeScreenState extends State<CampusHomeScreen> {
  String _selectedCategory = 'All';

  final List<String> _orgs = ['All', 'JPCS', 'ACCESS', 'INTESS', 'CICS SC'];
  final List<String> _categories = [
    'All',
    'Events',
    'Merch',
    'Membership Fee',
    'Educational',
  ];

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final selectedOrg = widget.initialOrg;

    final filteredPosts = sampleCampusPosts.where((post) {
      if (!post.isPublished) return false;
      final matchesOrg = selectedOrg == 'All' || post.orgCode == selectedOrg;
      final matchesCat =
          _selectedCategory == 'All' || post.category == _selectedCategory;
      return matchesOrg && matchesCat;
    }).toList();

    final featuredPost = sampleCampusPosts.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: navy),
                SizedBox(width: 6),
                Text(
                  'CICS Portal',
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
              'Find your next\ncampus moment.',
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
              'Stay in the loop. Make it count.',
              style: TextStyle(fontSize: 14, color: slateSub),
            ),
            const SizedBox(height: 18),

            // Row 1: Organization Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _orgs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final org = _orgs[index];
                  final selected = selectedOrg == org;
                  return ChoiceChip(
                    label: Text(org),
                    selected: selected,
                    onSelected: (_) => widget.onOrgChanged(org),
                    selectedColor: navy,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(color: selected ? navy : cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Row 2: Category Filter Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: navy.withValues(alpha: 0.12),
                    backgroundColor: Colors.white,
                    checkmarkColor: navy,
                    labelStyle: TextStyle(
                      color: navy,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: selected ? navy : cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your campus feed',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                Text(
                  'Latest first',
                  style: TextStyle(fontSize: 12, color: slateSub),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (selectedOrg == 'All' && _selectedCategory == 'All') ...[
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(post: featuredPost),
                    ),
                  );
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2547), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CICS TECH SUMMIT / 2026',
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '04 DEC',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'BUILD. BEYOND.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        'Ideas today. Impact tomorrow.',
                        style:
                        TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'JPCS • Dec 04 • 9:00 AM • CICS Auditorium',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'View event',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            ...filteredPosts.map((post) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(post: post),
                      ),
                    );
                    setState(() {});
                  },
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
                        OrgLogoAvatar(orgCode: post.orgCode, size: 46),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    post.orgCode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: slateSub,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      post.category,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.fullDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: slateSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: slateSub),
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