import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/portal_repository.dart';

class OrgMemberDirectoryCard extends StatefulWidget {
  final String orgCode;

  const OrgMemberDirectoryCard({
    super.key,
    required this.orgCode,
  });

  @override
  State<OrgMemberDirectoryCard> createState() => _OrgMemberDirectoryCardState();
}

class _OrgMemberDirectoryCardState extends State<OrgMemberDirectoryCard> {
  static const int _previewLimit = 5;

  late Future<List<UserProfile>> _membersFuture;
  String _search = '';
  String _yearFilter = 'All';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _membersFuture =
        PortalRepository.instance.fetchOrgStudentMembers(widget.orgCode);
  }

  String _formatEmail(UserProfile student) {
    if (student.email.trim().isNotEmpty) return student.email.trim();
    final cleaned =
    student.studentNumber.trim().replaceFirst(RegExp(r'^20'), '');
    return '$cleaned@g.batstate-u.edu.ph';
  }

  List<UserProfile> _applyFilters(
      List<UserProfile> allMembers, {
        required String search,
        required String yearFilter,
        required bool sortAscending,
      }) {
    final q = search.trim().toLowerCase();
    final list = allMembers.where((m) {
      final matchesYear = yearFilter == 'All' || m.yearLevel == yearFilter;
      final matchesSearch = q.isEmpty ||
          m.fullName.toLowerCase().contains(q) ||
          m.studentNumber.toLowerCase().contains(q) ||
          _formatEmail(m).toLowerCase().contains(q);
      return matchesYear && matchesSearch;
    }).toList();

    list.sort((a, b) {
      final cmp = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
      return sortAscending ? cmp : -cmp;
    });
    return list;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openFullRosterModal(List<UserProfile> allMembers) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    String modalSearch = _search;
    String modalYear = _yearFilter;
    bool modalAsc = _sortAscending;
    final modalSearchController = TextEditingController(text: modalSearch);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _applyFilters(
              allMembers,
              search: modalSearch,
              yearFilter: modalYear,
              sortAscending: modalAsc,
            );

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 680,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.orgCode} Full Member Roster',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                ),
                                Text(
                                  '${filtered.length} of ${allMembers.length} approved members',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: slateSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: filtered.isEmpty
                                ? null
                                : () {
                              final emails = filtered
                                  .map(_formatEmail)
                                  .where((e) => e.isNotEmpty)
                                  .join(', ');
                              _copyToClipboard(
                                emails,
                                '${filtered.length} member emails',
                              );
                            },
                            icon: const Icon(Icons.copy_all_rounded, size: 16),
                            label: const Text(
                              'Copy Emails',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: navy,
                              side: const BorderSide(color: cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded,
                                color: slateSub),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: cardBorder),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: modalSearchController,
                              onChanged: (v) =>
                                  setModalState(() => modalSearch = v),
                              style: const TextStyle(fontSize: 13, color: navy),
                              decoration: InputDecoration(
                                hintText: 'Search name, SR-Code, or email...',
                                hintStyle: const TextStyle(
                                    fontSize: 12.5, color: slateSub),
                                prefixIcon: const Icon(Icons.search,
                                    size: 19, color: slateSub),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: cardBorder),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () =>
                                setModalState(() => modalAsc = !modalAsc),
                            tooltip: modalAsc ? 'Sort Z–A' : 'Sort A–Z',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF8FAFC),
                              side: const BorderSide(color: cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              modalAsc
                                  ? Icons.sort_by_alpha_rounded
                                  : Icons.sort_rounded,
                              color: navy,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            '1st Year',
                            '2nd Year',
                            '3rd Year',
                            '4th Year'
                          ].map((yr) {
                            final selected = modalYear == yr;
                            final count = yr == 'All'
                                ? allMembers.length
                                : allMembers
                                .where((m) => m.yearLevel == yr)
                                .length;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('$yr ($count)'),
                                selected: selected,
                                onSelected: (_) =>
                                    setModalState(() => modalYear = yr),
                                selectedColor: navy,
                                backgroundColor: const Color(0xFFF8FAFC),
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? gold : navy,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                          child: Text(
                            'No matching student members found.',
                            style:
                            TextStyle(fontSize: 13, color: slateSub),
                          ),
                        )
                            : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 14, color: cardBorder),
                          itemBuilder: (context, index) =>
                              _buildMemberTile(filtered[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(modalSearchController.dispose);
  }

  Widget _buildMemberTile(UserProfile student) {
    const navy = Color(0xFF0F2547);
    const slateSub = Color(0xFF64748B);
    final email = _formatEmail(student);
    final srCode =
    student.studentNumber.trim().replaceFirst(RegExp(r'^20'), '');

    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: navy.withValues(alpha: 0.08),
          child: Text(
            student.fullName.isNotEmpty
                ? student.fullName[0].toUpperCase()
                : 'S',
            style: const TextStyle(fontWeight: FontWeight.w800, color: navy),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$srCode • ${student.program} • ${student.yearLevel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: slateSub,
                ),
              ),
            ],
          ),
        ),
        if (MediaQuery.of(context).size.width >= 600) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: slateSub,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Member',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF166534),
            ),
          ),
        ),
        IconButton(
          onPressed: () =>
              _copyToClipboard(email, '${student.fullName}\'s email'),
          tooltip: 'Copy email ($email)',
          icon:
          const Icon(Icons.content_copy_rounded, size: 16, color: slateSub),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

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
      child: FutureBuilder<List<UserProfile>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          final allMembers = snapshot.data ?? const <UserProfile>[];
          final filtered = _applyFilters(
            allMembers,
            search: _search,
            yearFilter: _yearFilter,
            sortAscending: _sortAscending,
          );

          final isSearching = _search.trim().isNotEmpty;
          final visibleMembers = isSearching
              ? filtered
              : filtered.take(_previewLimit).toList();
          final hasMore = !isSearching && filtered.length > _previewLimit;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.orgCode} Student Roster',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${allMembers.length} ${allMembers.length == 1 ? 'member' : 'members'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (allMembers.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openFullRosterModal(allMembers),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: const BorderSide(color: cardBorder),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_full_rounded, size: 14),
                      label: const Text(
                        'Full Roster',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(fontSize: 13, color: navy),
                      decoration: InputDecoration(
                        hintText: 'Search name, SR-Code, or email...',
                        hintStyle:
                        const TextStyle(fontSize: 12.5, color: slateSub),
                        prefixIcon: const Icon(Icons.search,
                            size: 19, color: slateSub),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: cardBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        setState(() => _sortAscending = !_sortAscending),
                    tooltip: _sortAscending ? 'Sort Z–A' : 'Sort A–Z',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: const BorderSide(color: cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      _sortAscending
                          ? Icons.sort_by_alpha_rounded
                          : Icons.sort_rounded,
                      size: 20,
                      color: navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    '1st Year',
                    '2nd Year',
                    '3rd Year',
                    '4th Year'
                  ].map((yr) {
                    final selected = _yearFilter == yr;
                    final count = yr == 'All'
                        ? allMembers.length
                        : allMembers.where((m) => m.yearLevel == yr).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$yr ($count)'),
                        selected: selected,
                        onSelected: (_) => setState(() => _yearFilter = yr),
                        selectedColor: navy,
                        backgroundColor: const Color(0xFFF8FAFC),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : navy,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: navy)),
                )
              else if (visibleMembers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No matching student members found.',
                      style: TextStyle(fontSize: 12.5, color: slateSub),
                    ),
                  ),
                )
              else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleMembers.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 16, color: cardBorder),
                    itemBuilder: (context, index) =>
                        _buildMemberTile(visibleMembers[index]),
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _openFullRosterModal(allMembers),
                      icon: const Icon(Icons.groups_rounded, size: 17),
                      label: Text(
                        'View All ${filtered.length} Members',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: const BorderSide(color: cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
            ],
          );
        },
      ),
    );
  }
}