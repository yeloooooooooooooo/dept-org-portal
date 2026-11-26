import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import 'create_post_screen.dart';
import 'event_details_screen.dart';

class OfficerEventsScreen extends StatefulWidget {
  const OfficerEventsScreen({super.key});

  @override
  State<OfficerEventsScreen> createState() => _OfficerEventsScreenState();
}

class _OfficerEventsScreenState extends State<OfficerEventsScreen> {
  bool _showArchived = false;

  Future<void> _toggleArchive(CampusPost post) async {
    await PortalRepository.instance.toggleArchivePost(post);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          post.isArchived
              ? 'Moved "${post.title}" to Archive'
              : 'Restored "${post.title}" to Active Feed',
        ),
        backgroundColor: const Color(0xFF0F2547),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

    final user = PortalRepository.instance.currentUser;
    final orgPosts = sampleCampusPosts
        .where((p) => p.orgCode == user.orgCode)
        .toList();

    final activePosts = orgPosts.where((p) => !p.isArchived).toList();
    final archivedPosts = orgPosts.where((p) => p.isArchived).toList();
    final displayedPosts = _showArchived ? archivedPosts : activePosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Navy Officer Header
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 18,
              20,
              26,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B1C38), Color(0xFF1A3B70)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${user.orgCode} OFFICER CONSOLE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: gold,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final created = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreatePostScreen(orgCode: user.orgCode),
                          ),
                        );
                        if (created == true) setState(() {});
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: navy,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'New Post',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage Events & Posts',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Active vs Archived Segment Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentTab(
                          label: 'Active (${activePosts.length})',
                          selected: !_showArchived,
                          onTap: () => setState(() => _showArchived = false),
                        ),
                      ),
                      Expanded(
                        child: _SegmentTab(
                          label: 'Archived (${archivedPosts.length})',
                          selected: _showArchived,
                          onTap: () => setState(() => _showArchived = true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          if (displayedPosts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [
                  Icon(
                    _showArchived
                        ? Icons.archive_outlined
                        : Icons.event_available_rounded,
                    size: 48,
                    color: slateSub.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _showArchived
                        ? 'No archived events yet'
                        : 'No active events for ${user.orgCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showArchived
                        ? 'Finished events you archive will appear here.'
                        : 'Tap "New Post" above to publish an update.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: slateSub),
                  ),
                ],
              ),
            )
          else
            ...displayedPosts.map((post) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: navy.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OrgLogoAvatar(orgCode: post.orgCode, size: 42),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${post.category} • ${post.dateBadge}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: slateSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: post.isArchived
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.isArchived ? 'Archived' : 'Live',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: post.isArchived
                                    ? slateSub
                                    : const Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsScreen(post: post),
                                  ),
                                );
                                setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: navy,
                                side: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _toggleArchive(post),
                              style: FilledButton.styleFrom(
                                backgroundColor: post.isArchived
                                    ? navy
                                    : const Color(0xFFF59E0B),
                                foregroundColor: post.isArchived
                                    ? Colors.white
                                    : navy,
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                post.isArchived
                                    ? Icons.unarchive_rounded
                                    : Icons.archive_rounded,
                                size: 16,
                              ),
                              label: Text(
                                post.isArchived ? 'Restore' : 'Archive',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? const Color(0xFF0F2547) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}