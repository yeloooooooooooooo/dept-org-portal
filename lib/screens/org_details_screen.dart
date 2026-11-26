import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/campus_post.dart';
import '../widgets/org_logo_avatar.dart';
import 'event_details_screen.dart';

class OrgDetailsScreen extends StatefulWidget {
  final Map orgData;

  const OrgDetailsScreen({super.key, required this.orgData});

  @override
  State<OrgDetailsScreen> createState() => _OrgDetailsScreenState();
}

class _OrgDetailsScreenState extends State<OrgDetailsScreen> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = (widget.orgData['isMember'] as bool?) ?? false;
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open mail app for $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final code = widget.orgData['code'].toString();
    final name = widget.orgData['fullName'].toString();
    final about = widget.orgData['about'].toString();
    final president = widget.orgData['president'].toString();
    final email = widget.orgData['email'].toString();
    final room = widget.orgData['officeLocation'].toString();
    final focusTags = List.from(widget.orgData['tags'] as Iterable);

    final orgPosts = sampleCampusPosts
        .where((p) => p.orgCode == code && p.isPublished)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: navy),
        title: Text(
          code,
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Navy Header Card with Logo, Full Name & Join/Following Toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2547), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: OrgLogoAvatar(orgCode: code, size: 46),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            code,
                            style: const TextStyle(
                              color: gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focusTags
                      .map(
                        (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() => _isFollowing = !_isFollowing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFollowing
                                ? 'Joined $code updates!'
                                : 'Unfollowed $code updates',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      _isFollowing
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      size: 18,
                      color: _isFollowing ? navy : gold,
                    ),
                    label: Text(
                      _isFollowing ? 'Member • Following' : 'Join / Follow Org',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _isFollowing ? navy : Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isFollowing
                          ? gold
                          : Colors.white.withValues(alpha: 0.16),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About & Office Info Card
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
                const Text(
                  'ABOUT THE ORGANIZATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: slateSub,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  about,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                const Divider(height: 26, color: cardBorder),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: navy),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'President: $president',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined,
                        size: 18, color: navy),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        room,
                        style: const TextStyle(fontSize: 13, color: slateSub),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _sendEmail(email),
                    icon: const Icon(Icons.email_outlined, size: 17),
                    label: Text('Inquire at $email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: const BorderSide(color: cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Scoped Announcements for this Org
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$code announcements',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              Text(
                '${orgPosts.length} active',
                style: const TextStyle(fontSize: 12, color: slateSub),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (orgPosts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
              ),
              child: Text(
                'No active announcements from $code right now.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: slateSub, fontSize: 13),
              ),
            )
          else
            ...orgPosts.map((post) {
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    fontWeight: FontWeight.w700,
                                    color: navy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
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
    );
  }
}