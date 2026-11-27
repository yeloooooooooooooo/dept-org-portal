import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import 'create_post_screen.dart';
import 'event_details_screen.dart';

enum _OfficerPostFilter { live, drafts, archived }

class OfficerEventsScreen extends StatefulWidget {
  const OfficerEventsScreen({super.key});

  @override
  State<OfficerEventsScreen> createState() => _OfficerEventsScreenState();
}

class _OfficerEventsScreenState extends State<OfficerEventsScreen> {
  _OfficerPostFilter _filter = _OfficerPostFilter.live;

  Future<void> _toggleArchive(CampusPost post) async {
    await PortalRepository.instance.toggleArchivePost(post);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !post.isArchived
              ? 'Moved "${post.title}" to Archive'
              : 'Restored "${post.title}" to Live Feed',
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

    final repo = PortalRepository.instance;
    final user = repo.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: StreamBuilder<List<CampusPost>>(
        stream: repo.watchPosts(),
        builder: (context, snapshot) {
          final allPosts = snapshot.data ?? const <CampusPost>[];
          final orgPosts =
          allPosts.where((p) => p.orgCode == user.orgCode).toList();

          final livePosts = orgPosts
              .where((p) => p.isPublished && !p.isArchived)
              .toList();
          final draftPosts = orgPosts
              .where((p) => !p.isPublished && !p.isArchived)
              .toList();
          final archivedPosts =
          orgPosts.where((p) => p.isArchived).toList();

          final displayedPosts = switch (_filter) {
            _OfficerPostFilter.live => livePosts,
            _OfficerPostFilter.drafts => draftPosts,
            _OfficerPostFilter.archived => archivedPosts,
          };

          return ListView(
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
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
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
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreatePostScreen(orgCode: user.orgCode),
                              ),
                            );
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

                    // Live vs Drafts vs Archived Segment Switcher
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
                              label: 'Live (${livePosts.length})',
                              selected: _filter == _OfficerPostFilter.live,
                              onTap: () => setState(
                                      () => _filter = _OfficerPostFilter.live),
                            ),
                          ),
                          Expanded(
                            child: _SegmentTab(
                              label: 'Drafts (${draftPosts.length})',
                              selected: _filter == _OfficerPostFilter.drafts,
                              onTap: () => setState(
                                      () => _filter = _OfficerPostFilter.drafts),
                            ),
                          ),
                          Expanded(
                            child: _SegmentTab(
                              label: 'Archived (${archivedPosts.length})',
                              selected: _filter == _OfficerPostFilter.archived,
                              onTap: () => setState(
                                      () => _filter = _OfficerPostFilter.archived),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(color: navy),
                  ),
                )
              else if (displayedPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    children: [
                      Icon(
                        switch (_filter) {
                          _OfficerPostFilter.live =>
                          Icons.event_available_rounded,
                          _OfficerPostFilter.drafts => Icons.edit_note_rounded,
                          _OfficerPostFilter.archived => Icons.archive_outlined,
                        },
                        size: 48,
                        color: slateSub.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        switch (_filter) {
                          _OfficerPostFilter.live =>
                          'No live posts for ${user.orgCode}',
                          _OfficerPostFilter.drafts => 'No saved drafts yet',
                          _OfficerPostFilter.archived =>
                          'No archived events yet',
                        },
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (_filter) {
                          _OfficerPostFilter.live =>
                          'Tap "New Post" above to publish an update.',
                          _OfficerPostFilter.drafts =>
                          'Posts saved as draft will appear here until published.',
                          _OfficerPostFilter.archived =>
                          'Finished events you archive will appear here.',
                        },
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: slateSub),
                      ),
                    ],
                  ),
                )
              else
                ...displayedPosts.map((post) {
                  final isDraft = !post.isPublished && !post.isArchived;
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
                                      : isDraft
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  post.isArchived
                                      ? 'Archived'
                                      : isDraft
                                      ? 'Draft'
                                      : 'Live',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: post.isArchived
                                        ? slateSub
                                        : isDraft
                                        ? const Color(0xFF92400E)
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
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: navy,
                                    side: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: isDraft
                                    ? FilledButton.icon(
                                  onPressed: () async {
                                    await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreatePostScreen(
                                          orgCode: post.orgCode,
                                          existingPost: post,
                                        ),
                                      ),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: navy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit_rounded,
                                      size: 16, color: gold),
                                  label: const Text(
                                    'Edit / Publish',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12),
                                  ),
                                )
                                    : FilledButton.icon(
                                  onPressed: () => _toggleArchive(post),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: post.isArchived
                                        ? navy
                                        : const Color(0xFFF59E0B),
                                    foregroundColor: post.isArchived
                                        ? Colors.white
                                        : navy,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    post.isArchived
                                        ? Icons.unarchive_rounded
                                        : Icons.archive_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    post.isArchived
                                        ? 'Restore'
                                        : 'Archive',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12),
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
          );
        },
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