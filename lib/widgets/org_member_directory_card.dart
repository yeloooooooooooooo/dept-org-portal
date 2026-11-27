import 'package:flutter/material.dart';
import '../services/portal_repository.dart';

class OrgMemberDirectoryCard extends StatefulWidget {
  final String orgCode;
  const OrgMemberDirectoryCard({super.key, required this.orgCode});

  @override
  State<OrgMemberDirectoryCard> createState() => _OrgMemberDirectoryCardState();
}

class _OrgMemberDirectoryCardState extends State<OrgMemberDirectoryCard> {
  late Future<List<UserProfile>> _membersFuture;
  String _search = '';
  String _yearFilter = 'All';

  @override
  void initState() {
    super.initState();
    _membersFuture = PortalRepository.instance.fetchOrgStudentMembers(widget.orgCode);
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);
    const slateSub = Color(0xFF64748B);
    const cardBorder = Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder),
      ),
      child: FutureBuilder<List<UserProfile>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          final allMembers = snapshot.data ?? const <UserProfile>[];
          final filtered = allMembers.where((m) {
            final matchesYear = _yearFilter == 'All' || m.yearLevel == _yearFilter;
            final q = _search.trim().toLowerCase();
            final matchesSearch = q.isEmpty ||
                m.fullName.toLowerCase().contains(q) ||
                m.studentNumber.toLowerCase().contains(q) ||
                m.email.toLowerCase().contains(q);
            return matchesYear && matchesSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.orgCode} Student Roster',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filtered.length} ${filtered.length == 1 ? 'member' : 'members'}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(fontSize: 13, color: navy),
                decoration: InputDecoration(
                  hintText: 'Search name, SR-Code, or email...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: slateSub),
                  prefixIcon: const Icon(Icons.search, size: 19, color: slateSub),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'].map((yr) {
                    final selected = _yearFilter == yr;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(yr),
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
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No matching student members found.',
                      style: TextStyle(fontSize: 12.5, color: slateSub),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 16, color: cardBorder),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Text(
                            student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
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
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${student.studentNumber} • ${student.program} • ${student.yearLevel}',
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
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}