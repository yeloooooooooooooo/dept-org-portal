import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';
import '../widgets/portal_background.dart';
import 'event_details_screen.dart';
import 'organizations_screen.dart';

class OrgDetailsScreen extends StatefulWidget {
  final String orgCode;
  final VoidCallback? onViewFeed;

  const OrgDetailsScreen({
    super.key,
    required this.orgCode,
    this.onViewFeed,
  });

  @override
  State<OrgDetailsScreen> createState() => _OrgDetailsScreenState();
}

class _OrgDetailsScreenState extends State<OrgDetailsScreen> {
  static const List<String> _categories = [
    'All',
    'Event',
    'Merch',
    'Announcement',
  ];

  String _selectedCategory = 'All';

  void _openEditOrgSheet(CicsOrgProfile org) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final mottoCtrl = TextEditingController(text: org.motto);
    final aboutCtrl = TextEditingController(text: org.about);
    final adviserCtrl = TextEditingController(text: org.adviser);
    final officeCtrl = TextEditingController(text: org.officeLocation);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
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
                          children: [
                            OrgLogoAvatar(orgCode: org.code, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit ${org.code} Details',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: navy,
                                    ),
                                  ),
                                  Text(
                                    org.officialEmail,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: slateSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _EditField(
                          label: 'ORGANIZATION MOTTO / TAGLINE',
                          controller: mottoCtrl,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 14),
                        _EditField(
                          label: 'ABOUT ORGANIZATION',
                          controller: aboutCtrl,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _EditField(
                          label: 'FACULTY ADVISER',
                          controller: adviserCtrl,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 14),
                        _EditField(
                          label: 'CAMPUS OFFICE LOCATION',
                          controller: officeCtrl,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSaving
                                    ? null
                                    : () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: navy,
                                  side: const BorderSide(color: cardBorder),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        final newMotto =
                                            mottoCtrl.text.trim().isNotEmpty
                                                ? mottoCtrl.text.trim()
                                                : org.motto;
                                        final newAbout =
                                            aboutCtrl.text.trim().isNotEmpty
                                                ? aboutCtrl.text.trim()
                                                : org.about;
                                        final newAdviser =
                                            adviserCtrl.text.trim().isNotEmpty
                                                ? adviserCtrl.text.trim()
                                                : org.adviser;
                                        final newOffice =
                                            officeCtrl.text.trim().isNotEmpty
                                                ? officeCtrl.text.trim()
                                                : org.officeLocation;

                                        setModalState(() => isSaving = true);
                                        try {
                                          await PortalRepository.instance
                                              .updateOrgProfile(
                                            orgCode: org.code,
                                            motto: newMotto,
                                            about: newAbout,
                                            adviser: newAdviser,
                                            officeLocation: newOffice,
                                            officers: org.officers
                                                .map((e) => e.toMap())
                                                .toList(),
                                          );

                                          org.motto = newMotto;
                                          org.about = newAbout;
                                          org.adviser = newAdviser;
                                          org.officeLocation = newOffice;

                                          if (!sheetContext.mounted) return;
                                          Navigator.pop(sheetContext);

                                          if (!mounted) return;
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${org.code} organization details saved.'),
                                              backgroundColor: navy,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } catch (e) {
                                          setModalState(() => isSaving = false);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to save changes: $e'),
                                              backgroundColor:
                                                  const Color(0xFFDC2626),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: navy,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: gold,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle_outline,
                                        size: 18, color: gold),
                                label: Text(
                                  isSaving ? 'Saving...' : 'Save Changes',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddOfficerDialog(CicsOrgProfile org) async {
    final nameCtrl = TextEditingController();
    final positionCtrl = TextEditingController();
    String selectedYear = '3rd Year';

    final added = await showDialog<OrgOfficerMember>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Add Executive Officer',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F2547),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Maria Clara Santos',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: positionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  hintText: 'e.g. President, VP Internal',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration: const InputDecoration(labelText: 'Year Level'),
                items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedYear = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    positionCtrl.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  OrgOfficerMember(
                    name: nameCtrl.text.trim(),
                    position: positionCtrl.text.trim(),
                    year: selectedYear,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F2547),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (added == null) return;

    final updatedList = [...org.officers, added];
    await PortalRepository.instance.updateOrgProfile(
      orgCode: org.code,
      motto: org.motto,
      about: org.about,
      adviser: org.adviser,
      officeLocation: org.officeLocation,
      officers: updatedList.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> _removeOfficer(CicsOrgProfile org, int index) async {
    final updatedList = [...org.officers]..removeAt(index);
    await PortalRepository.instance.updateOrgProfile(
      orgCode: org.code,
      motto: org.motto,
      about: org.about,
      adviser: org.adviser,
      officeLocation: org.officeLocation,
      officers: updatedList.map((e) => e.toMap()).toList(),
    );
  }

  Widget _buildExecutiveBoardCard({
    required CicsOrgProfile org,
    required bool canEdit,
  }) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                'EXECUTIVE OFFICERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: slateSub,
                ),
              ),
              if (canEdit)
                TextButton.icon(
                  onPressed: () => _showAddOfficerDialog(org),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 15,
                    color: navy,
                  ),
                  label: const Text(
                    'Add Officer',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: navy,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (org.officers.isEmpty)
            const Text(
              'Officer roster has not been published yet.',
              style: TextStyle(fontSize: 12.5, color: slateSub),
            )
          else
            ...org.officers.asMap().entries.map((entry) {
              final idx = entry.key;
              final member = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: navy,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                subtitle: Text(
                  member.year.isNotEmpty
                      ? '${member.position} • ${member.year}'
                      : member.position,
                  style: const TextStyle(
                    fontSize: 12,
                    color: slateSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: canEdit
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: Color(0xFFDC2626),
                        ),
                        onPressed: () => _removeOfficer(org, idx),
                      )
                    : null,
              );
            }),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    final fallback = cicsOrgProfiles[widget.orgCode] ??
        CicsOrgProfile(
          code: widget.orgCode,
          fullName: widget.orgCode,
          focus: 'CICS Student Organization',
          motto: 'Excellence in Computing and Service',
          about: 'Accredited student organization at BatStateU Alangilan.',
          adviser: 'CICS Faculty Adviser',
          officeLocation: 'CICS Building, Alangilan Campus',
        );

    final repo = PortalRepository.instance;
    final currentUser = repo.currentUser;
    final canEditThisOrg =
        currentUser.role == 'officer' && currentUser.orgCode == fallback.code;

    return Scaffold(
      body: PortalBackground(
        child: StreamBuilder<OrgProfileMap>(
          stream: repo.watchOrgProfiles(),
          builder: (context, orgSnapshot) {
            final remoteOrgs = orgSnapshot.data ?? const {};
            final org = remoteOrgs.containsKey(widget.orgCode)
                ? CicsOrgProfile.fromMap(
                    remoteOrgs[widget.orgCode]!,
                    fallback: fallback,
                  )
                : fallback;

            return StreamBuilder<List<CampusPost>>(
              stream: repo.watchPosts(),
              builder: (context, snapshot) {
                final allPosts = snapshot.data ?? const <CampusPost>[];
                final orgPosts = allPosts
                    .where((p) =>
                        p.orgCode == org.code &&
                        p.isPublished &&
                        !p.isArchived)
                    .toList();

                final filteredPosts = _selectedCategory == 'All'
                    ? orgPosts
                    : orgPosts
                        .where((p) =>
                            p.category.trim().toLowerCase() ==
                            _selectedCategory.toLowerCase())
                        .toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 60),
                  children: [
                    PortalHeroHeader(
                      bottomPadding: 30,
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
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back_rounded,
                                          size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'All Orgs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onViewFeed != null)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        widget.onViewFeed!();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.dynamic_feed_rounded,
                                                size: 15, color: gold),
                                            SizedBox(width: 6),
                                            Text(
                                              'Main Feed',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (canEditThisOrg) ...[
                                    if (widget.onViewFeed != null)
                                      const SizedBox(width: 8),
                                    FilledButton.icon(
                                      onPressed: () => _openEditOrgSheet(org),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: gold,
                                        foregroundColor: navy,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 9),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.edit_rounded,
                                          size: 16),
                                      label: const Text(
                                        'Edit Org Details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.14),
                                  border: Border.all(color: gold, width: 2),
                                ),
                                child:
                                    OrgLogoAvatar(orgCode: org.code, size: 60),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      org.code,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      org.fullName,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${org.motto}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    PortalResponsiveGrid(
                      spacing: 16,
                      children: [
                        // Card 1: About & Focus
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ABOUT ORGANIZATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: slateSub,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                org.about,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: navy,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card 2: Official Contact & Directory Info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OFFICIAL DIRECTORY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: slateSub,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _OrgMetaRow(
                                icon: Icons.alternate_email_rounded,
                                label: 'G-Suite Email',
                                value: org.officialEmail,
                              ),
                              const SizedBox(height: 11),
                              _OrgMetaRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Adviser',
                                value: org.adviser,
                              ),
                              const SizedBox(height: 11),
                              _OrgMetaRow(
                                icon: Icons.location_on_outlined,
                                label: 'Office',
                                value: org.officeLocation,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Card 3: Public Executive Officers Roster
                    _centeredBody(
                      _buildExecutiveBoardCard(
                        org: org,
                        canEdit: canEditThisOrg,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Header + Category Filter Pills
                    _centeredBody(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Published by ${org.code}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: navy.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filteredPosts.length} ${filteredPosts.length == 1 ? 'post' : 'posts'}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((category) {
                                final isSelected =
                                    _selectedCategory == category;
                                final count = category == 'All'
                                    ? orgPosts.length
                                    : orgPosts
                                        .where((p) =>
                                            p.category.trim().toLowerCase() ==
                                            category.toLowerCase())
                                        .length;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => setState(
                                        () => _selectedCategory = category),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected ? navy : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected ? navy : cardBorder,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: navy.withValues(
                                                      alpha: 0.16),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? Colors.white
                                                  : navy,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? gold
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$count',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w900,
                                                color: isSelected
                                                    ? navy
                                                    : slateSub,
                                              ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData)
                      _centeredBody(
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: CircularProgressIndicator(color: navy),
                          ),
                        ),
                      )
                    else if (filteredPosts.isEmpty)
                      _centeredBody(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 30,
                                color: slateSub,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedCategory == 'All'
                                    ? 'No active posts from ${org.code} yet.'
                                    : 'No ${_selectedCategory.toLowerCase()} posts from ${org.code} yet.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: slateSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      PortalResponsiveGrid(
                        spacing: 14,
                        children: filteredPosts.map((post) {
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailsScreen(post: post),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: navy,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      post.dateBadge,
                                      style: const TextStyle(
                                        color: gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          post.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: navy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${post.category} • ${post.location}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: slateSub,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: slateSub),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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

class _OrgMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OrgMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F2547),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _EditField({
    required this.label,
    required this.controller,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: navy,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}