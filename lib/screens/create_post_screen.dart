import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import 'event_details_screen.dart';

class CreatePostScreen extends StatefulWidget {
  final String orgCode;
  final CampusPost? existingPost;

  const CreatePostScreen({
    super.key,
    this.orgCode = 'JPCS',
    this.existingPost,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _dateController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _formUrlController;

  late String _selectedCategory;
  late bool _publishLive;

  final List<String> _categories = [
    'Events',
    'Educational',
    'Merch',
    'Membership Fee',
  ];

  @override
  void initState() {
    super.initState();
    final post = widget.existingPost;
    _titleController =
        TextEditingController(text: post?.title ?? 'Career-ready workshop');
    _selectedCategory = post?.category ?? 'Events';
    _descController = TextEditingController(
      text: post?.description ??
          'Build a standout CV and practice interview skills with CICS alumni. Open to all BSIT and BSCS students.',
    );
    _dateController =
        TextEditingController(text: post?.fullDate ?? 'December 12, 2026');
    _contactNameController =
        TextEditingController(text: post?.pointPersonName ?? 'Andrea Reyes');
    _contactEmailController = TextEditingController(
        text: post?.pointPersonEmail ?? 'andrea.reyes@cics.edu');
    _formUrlController = TextEditingController(
        text: post?.formUrl ?? 'https://forms.gle/cics-career-ready');
    _publishLive = post?.isPublished ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _formUrlController.dispose();
    super.dispose();
  }

  CampusPost _buildPostObject() {
    return CampusPost(
      id: widget.existingPost?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      orgCode: widget.orgCode,
      orgFullName: widget.orgCode == 'JPCS'
          ? 'Junior Philippine Computer Society'
          : widget.orgCode,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateBadge: '12 DEC',
      fullDate: _dateController.text.trim(),
      timeRange: '1:00 PM - 5:00 PM',
      location: 'CICS Auditorium',
      description: _descController.text.trim(),
      pointPersonName: _contactNameController.text.trim(),
      pointPersonRole: '${widget.orgCode} Officer',
      pointPersonEmail: _contactEmailController.text.trim(),
      formUrl: _formUrlController.text.trim(),
      publishedDateLabel: _publishLive ? 'Nov 27, 2026' : 'Draft',
      isPublished: _publishLive,
    );
  }

  void _savePost() {
    if (!_formKey.currentState!.validate()) return;

    final newPost = _buildPostObject();

    if (widget.existingPost != null) {
      final index = sampleCampusPosts
          .indexWhere((item) => item.id == widget.existingPost!.id);
      if (index != -1) {
        sampleCampusPosts[index] = newPost;
      }
    } else {
      sampleCampusPosts.insert(0, newPost);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: Text(
          widget.existingPost == null ? 'Create post' : 'Edit post',
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: navy),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.orgCode,
                  style: const TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Create a new organization announcement.',
              style: TextStyle(fontSize: 14, color: slateSub),
            ),
            const SizedBox(height: 16),

            // Form Card
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
                  _label('Post title'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDeco('Enter announcement title'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: _inputDeco('Select category'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),

                  _label('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: _inputDeco('Write event or announcement details'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Event date'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _dateController,
                    decoration: _inputDeco('e.g. December 12, 2026'),
                  ),
                  const SizedBox(height: 16),

                  _label('Point person contact info'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contactNameController,
                    decoration: _inputDeco('Coordinator full name'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDeco('coordinator@cics.edu'),
                  ),
                  const SizedBox(height: 16),

                  _label('External Google Form URL'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _formUrlController,
                    keyboardType: TextInputType.url,
                    decoration: _inputDeco('https://forms.gle/...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Publish Live Switch Card
            Container(
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
                        const Text(
                          'Publish Live',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _publishLive
                              ? 'On — visible to all CICS students immediately.'
                              : 'Off — save as Draft. Only officers can see it.',
                          style: const TextStyle(fontSize: 12, color: slateSub),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _publishLive,
                    activeThumbColor: navy,
                    onChanged: (val) => setState(() => _publishLive = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Save / Publish Button
            FilledButton(
              onPressed: _savePost,
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _publishLive ? 'Publish Announcement' : 'Save draft',
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Switch on Publish Live when your post is ready.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: slateSub),
            ),
            const SizedBox(height: 12),

            // Preview Button
            OutlinedButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EventDetailsScreen(post: _buildPostObject()),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text(
                'Preview',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: cardBorder),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F2547),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F2547), width: 1.5),
      ),
    );
  }
}