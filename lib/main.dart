import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/campus_post.dart';
import 'screens/checklist_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/login_screen.dart';
import 'screens/officer_dashboard_screen.dart';
import 'screens/officer_events_screen.dart';
import 'screens/organizations_screen.dart';
import 'services/portal_repository.dart';
import 'widgets/org_logo_avatar.dart';
import 'widgets/portal_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://npkqnmibhmpumcuxnouy.supabase.co',
    publishableKey: 'sb_publishable_wmPbd_ulS_jhLfdcIj7CQA_8xLTu9ws',
  );

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
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2547),
          primary: const Color(0xFF0F2547),
          secondary: const Color(0xFFD4AF37),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FC),
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
    final isOfficer = widget.userRole == 'officer';

    final pages = [
      CampusHomeScreen(
        initialOrg: _homeOrgFilter,
        onOrgChanged: (org) => setState(() => _homeOrgFilter = org),
        isOfficer: isOfficer,
        onOpenManageTab: () => setState(() => _selectedIndex = 2),
      ),
      OrganizationsScreen(onSelectOrg: _openOrgInFeed),
      isOfficer ? const OfficerEventsScreen() : const ChecklistScreen(),
      OfficerDashboardScreen(userRole: widget.userRole),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
      floatingActionButton: isOfficer && _selectedIndex == 0
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F2547),
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                orgCode: PortalRepository.instance.currentUser.orgCode,
              ),
            ),
          );
          if (created == true) setState(() {});
        },
        icon: const Icon(
          Icons.add_circle_outline,
          color: Color(0xFFD4AF37),
        ),
        label: const Text(
          'Post Update',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      )
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF09162E), Color(0xFF0F2547)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2547).withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavPillItem(
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore_rounded,
                      label: 'Discover',
                      selected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _NavPillItem(
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups_rounded,
                      label: 'Orgs',
                      selected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    _NavPillItem(
                      icon: isOfficer
                          ? Icons.inventory_2_outlined
                          : Icons.task_alt_outlined,
                      activeIcon: isOfficer
                          ? Icons.inventory_2_rounded
                          : Icons.task_alt_rounded,
                      label: isOfficer ? 'Manage' : 'Tasks',
                      selected: _selectedIndex == 2,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                    _NavPillItem(
                      icon: Icons.badge_outlined,
                      activeIcon: Icons.badge_rounded,
                      label: 'Profile',
                      selected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavPillItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavPillItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? gold : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 21,
              color: selected ? navy : const Color(0xFFCBD5E1),
            ),
            if (selected) ...[
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CampusHomeScreen extends StatefulWidget {
  final String initialOrg;
  final ValueChanged<String> onOrgChanged;
  final bool isOfficer;
  final VoidCallback? onOpenManageTab;

  const CampusHomeScreen({
    super.key,
    required this.initialOrg,
    required this.onOrgChanged,
    this.isOfficer = false,
    this.onOpenManageTab,
  });

  @override
  State<CampusHomeScreen> createState() => _CampusHomeScreenState();
}

class _CampusHomeScreenState extends State<CampusHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _orgs = ['All', 'JPCS', 'ACCESS', 'INTESS', 'CICS SC'];
  static const _categories = [
    'All',
    'Events',
    'Merch',
    'Membership Fee',
    'Educational',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Events':
        return Icons.celebration_rounded;
      case 'Merch':
        return Icons.checkroom_rounded;
      case 'Membership Fee':
        return Icons.verified_user_rounded;
      case 'Educational':
        return Icons.terminal_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  void _openFilterSheet() {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    String tempOrg = widget.initialOrg;
    String tempCat = _selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Campus Feed',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempOrg = 'All';
                            tempCat = 'All';
                          });
                        },
                        child: const Text(
                          'Reset all',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: slateSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ORGANIZATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: slateSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _orgs.map((org) {
                      final selected = tempOrg == org;
                      return ChoiceChip(
                        label: Text(org),
                        selected: selected,
                        onSelected: (_) => setModalState(() => tempOrg = org),
                        selectedColor: navy,
                        backgroundColor: const Color(0xFFF8FAFC),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        side: BorderSide(color: selected ? navy : cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: slateSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final selected = tempCat == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setModalState(() => tempCat = cat),
                        selectedColor: gold.withValues(alpha: 0.25),
                        backgroundColor: const Color(0xFFF8FAFC),
                        labelStyle: TextStyle(
                          color: navy,
                          fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: selected ? gold : cardBorder,
                          width: selected ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      widget.onOrgChanged(tempOrg);
                      setState(() => _selectedCategory = tempCat);
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
                      'Show Results',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
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

  Widget _buildAdminCommandBar({
    required String orgCode,
    required int liveCount,
    required int draftCount,
  }) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);

    return _centeredBody(
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            OrgLogoAvatar(orgCode: orgCode, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$orgCode Overview',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$liveCount live • $draftCount ${draftCount == 1 ? 'draft' : 'drafts'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: widget.onOpenManageTab,
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: gold,
              ),
              label: Text(
                draftCount > 0
                    ? '$orgCode Drafts ($draftCount)'
                    : '$orgCode Drafts',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final repo = PortalRepository.instance;
    final user = repo.currentUser;
    final firstName = user.fullName.split(' ').first;
    final selectedOrg = widget.initialOrg;
    final isOfficer = widget.isOfficer;

    final activeFilterCount =
        (selectedOrg != 'All' ? 1 : 0) + (_selectedCategory != 'All' ? 1 : 0);

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<List<CampusPost>>(
          stream: repo.watchPosts(),
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? const <CampusPost>[];
            final publishedPosts = allPosts
                .where((p) => p.isPublished && !p.isArchived)
                .toList();
            final pendingCount = publishedPosts.where((p) => !p.isDone).length;

            final orgPosts =
            allPosts.where((p) => p.orgCode == user.orgCode && !p.isArchived);
            final orgLiveCount = orgPosts.where((p) => p.isPublished).length;
            final orgDraftCount = orgPosts.where((p) => !p.isPublished).length;

            final filteredPosts = publishedPosts.where((post) {
              final matchesOrg =
                  selectedOrg == 'All' || post.orgCode == selectedOrg;
              final matchesCat = _selectedCategory == 'All' ||
                  post.category == _selectedCategory;
              final q = _searchQuery.trim().toLowerCase();
              final matchesSearch = q.isEmpty ||
                  post.title.toLowerCase().contains(q) ||
                  post.orgCode.toLowerCase().contains(q) ||
                  post.location.toLowerCase().contains(q);
              return matchesOrg && matchesCat && matchesSearch;
            }).toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                PortalHeroHeader(
                  bottomPadding: 38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: gold, width: 1.5),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/cics_logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.shield_rounded,
                                      color: gold,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'CICS HUB',
                                style: TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          if (isOfficer)
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: gold.withValues(alpha: 0.55),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OrgLogoAvatar(
                                    orgCode: user.orgCode,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    '${user.orgCode} ADMIN',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: gold.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                pendingCount == 0
                                    ? 'All caught up! 🎉'
                                    : '$pendingCount tasks waiting',
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (isOfficer) ...[
                        Text(
                          '${user.orgCode} Portal',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Publish announcements, manage drafts, and monitor campus posts.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Hey $firstName! 👋',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'See what your orgs are building this week.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _centeredBody(
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: navy.withValues(alpha: 0.10),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: const TextStyle(fontSize: 13, color: navy),
                              decoration: InputDecoration(
                                hintText: 'Search events, merch, orgs...',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: slateSub,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: slateSub,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: slateSub,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _openFilterSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: activeFilterCount > 0 ? navy : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: navy.withValues(alpha: 0.10),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 20,
                                  color: activeFilterCount > 0 ? gold : navy,
                                ),
                                if (activeFilterCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: gold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$activeFilterCount',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isOfficer) ...[
                  _buildAdminCommandBar(
                    orgCode: user.orgCode,
                    liveCount: orgLiveCount,
                    draftCount: orgDraftCount,
                  ),
                  const SizedBox(height: 18),
                ],

                if (activeFilterCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _centeredBody(
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (selectedOrg != 'All')
                            InputChip(
                              label: Text(selectedOrg),
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: navy,
                              ),
                              backgroundColor: Colors.white,
                              deleteIconColor: navy,
                              side: const BorderSide(color: cardBorder),
                              onDeleted: () => widget.onOrgChanged('All'),
                            ),
                          if (_selectedCategory != 'All')
                            InputChip(
                              label: Text(_selectedCategory),
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: navy,
                              ),
                              backgroundColor: Colors.white,
                              deleteIconColor: navy,
                              side: const BorderSide(color: cardBorder),
                              onDeleted: () =>
                                  setState(() => _selectedCategory = 'All'),
                            ),
                        ],
                      ),
                    ),
                  ),

                _centeredBody(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedOrg == 'All'
                            ? 'Happening on campus'
                            : '$selectedOrg Highlights',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                      Text(
                        '${filteredPosts.length} ${filteredPosts.length == 1 ? 'post' : 'posts'}',
                        style: const TextStyle(fontSize: 12, color: slateSub),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(color: navy),
                    ),
                  )
                else if (filteredPosts.isEmpty)
                  _centeredBody(
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: slateSub.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No matching posts found',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try clearing your search or adjusting your filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: slateSub),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  PortalResponsiveGrid(
                    spacing: 16,
                    children: filteredPosts.map((post) {
                      final gradientColors = switch (post.category) {
                        'Events' => const [
                          Color(0xFF0F2547),
                          Color(0xFF2563EB),
                        ],
                        'Merch' => const [
                          Color(0xFF1E293B),
                          Color(0xFFB45309),
                        ],
                        'Membership Fee' => const [
                          Color(0xFF064E3B),
                          Color(0xFF059669),
                        ],
                        'Educational' => const [
                          Color(0xFF311042),
                          Color(0xFF7C3AED),
                        ],
                        _ => const [Color(0xFF0F2547), Color(0xFF1E3A8A)],
                      };

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(post: post),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 6,
                                      bottom: -8,
                                      child: Icon(
                                        _categoryIcon(post.category),
                                        size: 62,
                                        color:
                                        Colors.white.withValues(alpha: 0.14),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.18),
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                post.category.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: gold,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                post.dateBadge,
                                                style: const TextStyle(
                                                  color: navy,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            OrgLogoAvatar(
                                              orgCode: post.orgCode,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              post.orgCode,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                        color: navy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      post.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: slateSub,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 14,
                                          color: navy,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            post.location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: slateSub,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
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