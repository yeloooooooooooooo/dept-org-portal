import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';

class EventDetailsScreen extends StatefulWidget {
  final CampusPost post;

  const EventDetailsScreen({super.key, required this.post});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Future<void> _launchExternal(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No external link provided for this post.')),
      );
      return;
    }

    final normalized = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('mailto:')
        ? trimmed
        : 'https://$trimmed';

    final Uri uri = Uri.parse(normalized);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $normalized')),
      );
    }
  }

  Widget _centeredBody(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
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

    final post = widget.post;
    final repo = PortalRepository.instance;
    final currentUser = repo.currentUser;
    final isOwnOrgOfficer =
        currentUser.role == 'officer' && currentUser.orgCode == post.orgCode;

    final initial = post.pointPersonName.trim().isNotEmpty
        ? post.pointPersonName.trim()[0].toUpperCase()
        : '?';

    final isDraft = !post.isPublished && !post.isArchived;
    final statusLabel = post.isArchived
        ? 'Archived'
        : isDraft
        ? 'Draft'
        : 'Open';
    final statusBg = post.isArchived
        ? const Color(0xFFF1F5F9)
        : isDraft
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFDCFCE7);
    final statusFg = post.isArchived
        ? slateSub
        : isDraft
        ? const Color(0xFF92400E)
        : const Color(0xFF166534);

    return Scaffold(
      body: PortalBackground(
        child: ListenableBuilder(
          listenable: repo,
          builder: (context, _) {
            final isDone = repo.isPostDone(post.id);

            return ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                PortalHeroHeader(
                  bottomPadding: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              post.dateBadge,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gold.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          '${post.orgCode} • ${post.category.toUpperCase()}',
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${post.fullDate} • ${post.timeRange}',
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Main Info Card
                _centeredBody(
                  Container(
                    padding: const EdgeInsets.all(22),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            OrgLogoAvatar(orgCode: post.orgCode, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.orgCode,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                      color: navy,
                                    ),
                                  ),
                                  Text(
                                    post.orgFullName,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: slateSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusFg,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28, color: cardBorder),
                        const Text(
                          'ABOUT THIS UPDATE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: slateSub,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.description,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF334155),
                            height: 1.55,
                          ),
                        ),
                        const Divider(height: 28, color: cardBorder),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          title: post.fullDate,
                          subtitle: post.timeRange,
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          title: post.location,
                          subtitle: 'Verify venue updates before arriving',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Point Person Card
                _centeredBody(
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HAVE A QUESTION? YOUR POINT PERSON',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: slateSub,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 23,
                              backgroundColor: navy.withValues(alpha: 0.1),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.pointPersonName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: navy,
                                    ),
                                  ),
                                  Text(
                                    post.pointPersonRole,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: slateSub,
                                    ),
                                  ),
                                  if (post.pointPersonEmail.trim().isNotEmpty)
                                    Text(
                                      post.pointPersonEmail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (post.pointPersonEmail.trim().isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () => _launchExternal(
                                  'mailto:${post.pointPersonEmail}',
                                ),
                                icon: const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Email',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: navy,
                                  side: const BorderSide(color: cardBorder),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Primary External Form CTA & Role-Aware Secondary Action
                _centeredBody(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _launchExternal(post.formUrl),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: gold,
                        ),
                        label: const Text(
                          'Open Official Form / Payment Link',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Opens the official organizer's external page.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: slateSub),
                      ),
                      if (isOwnOrgOfficer && !isDraft) ...[
                        const SizedBox(height: 14),
                          FutureBuilder<TaskCountMap>(
                          future: repo.fetchOrgTaskCompletionCounts(post.orgCode),
                          builder: (context, countSnap) {
                            final completed = countSnap.data?[post.id] ?? 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.task_alt_rounded,
                                    size: 19,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Students Marked Done',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    countSnap.connectionState ==
                                            ConnectionState.waiting
                                        ? '...'
                                        : '$completed ${completed == 1 ? 'student' : 'students'}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: navy,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final wasArchived = post.isArchived;
                            await repo.toggleArchivePost(post);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !wasArchived
                                      ? 'Moved "${post.title}" to Archive'
                                      : 'Restored "${post.title}" to Live Feed',
                                ),
                                backgroundColor: navy,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(this.context);
                          },
                          icon: Icon(
                            post.isArchived
                                ? Icons.unarchive_rounded
                                : Icons.archive_outlined,
                            color: navy,
                          ),
                          label: Text(
                            post.isArchived
                                ? 'Restore to Live Feed'
                                : 'Archive Post',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: navy,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ] else if (!isOwnOrgOfficer) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await repo.togglePostDone(post);
                          },
                          icon: Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline_rounded,
                            color: isDone ? const Color(0xFF16A34A) : navy,
                          ),
                          label: Text(
                            isDone
                                ? 'Completed in Checklist'
                                : 'Mark as Done',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isDone ? const Color(0xFF16A34A) : navy,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(
                              color:
                              isDone ? const Color(0xFF16A34A) : cardBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0F2547)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF0F2547),
                ),
              ),
              Text(
                subtitle,
                style:
                const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}