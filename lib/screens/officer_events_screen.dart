import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'create_post_screen.dart';
import 'event_details_screen.dart';

enum _OfficerPostFilter { live, drafts, archived }

class OfficerEventsScreen extends StatefulWidget {
  final int initialTabIndex;
  const OfficerEventsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OfficerEventsScreen> createState() => _OfficerEventsScreenState();
}

class _OfficerEventsScreenState extends State<OfficerEventsScreen> {
  late _OfficerPostFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = _tabFromIndex(widget.initialTabIndex);
  }

  @override
  void didUpdateWidget(covariant OfficerEventsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      setState(() {
        _filter = _tabFromIndex(widget.initialTabIndex);
      });
    }
  }

  _OfficerPostFilter _tabFromIndex(int index) {
    return switch (index) {
      1 => _OfficerPostFilter.drafts,
      2 => _OfficerPostFilter.archived,
      _ => _OfficerPostFilter.live,
    };
  }

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

  Future<void> _confirmAndDelete(CampusPost post) async {
    const navy = Color(0xFF0F2547);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);
    const dangerRed = Color(0xFFDC2626);
    final isDraft = !post.isPublished && !post.isArchived;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF09162E).withValues(alpha: 0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: cardBorder),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: dangerRed,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDraft ? 'Delete Draft?' : 'Delete Archived Post?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: navy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will permanently remove the post from CICS Hub. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: slateSub,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      children: [
                        OrgLogoAvatar(orgCode: post.orgCode, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
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
                                '${post.category} • ${post.dateBadge}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: slateSub,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: dangerRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await PortalRepository.instance.deletePost(post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Deleted "${post.title}"')),
            ],
          ),
          backgroundColor: navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete post: $e'),
          backgroundColor: dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    const cardBorder = Color(0xFFE2E8F0);

    final repo = PortalRepository.instance;
    final user = repo.currentUser;

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<List<CampusPost>>(
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
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                PortalHeroHeader(
                  bottomPadding: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  '${user.orgCode} PORTAL',
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
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
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text(
                              'New Post',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Manage Events & Posts',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review live announcements, edit saved drafts, or archive past ${user.orgCode} activities.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
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
                                selected:
                                _filter == _OfficerPostFilter.archived,
                                onTap: () => setState(() =>
                                _filter = _OfficerPostFilter.archived),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(color: navy),
                    ),
                  )
                else if (displayedPosts.isEmpty)
                  _centeredBody(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 42,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: navy.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              switch (_filter) {
                                _OfficerPostFilter.live =>
                                Icons.campaign_outlined,
                                _OfficerPostFilter.drafts =>
                                Icons.edit_note_rounded,
                                _OfficerPostFilter.archived =>
                                Icons.inventory_2_outlined,
                              },
                              size: 28,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            switch (_filter) {
                              _OfficerPostFilter.live =>
                              'No live posts for ${user.orgCode}',
                              _OfficerPostFilter.drafts =>
                              'No saved drafts yet',
                              _OfficerPostFilter.archived =>
                              'No archived events yet',
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            switch (_filter) {
                              _OfficerPostFilter.live =>
                              'Published announcements and events will appear here for students to see.',
                              _OfficerPostFilter.drafts =>
                              'Unfinished posts saved as drafts stay private here until you publish them.',
                              _OfficerPostFilter.archived =>
                              'Completed events you archive are stored here for safekeeping.',
                            },
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: slateSub,
                            ),
                          ),
                          if (_filter != _OfficerPostFilter.archived) ...[
                            const SizedBox(height: 18),
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
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 18,
                                color: gold,
                              ),
                              label: const Text(
                                'Create a Post',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  _centeredBody(
                    Column(
                      children: displayedPosts.map((post) {
                        final isDraft = !post.isPublished && !post.isArchived;
                        final canDelete = isDraft || post.isArchived;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  OrgLogoAvatar(
                                    orgCode: post.orgCode,
                                    size: 44,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: navy,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${post.category} • ${post.dateBadge} • ${post.location}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: slateSub,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
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
                              if (post.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  post.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: slateSub,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
                                        side:
                                        const BorderSide(color: cardBorder),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                        ),
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
                                            builder: (_) =>
                                                CreatePostScreen(
                                                  orgCode: post.orgCode,
                                                  existingPost: post,
                                                ),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: navy,
                                        foregroundColor: Colors.white,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: gold,
                                      ),
                                      label: const Text(
                                        'Edit / Publish',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    )
                                        : FilledButton.icon(
                                      onPressed: () =>
                                          _toggleArchive(post),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: post.isArchived
                                            ? navy
                                            : const Color(0xFFF59E0B),
                                        foregroundColor: post.isArchived
                                            ? Colors.white
                                            : navy,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 11,
                                        ),
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
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (canDelete) ...[
                                    const SizedBox(width: 10),
                                    Tooltip(
                                      message: 'Delete permanently',
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _confirmAndDelete(post),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                          const Color(0xFFDC2626),
                                          backgroundColor:
                                          const Color(0xFFFEF2F2),
                                          side: const BorderSide(
                                            color: Color(0xFFFECACA),
                                          ),
                                          minimumSize: const Size(44, 42),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 11,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        ),
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
      behavior: HitTestBehavior.opaque,
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