import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/campus_post.dart';
import '../widgets/org_logo_avatar.dart';

class EventDetailsScreen extends StatefulWidget {
  final CampusPost post;

  const EventDetailsScreen({super.key, required this.post});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Future<void> _launchExternal(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);
    final post = widget.post;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Event details',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: navy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Banner matching "CICS TECH SUMMIT / 2026"
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2547), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${post.orgCode} • ${post.category.toUpperCase()}',
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    post.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ideas today. Impact tomorrow.',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Info Card
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
                    children: [
                      OrgLogoAvatar(orgCode: post.orgCode, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.orgCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: navy,
                              ),
                            ),
                            Text(
                              post.orgFullName,
                              style:
                              const TextStyle(fontSize: 12, color: slateSub),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 28, color: cardBorder),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: post.fullDate,
                    subtitle: post.timeRange,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    title: post.location,
                    subtitle: 'Verify venue updates before arriving',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Point Person Card ("Have a question? Your point person")
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HAVE A QUESTION? YOUR POINT PERSON',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: slateSub,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: navy.withValues(alpha: 0.1),
                        child: Text(
                          post.pointPersonName[0],
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: navy,
                              ),
                            ),
                            Text(
                              post.pointPersonRole,
                              style:
                              const TextStyle(fontSize: 12, color: slateSub),
                            ),
                            Text(
                              post.pointPersonEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _launchExternal('mailto:${post.pointPersonEmail}'),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navy,
                          side: const BorderSide(color: cardBorder),
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
            const SizedBox(height: 20),

            // External Form CTA
            FilledButton.icon(
              onPressed: () => _launchExternal(post.formUrl),
              icon: const Icon(Icons.open_in_new, size: 18, color: gold),
              label: const Text(
                'Open Official Form / Payment Link',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
            const SizedBox(height: 14),

            // Mark as Done Toggle
            OutlinedButton.icon(
              onPressed: () {
                setState(() => post.isDone = !post.isDone);
              },
              icon: Icon(
                post.isDone ? Icons.check_circle : Icons.check_circle_outline,
                color: post.isDone ? const Color(0xFF16A34A) : navy,
              ),
              label: Text(
                post.isDone ? 'Completed in Checklist' : 'Mark as Done',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: post.isDone ? const Color(0xFF16A34A) : navy,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(
                  color: post.isDone ? const Color(0xFF16A34A) : cardBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
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
        Column(
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }
}