import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/portal_repository.dart';
import '../widgets/org_logo_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  final String? orgCode;
  final CampusPost? existingPost;

  const CreatePostScreen({
    super.key,
    this.orgCode,
    this.existingPost,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const Color _navy = Color(0xFF0F2544);
  static const Color _navyLight = Color(0xFF1A3A68);
  static const Color _gold = Color(0xFFE5A93B);
  static const Color _bg = Color(0xFFF4F6FA);

  final _formKey = GlobalKey<FormState>();
  final _repo = PortalRepository.instance;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateBadgeController;
  late final TextEditingController _fullDateController;
  late final TextEditingController _timeRangeController;
  late final TextEditingController _locationController;
  late final TextEditingController _pointPersonNameController;
  late final TextEditingController _pointPersonRoleController;
  late final TextEditingController _pointPersonEmailController;
  late final TextEditingController _formUrlController;

  late String _selectedCategory;
  late bool _isPublished;
  bool _isSubmitting = false;

  static const _categories = [
    {
      'label': 'Events',
      'icon': Icons.event_available_rounded,
      'color': Color(0xFF1D4ED8),
    },
    {
      'label': 'Merch',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFB45309),
    },
    {
      'label': 'Membership Fee',
      'icon': Icons.payments_rounded,
      'color': Color(0xFF047857),
    },
    {
      'label': 'Educational',
      'icon': Icons.school_rounded,
      'color': Color(0xFF6D28D9),
    },
  ];

  static const Map<String, String> _orgNames = {
    'CICS SC': 'CICS Student Council',
    'JPCS': 'Junior Philippine Computer Society',
    'ACCESS': 'Association of Committed Computer Science Students',
    'INTESS': 'Information Technology Society of Students',
  };

  String get _effectiveOrgCode =>
      widget.existingPost?.orgCode ??
          widget.orgCode ??
          _repo.currentUser.orgCode;

  @override
  void initState() {
    super.initState();
    final post = widget.existingPost;
    final user = _repo.currentUser;
    final activeOrg = _effectiveOrgCode;

    _selectedCategory = post?.category ?? 'Events';
    _isPublished = post?.isPublished ?? true;

    _titleController = TextEditingController(text: post?.title ?? '');
    _descriptionController =
        TextEditingController(text: post?.description ?? '');
    _dateBadgeController =
        TextEditingController(text: post?.dateBadge ?? '04 DEC');
    _fullDateController =
        TextEditingController(text: post?.fullDate ?? 'December 04, 2026');
    _timeRangeController =
        TextEditingController(text: post?.timeRange ?? '9:00 AM - 4:00 PM');
    _locationController = TextEditingController(
      text: post?.location ?? 'CICS Auditorium • Main Campus',
    );
    _pointPersonNameController = TextEditingController(
      text: post?.pointPersonName ?? user.fullName,
    );
    _pointPersonRoleController = TextEditingController(
      text: post?.pointPersonRole ?? '$activeOrg Officer',
    );
    _pointPersonEmailController = TextEditingController(
      text: post?.pointPersonEmail ?? user.email,
    );
    _formUrlController = TextEditingController(
      text: post?.formUrl ?? 'https://forms.gle/',
    );

    for (final c in [
      _titleController,
      _descriptionController,
      _dateBadgeController,
      _fullDateController,
      _timeRangeController,
      _locationController,
      _pointPersonNameController,
      _pointPersonRoleController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateBadgeController.dispose();
    _fullDateController.dispose();
    _timeRangeController.dispose();
    _locationController.dispose();
    _pointPersonNameController.dispose();
    _pointPersonRoleController.dispose();
    _pointPersonEmailController.dispose();
    _formUrlController.dispose();
    super.dispose();
  }

  Color _categoryColor(String category) {
    final match = _categories.firstWhere(
          (c) => c['label'] == category,
      orElse: () => _categories.first,
    );
    return match['color'] as Color;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final orgCode = _effectiveOrgCode;
    final orgFullName =
        widget.existingPost?.orgFullName ?? (_orgNames[orgCode] ?? orgCode);

    final post = CampusPost(
      id: widget.existingPost?.id ?? '',
      orgCode: orgCode,
      orgFullName: orgFullName,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateBadge: _dateBadgeController.text.trim().toUpperCase(),
      fullDate: _fullDateController.text.trim(),
      timeRange: _timeRangeController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      pointPersonName: _pointPersonNameController.text.trim(),
      pointPersonRole: _pointPersonRoleController.text.trim(),
      pointPersonEmail: _pointPersonEmailController.text.trim(),
      formUrl: _formUrlController.text.trim(),
      publishedDateLabel: _isPublished ? 'NOV 27' : 'DRAFT',
      isPublished: _isPublished,
      isArchived: widget.existingPost?.isArchived ?? false,
    );

    try {
      await _repo.savePost(post, isNew: widget.existingPost == null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
          content: Text(
            _isPublished
                ? 'Post published live to Discover!'
                : 'Saved to your organization drafts.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          content: Text('Could not save post: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPost != null;
    final orgCode = _effectiveOrgCode;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Organization Post' : 'Create Organization Post',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Broadcasting to CICS Student Discover Feed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              orgCode,
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 940;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildLivePreview(orgCode)),
                  ],
                )
                    : Column(
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildLivePreview(orgCode),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.campaign_rounded, 'Announcement Details'),
            const SizedBox(height: 16),
            _fieldLabel('Post Title'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g., CICS Tech Summit 2026'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 18),
            _fieldLabel('Category'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final label = cat['label'] as String;
                final icon = cat['icon'] as IconData;
                final color = cat['color'] as Color;
                final selected = _selectedCategory == label;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = label),
                  avatar: Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : color,
                  ),
                  label: Text(label),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _navy,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: _navy,
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: BorderSide(
                    color: selected ? _navy : const Color(0xFFCBD5E1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _fieldLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Share key details, eligibility, registration steps, or payment instructions...',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Divider(height: 1),
            ),
            _sectionHeader(Icons.schedule_rounded, 'Schedule & Venue'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Date Badge'),
                      TextFormField(
                        controller: _dateBadgeController,
                        decoration: _inputDecoration('04 DEC'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Full Event / Due Date'),
                      TextFormField(
                        controller: _fullDateController,
                        decoration: _inputDecoration('December 04, 2026'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Time Range'),
                      TextFormField(
                        controller: _timeRangeController,
                        decoration: _inputDecoration('9:00 AM - 4:00 PM'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Location / Booth'),
                      TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration('CICS Auditorium'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Divider(height: 1),
            ),
            _sectionHeader(Icons.contact_mail_rounded, 'Point Person & Link'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Contact Name'),
                      TextFormField(
                        controller: _pointPersonNameController,
                        decoration: _inputDecoration('Andrea Reyes'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Officer Role'),
                      TextFormField(
                        controller: _pointPersonRoleController,
                        decoration: _inputDecoration('Event Coordinator'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Contact Email'),
                      TextFormField(
                        controller: _pointPersonEmailController,
                        decoration: _inputDecoration('officer@g.batstate-u.edu.ph'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Registration / Form URL'),
                      TextFormField(
                        controller: _formUrlController,
                        decoration: _inputDecoration('https://forms.gle/...'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Divider(height: 1),
            ),
            _fieldLabel('Visibility Status'),
            Row(
              children: [
                Expanded(
                  child: _visibilityOption(
                    selected: _isPublished,
                    title: 'Publish Immediately',
                    subtitle: 'Visible to all CICS students now',
                    icon: Icons.public_rounded,
                    onTap: () => setState(() => _isPublished = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _visibilityOption(
                    selected: !_isPublished,
                    title: 'Save as Draft',
                    subtitle: 'Only visible to org officers',
                    icon: Icons.edit_note_rounded,
                    onTap: () => setState(() => _isPublished = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _isPublished ? _navy : const Color(0xFF475569),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  _isPublished
                      ? Icons.rocket_launch_rounded
                      : Icons.save_rounded,
                  color: _gold,
                ),
                label: Text(
                  _isSubmitting
                      ? 'Saving...'
                      : (_isPublished
                      ? 'Publish Post to Discover'
                      : 'Save Draft'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreview(String orgCode) {
    final badgeColor = _categoryColor(_selectedCategory);
    final title = _titleController.text.trim().isEmpty
        ? 'Your Post Title Will Appear Here'
        : _titleController.text.trim();
    final desc = _descriptionController.text.trim().isEmpty
        ? 'Start typing a description on the left to preview how students will see your announcement in the Discover feed.'
        : _descriptionController.text.trim();
    final dateBadge = _dateBadgeController.text.trim().isEmpty
        ? '04 DEC'
        : _dateBadgeController.text.trim().toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility_rounded, size: 18, color: _navy),
            const SizedBox(width: 8),
            const Text(
              'LIVE STUDENT CARD PREVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: _navy,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isPublished
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isPublished ? 'LIVE FEED' : 'DRAFT ONLY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _isPublished
                      ? const Color(0xFF166534)
                      : const Color(0xFF92400E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, _navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    OrgLogoAvatar(orgCode: orgCode, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orgCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _orgNames[orgCode] ?? 'CICS Organization',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        dateBadge,
                        style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedCategory.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _previewMetaRow(
                      Icons.calendar_today_rounded,
                      '${_fullDateController.text} • ${_timeRangeController.text}',
                    ),
                    const SizedBox(height: 6),
                    _previewMetaRow(
                      Icons.location_on_rounded,
                      _locationController.text,
                    ),
                    const SizedBox(height: 6),
                    _previewMetaRow(
                      Icons.person_rounded,
                      '${_pointPersonNameController.text} (${_pointPersonRoleController.text})',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _navyLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.trim().isEmpty ? '—' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _visibilityOption({
    required bool selected,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _navy.withValues(alpha: 0.06)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _navy : const Color(0xFFCBD5E1),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _navy : const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: selected ? _navy : const Color(0xFF334155),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _navy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: _navy),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _navy, width: 1.8),
      ),
    );
  }
}