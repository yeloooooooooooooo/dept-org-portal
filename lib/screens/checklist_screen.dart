import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../widgets/org_logo_avatar.dart';
import 'event_details_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final pendingPosts =
    sampleCampusPosts.where((post) => !post.isDone).toList();
    final completedPosts =
    sampleCampusPosts.where((post) => post.isDone).toList();

    final totalCount = sampleCampusPosts.length;
    final completedCount = completedPosts.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final percentInt = (progress * 100).round();

    final visibleList = _showCompleted ? completedPosts : pendingPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            // Top Badge
            const Row(
              children: [
                Icon(Icons.assignment_turned_in_outlined,
                    size: 16, color: navy),
                SizedBox(width: 6),
                Text(
                  'My checklist',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Editorial Header matching "04 · Personal checklist"
            const Text(
              'A little progress,\nevery day.',
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
              'Keep your campus to-dos in one place.',
              style: TextStyle(fontSize: 14, color: slateSub),
            ),
            const SizedBox(height: 20),

            // Progress Card ("YOU'RE MAKING PROGRESS")
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "YOU'RE MAKING PROGRESS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: slateSub,
                        ),
                      ),
                      Text(
                        '$percentInt%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(gold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$completedCount completed • ${pendingPosts.length} to go',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pending / Completed Toggle Pills
            Row(
              children: [
                Expanded(
                  child: _TabPill(
                    label: 'Pending (${pendingPosts.length})',
                    selected: !_showCompleted,
                    onTap: () => setState(() => _showCompleted = false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TabPill(
                    label: 'Completed (${completedPosts.length})',
                    selected: _showCompleted,
                    onTap: () => setState(() => _showCompleted = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Label
            Text(
              _showCompleted ? 'COMPLETED TASKS' : 'UP NEXT',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: slateSub,
              ),
            ),
            const SizedBox(height: 10),

            if (visibleList.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Text(
                  _showCompleted
                      ? 'No completed items yet. Mark an announcement as done to track it here.'
                      : 'All caught up! No pending campus tasks.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: slateSub, fontSize: 13),
                ),
              )
            else
              ...visibleList.map((post) {
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
                          InkWell(
                            onTap: () =>
                                setState(() => post.isDone = !post.isDone),
                            child: Icon(
                              post.isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: post.isDone
                                  ? const Color(0xFF16A34A)
                                  : slateSub,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OrgLogoAvatar(orgCode: post.orgCode, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${post.orgCode} • ${post.category.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: slateSub,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: navy,
                                    decoration: post.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
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

            const SizedBox(height: 8),
            const Text(
              'Your checklist tracks progress, not payment verification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: slateSub),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? navy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : navy,
          ),
        ),
      ),
    );
  }
}