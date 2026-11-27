import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'event_details_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
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
        return Icons.celebration_rounded;
      case 'Merch':
        return Icons.checkroom_rounded;
      case 'Membership Fee':
        return Icons.verified_user_rounded;
      case 'Educational':
        return Icons.terminal_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Events':
        return const Color(0xFF2563EB);
      case 'Merch':
        return const Color(0xFFB45309);
      case 'Membership Fee':
        return const Color(0xFF059669);
      case 'Educational':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF0F2547);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

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
                final tasks = allPosts
                    .where((p) => p.isPublished && !p.isArchived)
                    .toList();
                final completedCount =
                    tasks.where((p) => repo.isPostDone(p.id)).length;
                final progress =
                tasks.isEmpty ? 0.0 : completedCount / tasks.length;

                const categoryOrder = [
                  'Events',
                  'Merch',
                  'Membership Fee',
                  'Educational',
                ];

                final groupedTasks = <String, List<CampusPost>>{};
                for (final cat in categoryOrder) {
                  final items = tasks.where((t) => t.category == cat).toList();
                  if (items.isNotEmpty) {
                    groupedTasks[cat] = items;
                  }
                }
                for (final task in tasks) {
                  if (!categoryOrder.contains(task.category)) {
                    groupedTasks
                        .putIfAbsent(task.category, () => [])
                        .add(task);
                  }
                }

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
                            '$completedCount of ${tasks.length} items completed this semester',
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
                        ],
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
                    else if (tasks.isEmpty)
                      _centeredBody(
                        Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            children: [
                              Icon(Icons.task_alt_rounded,
                                  size: 48,
                                  color: slateSub.withValues(alpha: 0.5)),
                              const SizedBox(height: 10),
                              const Text(
                                'No active tasks right now',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'New events, merch drops, and membership fees will appear here.',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(fontSize: 12, color: slateSub),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...groupedTasks.entries.map((entry) {
                        final category = entry.key;
                        final items = entry.value;
                        final catDone =
                            items.where((i) => repo.isPostDone(i.id)).length;
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
                                            color: accent.withValues(alpha: 0.12),
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
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        '$catDone / ${items.length} done',
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
                                            await repo.togglePostDone(post);
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
                                                ? const Icon(Icons.check_rounded,
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