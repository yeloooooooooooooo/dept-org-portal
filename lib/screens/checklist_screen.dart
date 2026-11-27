import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'event_details_screen.dart';

enum _TaskStatusTab { pending, done }

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<String> get _orgFilters => [
      'All Orgs',
      ...PortalRepository.instance.allowedOrgCodes,
    ];

  static const List<String> _defaultCategories = [
    'Events',
    'Merch',
    'Membership Fee',
    'Educational',
  ];

  _TaskStatusTab _activeTab = _TaskStatusTab.pending;
  String _selectedOrg = 'All Orgs';
  String _selectedCategory = 'All';

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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Events':
      case 'Event':
        return Icons.celebration_rounded;
      case 'Merch':
        return Icons.checkroom_rounded;
      case 'Membership Fee':
        return Icons.verified_user_rounded;
      case 'Educational':
        return Icons.terminal_rounded;
      case 'Announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Events':
      case 'Event':
        return const Color(0xFF2563EB);
      case 'Merch':
        return const Color(0xFFB45309);
      case 'Membership Fee':
        return const Color(0xFF059669);
      case 'Educational':
        return const Color(0xFF7C3AED);
      case 'Announcement':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF0F2547);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final repo = PortalRepository.instance;

    return Scaffold(
      body: PortalBackground(
        child: ListenableBuilder(
          listenable: repo,
          builder: (context, _) {
            return StreamBuilder<List<CampusPost>>(
              stream: repo.watchPosts(),
              builder: (context, snapshot) {
                final allPosts = snapshot.data ?? const <CampusPost>[];
                final activeTasks = allPosts
    .where((p) =>
        p.isPublished &&
        !p.isArchived &&
        repo.isOrgAllowedForCurrentUser(p.orgCode))
    .toList();

                final totalCompleted =
                    activeTasks.where((p) => repo.isPostDone(p.id)).length;
                final progress = activeTasks.isEmpty
                    ? 0.0
                    : totalCompleted / activeTasks.length;

                // Build dynamic category list preserving default order + any custom categories
                final categoryOptions = <String>['All', ..._defaultCategories];
                for (final task in activeTasks) {
                  if (task.category.trim().isNotEmpty &&
                      !categoryOptions.contains(task.category)) {
                    categoryOptions.add(task.category);
                  }
                }

                // Apply Org & Category filters first so Pending/Done tab counts match current filters
                final filteredByMeta = activeTasks.where((post) {
                  final matchesOrg = _selectedOrg == 'All Orgs' ||
                      post.orgCode.trim().toUpperCase() ==
                          _selectedOrg.toUpperCase();
                  final matchesCategory = _selectedCategory == 'All' ||
                      post.category.trim().toLowerCase() ==
                          _selectedCategory.toLowerCase();
                  return matchesOrg && matchesCategory;
                }).toList();

                final pendingTasks = filteredByMeta
                    .where((p) => !repo.isPostDone(p.id))
                    .toList();
                final doneTasks = filteredByMeta
                    .where((p) => repo.isPostDone(p.id))
                    .toList();

                final displayedTasks = _activeTab == _TaskStatusTab.pending
                    ? pendingTasks
                    : doneTasks;

                // Group displayed tasks by category
                final groupedTasks = <String, List<CampusPost>>{};
                for (final cat in categoryOptions.where((c) => c != 'All')) {
                  final items =
                  displayedTasks.where((t) => t.category == cat).toList();
                  if (items.isNotEmpty) {
                    groupedTasks[cat] = items;
                  }
                }

                final hasActiveFilters =
                    _selectedOrg != 'All Orgs' || _selectedCategory != 'All';

                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    PortalHeroHeader(
                      bottomPadding: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: gold.withValues(alpha: 0.45)),
                            ),
                            child: const Text(
                              'STUDENT CLEARANCE & TRACKER',
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
                            'My Campus Tasks',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalCompleted of ${activeTasks.length} items completed this semester',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFFCBD5E1)),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(gold),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Pending vs Done Segment Switcher
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
                                    label: 'Pending (${pendingTasks.length})',
                                    selected:
                                    _activeTab == _TaskStatusTab.pending,
                                    onTap: () => setState(() =>
                                    _activeTab = _TaskStatusTab.pending),
                                  ),
                                ),
                                Expanded(
                                  child: _SegmentTab(
                                    label: 'Done (${doneTasks.length})',
                                    selected: _activeTab == _TaskStatusTab.done,
                                    onTap: () => setState(
                                            () => _activeTab = _TaskStatusTab.done),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Organization & Category Filter Bar
                    _centeredBody(
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: navy.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'FILTER BY ORGANIZATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: slateSub,
                                  ),
                                ),
                                if (hasActiveFilters)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedOrg = 'All Orgs';
                                      _selectedCategory = 'All';
                                    }),
                                    child: const Text(
                                      'Reset filters',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _orgFilters.map((org) {
                                  final isSelected = _selectedOrg == org;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _selectedOrg = org),
                                      borderRadius: BorderRadius.circular(11),
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? navy
                                              : const Color(0xFFF8FAFC),
                                          borderRadius:
                                          BorderRadius.circular(11),
                                          border: Border.all(
                                            color:
                                            isSelected ? navy : cardBorder,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (org != 'All Orgs') ...[
                                              OrgLogoAvatar(
                                                  orgCode: org, size: 18),
                                              const SizedBox(width: 6),
                                            ],
                                            Text(
                                              org,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : navy,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'FILTER BY CATEGORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: slateSub,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: categoryOptions.map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () => setState(
                                              () => _selectedCategory = category),
                                      borderRadius: BorderRadius.circular(11),
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? gold.withValues(alpha: 0.22)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius:
                                          BorderRadius.circular(11),
                                          border: Border.all(
                                            color: isSelected
                                                ? gold
                                                : cardBorder,
                                            width: isSelected ? 1.4 : 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? navy : slateSub,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData)
                      _centeredBody(
                        const Padding(
                          padding: EdgeInsets.all(36),
                          child: Center(
                            child: CircularProgressIndicator(color: navy),
                          ),
                        ),
                      )
                    else if (displayedTasks.isEmpty)
                      _centeredBody(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: navy.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _activeTab == _TaskStatusTab.pending
                                      ? Icons.celebration_outlined
                                      : Icons.check_circle_outline_rounded,
                                  size: 28,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                hasActiveFilters
                                    ? 'No ${_activeTab == _TaskStatusTab.pending ? 'pending' : 'completed'} tasks match your filters'
                                    : _activeTab == _TaskStatusTab.pending
                                    ? 'All caught up! No pending tasks'
                                    : 'No completed tasks yet',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hasActiveFilters
                                    ? 'Try clearing your organization or category filter to see more items.'
                                    : _activeTab == _TaskStatusTab.pending
                                    ? 'New events, merch drops, and membership fees will appear here.'
                                    : 'Tap the checkbox on any task to move it here once finished.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12.5, color: slateSub),
                              ),
                              if (hasActiveFilters) ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    _selectedOrg = 'All Orgs';
                                    _selectedCategory = 'All';
                                  }),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: navy,
                                    side: const BorderSide(color: cardBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.filter_alt_off_rounded,
                                      size: 16),
                                  label: const Text(
                                    'Clear Filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      ...groupedTasks.entries.map((entry) {
                        final category = entry.key;
                        final items = entry.value;
                        final accent = _categoryColor(category);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _centeredBody(
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color:
                                            accent.withValues(alpha: 0.12),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            _categoryIcon(category),
                                            size: 16,
                                            color: accent,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: navy,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: cardBorder),
                                      ),
                                      child: Text(
                                        '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: slateSub,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
PortalResponsiveGrid(
                                spacing: 14,
                                children: items.map((post) {
                                  final isDone = repo.isPostDone(post.id);

                                  return Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDone
                                            ? const Color(0xFF86EFAC)
                                            : Colors.transparent,
                                        width: 1.4,
                                      ),
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
                                        InkWell(
                                          onTap: () async {
                                            final wasDone =
                                                repo.isPostDone(post.id);
                                            await repo.togglePostDone(post);
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 0, 16, 16),
                                                  backgroundColor:
                                                      const Color(0xFF0F2547),
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  content: Text(
                                                    wasDone
                                                        ? 'Moved back to Pending'
                                                        : 'Marked "${post.title}" as done',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'UNDO',
                                                    textColor:
                                                        const Color(0xFFD4AF37),
                                                    onPressed: () => repo
                                                        .togglePostDone(post),
                                                  ),
                                                ),
                                              );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: isDone
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              border: Border.all(
                                                color: isDone
                                                    ? const Color(0xFF16A34A)
                                                    : const Color(0xFFCBD5E1),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isDone
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 18,
                                                    color: Colors.white)
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OrgLogoAvatar(
                                            orgCode: post.orgCode, size: 38),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EventDetailsScreen(
                                                          post: post),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  post.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDone
                                                        ? slateSub
                                                        : navy,
                                                    decoration: isDone
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '${post.orgCode} • ${post.dateBadge}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: slateSub,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
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