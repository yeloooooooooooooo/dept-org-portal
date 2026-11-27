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
  static const Color _navy = Color(0xFF0B1E3D);
  static const Color _navyMid = Color(0xFF132D58);
  static const Color _cardBlueDark = Color(0xFF0E3A8A);
  static const Color _cardBlueLight = Color(0xFF1D56C8);
  static const Color _gold = Color(0xFFE5A93B);
  static const Color _bg = Color(0xFFF6F7F9);

  static const _shortMonths = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  static const _fullMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final _formKey = GlobalKey<FormState>();
  final _repo = PortalRepository.instance;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _fullDateController;
  late final TextEditingController _timeRangeController;
  late final TextEditingController _locationController;
  late final TextEditingController _pointPersonNameController;
  late final TextEditingController _pointPersonRoleController;
  late final TextEditingController _pointPersonEmailController;
  late final TextEditingController _formUrlController;

  int _currentStep = 0;
  DateTime _selectedDate = DateTime(2026, 12, 4);
  String _dateBadge = '04 DEC';
  String _selectedCategory = 'Events';
  bool _isPublished = true;
  bool _isSubmitting = false;
  bool _editingPointPerson = false;

  static const _stepLabels = [
    'Details',
    'When & Where',
    'Preview & Publish',
  ];

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

  String _formatDateBadge(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_shortMonths[date.month - 1]}';
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '${_fullMonths[date.month - 1]} $day, ${date.year}';
  }

  DateTime? _tryParseFullDate(String raw) {
    final cleaned = raw.trim().replaceAll(',', '');
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length != 3) return null;

    final monthIndex = _fullMonths.indexWhere(
          (m) => m.toLowerCase() == parts[0].toLowerCase(),
    );
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (monthIndex == -1 || day == null || year == null) return null;
    if (day < 1 || day > 31) return null;

    return DateTime(year, monthIndex + 1, day);
  }

  @override
  void initState() {
    super.initState();
    final post = widget.existingPost;
    final user = _repo.currentUser;
    final activeOrg = _effectiveOrgCode;

    final parsedExistingDate =
    post != null ? _tryParseFullDate(post.fullDate) : null;
    _selectedDate = parsedExistingDate ?? DateTime(2026, 12, 4);
    _dateBadge = post?.dateBadge.trim().isNotEmpty == true
        ? post!.dateBadge.trim().toUpperCase()
        : _formatDateBadge(_selectedDate);

    _selectedCategory = post?.category ?? 'Events';
    _isPublished = post?.isPublished ?? true;

    _titleController = TextEditingController(text: post?.title ?? '');
    _descriptionController =
        TextEditingController(text: post?.description ?? '');
    _fullDateController = TextEditingController(
      text: post?.fullDate.trim().isNotEmpty == true
          ? post!.fullDate
          : _formatFullDate(_selectedDate),
    );
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

    if (_pointPersonNameController.text.trim().isEmpty ||
        _pointPersonEmailController.text.trim().isEmpty) {
      _editingPointPerson = true;
    }

    for (final c in [
      _titleController,
      _descriptionController,
      _fullDateController,
      _timeRangeController,
      _locationController,
      _pointPersonNameController,
      _pointPersonRoleController,
      _pointPersonEmailController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fullDateController.dispose();
    _timeRangeController.dispose();
    _locationController.dispose();
    _pointPersonNameController.dispose();
    _pointPersonRoleController.dispose();
    _pointPersonEmailController.dispose();
    _formUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickEventDate() async {
    final initialDate =
        _tryParseFullDate(_fullDateController.text) ?? _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _navy,
              onPrimary: Colors.white,
              onSurface: _navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _fullDateController.text = _formatFullDate(picked);
      _dateBadge = _formatDateBadge(picked);
    });
  }

  IconData _categoryIcon(String category) {
    final match = _categories.firstWhere(
          (c) => c['label'] == category,
      orElse: () => _categories.first,
    );
    return match['icon'] as IconData;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isSubmitting = true);
    final orgCode = _effectiveOrgCode;
    final orgFullName =
        widget.existingPost?.orgFullName ?? (_orgNames[orgCode] ?? orgCode);
    final computedBadge = _formatDateBadge(_selectedDate);

    final post = CampusPost(
      id: widget.existingPost?.id ?? '',
      orgCode: orgCode,
      orgFullName: orgFullName,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateBadge: computedBadge,
      fullDate: _fullDateController.text.trim(),
      timeRange: _timeRangeController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      pointPersonName: _pointPersonNameController.text.trim(),
      pointPersonRole: _pointPersonRoleController.text.trim(),
      pointPersonEmail: _pointPersonEmailController.text.trim(),
      formUrl: _formUrlController.text.trim(),
      publishedDateLabel:
      _isPublished ? _formatDateBadge(DateTime.now()) : 'DRAFT',
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
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PortalCanvasPainter(),
            ),
          ),
          Container(
            height: 168,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, _navyMid, _navy],
                stops: [0.0, 0.55, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopHeader(isEditing: isEditing, orgCode: orgCode),
                      const SizedBox(height: 20),
                      _buildStepIndicator(),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: KeyedSubtree(
                            key: ValueKey(_currentStep),
                            child: _buildCurrentStepContent(orgCode),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildBottomNavigation(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader({
    required bool isEditing,
    required String orgCode,
  }) {
    return Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CICS HUB',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '  •  STEP ${_currentStep + 1} OF ${_stepLabels.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                isEditing
                    ? 'Edit Organization Post'
                    : 'Create Organization Post',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 13, 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _gold.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OrgLogoAvatar(orgCode: orgCode, size: 26),
              const SizedBox(width: 8),
              Text(
                orgCode,
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_stepLabels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final completed = _currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: completed ? _navy : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final step = index ~/ 2;
          final isActive = _currentStep == step;
          final isCompleted = _currentStep > step;

          return InkWell(
            onTap: step < _currentStep
                ? () => setState(() => _currentStep = step)
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? _navy
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 15, color: _gold)
                      : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _stepLabels[step],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? _navy : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(String orgCode) {
    switch (_currentStep) {
      case 0:
        return _buildDetailsStep();
      case 1:
        return _buildScheduleStep();
      default:
        return _buildReviewStep(orgCode);
    }
  }

  Widget _buildDetailsStep() {
    return _cardShell(
      title: 'What are you announcing?',
      subtitle: 'Start with a clear title, category, and short summary.',
      children: [
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
          maxLines: 5,
          decoration: _inputDecoration(
            'Share key details, eligibility, registration steps, or payment instructions...',
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Description is required'
              : null,
        ),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return _cardShell(
      title: 'When & where is it happening?',
      subtitle: 'Pick the date and add venue or registration details.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Event / Due Date'),
                  TextFormField(
                    controller: _fullDateController,
                    readOnly: true,
                    onTap: _pickEventDate,
                    decoration: _inputDecoration('December 04, 2026').copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_month_rounded,
                        color: _navy,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
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
          ],
        ),
        const SizedBox(height: 18),
        _fieldLabel('Location / Booth'),
        TextFormField(
          controller: _locationController,
          decoration: _inputDecoration('CICS Auditorium • Main Campus'),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Registration / Form URL'),
        TextFormField(
          controller: _formUrlController,
          decoration: _inputDecoration('https://forms.gle/...'),
        ),
      ],
    );
  }

  Widget _buildReviewStep(String orgCode) {
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Post'
        : _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final dateBadge = _dateBadge.trim().isEmpty
        ? _formatDateBadge(_selectedDate)
        : _dateBadge.trim().toUpperCase();

    final contactName = _pointPersonNameController.text.trim().isEmpty
        ? 'No contact name'
        : _pointPersonNameController.text.trim();
    final contactRole = _pointPersonRoleController.text.trim().isEmpty
        ? 'Officer'
        : _pointPersonRoleController.text.trim();
    final contactEmail = _pointPersonEmailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                    colors: [_cardBlueDark, _cardBlueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 12,
                      bottom: -10,
                      child: Icon(
                        _categoryIcon(_selectedCategory),
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedCategory.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
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
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            OrgLogoAvatar(orgCode: orgCode, size: 32),
                            const SizedBox(width: 10),
                            Text(
                              orgCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _previewMetaRow(
                      Icons.location_on_rounded,
                      _locationController.text,
                    ),
                    const SizedBox(height: 6),
                    _previewMetaRow(
                      Icons.calendar_today_rounded,
                      '${_fullDateController.text} • ${_timeRangeController.text}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _cardShell(
          title: 'Ready to publish?',
          subtitle: 'Confirm your point person and visibility below.',
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 18, color: _navy),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$contactName • $contactRole',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                              ),
                            ),
                            if (contactEmail.isNotEmpty)
                              Text(
                                contactEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                              () => _editingPointPerson = !_editingPointPerson,
                        ),
                        child: Text(
                          _editingPointPerson ? 'Done' : 'Edit',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_editingPointPerson) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pointPersonNameController,
                            decoration: _inputDecoration('Contact Name'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _pointPersonRoleController,
                            decoration: _inputDecoration('Officer Role'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pointPersonEmailController,
                      decoration:
                      _inputDecoration('officer@g.batstate-u.edu.ph'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _visibilityOption(
                      selected: _isPublished,
                      title: 'Publish Now',
                      subtitle: 'Live in Discover feed',
                      icon: Icons.public_rounded,
                      onTap: () => setState(() => _isPublished = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _visibilityOption(
                      selected: !_isPublished,
                      title: 'Save Draft',
                      subtitle: 'Officers only',
                      icon: Icons.edit_note_rounded,
                      onTap: () => setState(() => _isPublished = false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final isLastStep = _currentStep == _stepLabels.length - 1;

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : (isLastStep ? _submit : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep && !_isPublished
                    ? const Color(0xFF475569)
                    : _navy,
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
                isLastStep
                    ? (_isPublished
                    ? Icons.rocket_launch_rounded
                    : Icons.save_rounded)
                    : Icons.arrow_forward_rounded,
                color: isLastStep ? _gold : Colors.white,
                size: 19,
              ),
              label: Text(
                _isSubmitting
                    ? 'Saving...'
                    : (isLastStep
                    ? (_isPublished ? 'Publish Post' : 'Save Draft')
                    : 'Continue'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardShell({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _previewMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _cardBlueLight),
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
        padding: const EdgeInsets.all(13),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: selected ? _navy : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
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

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: _navy, width: 1.6),
      ),
    );
  }
}

class _PortalCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 44.0;
    final gridPaint = Paint()
      ..color = const Color(0xFF0F2544).withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final goldRingPaint = Paint()
      ..color = const Color(0xFFE5A93B).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    canvas.drawCircle(
      Offset(20, size.height * 0.88),
      150,
      goldRingPaint,
    );

    final navyRingPaint = Paint()
      ..color = const Color(0xFF0F2544).withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    canvas.drawCircle(
      Offset(size.width - 20, size.height * 0.78),
      190,
      navyRingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}