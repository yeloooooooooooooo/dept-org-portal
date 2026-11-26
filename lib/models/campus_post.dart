class CampusPost {
  final String id;
  final String orgCode;
  final String orgFullName;
  final String title;
  final String category;
  final String dateBadge;
  final String fullDate;
  final String timeRange;
  final String location;
  final String description;
  final String pointPersonName;
  final String pointPersonRole;
  final String pointPersonEmail;
  final String formUrl;
  final String publishedDateLabel;
  bool isDone;
  bool isPublished;
  bool isArchived;

  CampusPost({
    required this.id,
    required this.orgCode,
    required this.orgFullName,
    required this.title,
    required this.category,
    this.dateBadge = '04 DEC',
    required this.fullDate,
    required this.timeRange,
    required this.location,
    required this.description,
    required this.pointPersonName,
    required this.pointPersonRole,
    required this.pointPersonEmail,
    this.formUrl = 'https://forms.gle/example',
    this.publishedDateLabel = 'NOV 27',
    this.isDone = false,
    this.isPublished = true,
    this.isArchived = false,
  });

  // Converts model into a Firestore-ready Map
  Map<String, dynamic> toMap() {
    return {
      'orgCode': orgCode,
      'orgFullName': orgFullName,
      'title': title,
      'category': category,
      'dateBadge': dateBadge,
      'fullDate': fullDate,
      'timeRange': timeRange,
      'location': location,
      'description': description,
      'pointPersonName': pointPersonName,
      'pointPersonRole': pointPersonRole,
      'pointPersonEmail': pointPersonEmail,
      'formUrl': formUrl,
      'publishedDateLabel': publishedDateLabel,
      'isPublished': isPublished,
    };
  }

  // Rebuilds model from a Firestore document snapshot
  factory CampusPost.fromMap(
      String id,
      Map<String, dynamic> map, {
        List<String> completedIds = const [],
      }) {
    return CampusPost(
      id: id,
      orgCode: (map['orgCode'] ?? 'JPCS').toString(),
      orgFullName: (map['orgFullName'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      category: (map['category'] ?? 'Events').toString(),
      dateBadge: (map['dateBadge'] ?? '04 DEC').toString(),
      fullDate: (map['fullDate'] ?? '').toString(),
      timeRange: (map['timeRange'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      pointPersonName: (map['pointPersonName'] ?? '').toString(),
      pointPersonRole: (map['pointPersonRole'] ?? '').toString(),
      pointPersonEmail: (map['pointPersonEmail'] ?? '').toString(),
      formUrl: (map['formUrl'] ?? 'https://forms.gle/example').toString(),
      publishedDateLabel: (map['publishedDateLabel'] ?? 'NOV 27').toString(),
      isPublished: (map['isPublished'] as bool?) ?? true,
      isDone: completedIds.contains(id),
      isArchived: (map['isArchived'] as bool?) ?? false,
    );
  }
}

// Temporary local fallback data (kept empty-safe for backend swap)
final List<CampusPost> sampleCampusPosts = [
  CampusPost(
    id: 'post_1',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'CICS Tech Summit 2026',
    category: 'Events',
    dateBadge: '04 DEC',
    fullDate: 'December 04, 2026',
    timeRange: '9:00 AM - 4:00 PM',
    location: 'CICS Auditorium • Main campus',
    description:
    'Connect with student innovators, industry speakers, and project teams across the department. Open to all CICS students.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Event coordinator',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    publishedDateLabel: 'NOV 20',
  ),
  CampusPost(
    id: 'post_2',
    orgCode: 'CICS SC',
    orgFullName: 'CICS Student Council',
    title: 'Official Department Shirt Pre-order',
    category: 'Merch',
    dateBadge: '29 NOV',
    fullDate: 'November 29, 2026',
    timeRange: 'Until 5:00 PM',
    location: 'CICS Student Lounge • Ground Floor',
    description:
    'Reserve your official Navy & Gold CICS Department Shirt for SY 2026–2027. Sizes XS to 3XL available.',
    pointPersonName: 'Marco Santos',
    pointPersonRole: 'CICS SC Finance Officer',
    pointPersonEmail: 'marco.santos@cics.edu',
    publishedDateLabel: 'NOV 18',
  ),
  CampusPost(
    id: 'post_3',
    orgCode: 'ACCESS',
    orgFullName: 'Association of Committed Computer Science Students',
    title: 'ACCESS Annual Membership Fee',
    category: 'Membership Fee',
    dateBadge: '01 DEC',
    fullDate: 'December 01, 2026',
    timeRange: '8:00 AM - 5:00 PM',
    location: 'CICS Building, Room 204',
    description:
    'Settle your annual ACCESS membership dues (₱120.00) to unlock workshop certificates and voting rights.',
    pointPersonName: 'Claire Mendoza',
    pointPersonRole: 'ACCESS Treasurer',
    pointPersonEmail: 'claire.mendoza@cics.edu',
    publishedDateLabel: 'NOV 15',
  ),
  CampusPost(
    id: 'post_4',
    orgCode: 'INTESS',
    orgFullName: 'Information Technology Society of Students',
    title: 'Git & GitHub Bootcamp for Beginners',
    category: 'Educational',
    dateBadge: '08 DEC',
    fullDate: 'December 08, 2026',
    timeRange: '1:00 PM - 4:30 PM',
    location: 'CICS Computer Lab 3',
    description:
    'Hands-on session covering branching, pull requests, and collaborative workflows. Bring your laptop.',
    pointPersonName: 'Liam Cruz',
    pointPersonRole: 'INTESS Technical Head',
    pointPersonEmail: 'liam.cruz@cics.edu',
    publishedDateLabel: 'NOV 22',
  ),
  CampusPost(
    id: 'post_5',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'Mobile App Hackathon Mechanics (Draft)',
    category: 'Events',
    dateBadge: '15 JAN',
    fullDate: 'January 15, 2027',
    timeRange: '8:00 AM - 6:00 PM',
    location: 'CICS Innovation Hub',
    description:
    'Draft mechanics and judging rubrics for the upcoming CICS Flutter & Mobile App Hackathon.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Event coordinator',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    publishedDateLabel: 'DRAFT',
    isPublished: false,
  ),
];