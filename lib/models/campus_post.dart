class CampusPost {
  final String id;
  final String orgCode;
  final String orgFullName;
  final String title;
  final String category; // Events, Merch, Membership Fee, Educational
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
  final bool isFeatured;
  bool isPublished;
  bool isDone;

  CampusPost({
    required this.id,
    required this.orgCode,
    required this.orgFullName,
    required this.title,
    required this.category,
    required this.dateBadge,
    required this.fullDate,
    required this.timeRange,
    required this.location,
    required this.description,
    required this.pointPersonName,
    required this.pointPersonRole,
    required this.pointPersonEmail,
    required this.formUrl,
    this.publishedDateLabel = 'Nov 27, 2026',
    this.isFeatured = false,
    this.isPublished = true,
    this.isDone = false,
  });
}

// Sample CICS Portal data matching your mockups
final List<CampusPost> sampleCampusPosts = [
  CampusPost(
    id: '1',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'CICS Tech Summit 2026',
    category: 'Events',
    dateBadge: '04 DEC',
    fullDate: 'December 04, 2026',
    timeRange: '9:00 AM - 4:00 PM',
    location: 'CICS Auditorium • Main campus',
    description:
    'Connect with student innovators and industry mentors for talks, demos, and hands-on learning. Bring your curiosity. Build what comes next.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Event coordinator',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Nov 26, 2026',
    isFeatured: true,
    isPublished: true,
  ),
  CampusPost(
    id: '2',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'Git & GitHub essentials',
    category: 'Educational',
    dateBadge: '10 DEC',
    fullDate: 'December 10, 2026',
    timeRange: '1:00 PM - 4:00 PM',
    location: 'Computer Lab 3',
    description:
    'Turn curiosity into skills through hands-on version control, branching, and pull request workflows for student developers.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Workshop Lead',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Nov 24, 2026',
    isPublished: true,
  ),
  CampusPost(
    id: '3',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'JPCS lanyard pre-order',
    category: 'Merch',
    dateBadge: '15 DEC',
    fullDate: 'Orders close Dec 15, 2026',
    timeRange: 'Online Pre-Order',
    location: 'CICS Student Lounge',
    description:
    'Official JPCS navy & gold woven lanyard pre-order. Reserve yours through the form before the cutoff.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Business Manager',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Nov 22, 2026',
    isPublished: true,
  ),
  CampusPost(
    id: '4',
    orgCode: 'JPCS',
    orgFullName: 'Junior Philippine Computer Society',
    title: 'Freshmen coding bootcamp',
    category: 'Educational',
    dateBadge: '18 DEC',
    fullDate: 'December 18, 2026',
    timeRange: '9:00 AM - 12:00 PM',
    location: 'CICS Lab 1',
    description:
    'Draft announcement for upcoming introductory programming clinic for first-year CICS students.',
    pointPersonName: 'Andrea Reyes',
    pointPersonRole: 'JPCS Event coordinator',
    pointPersonEmail: 'andrea.reyes@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Draft',
    isPublished: false,
  ),
  CampusPost(
    id: '5',
    orgCode: 'CICS SC',
    orgFullName: 'Student Council',
    title: 'CICS organization shirt',
    category: 'Merch',
    dateBadge: '08 DEC',
    fullDate: 'Orders close Dec 08, 2026',
    timeRange: 'Online Pre-Order',
    location: 'CICS Student Lounge',
    description:
    'Official CICS department shirt pre-order for SY 2026–2027. Submit your size and proof of payment via the official order form.',
    pointPersonName: 'Marco Santos',
    pointPersonRole: 'CICS SC Business Manager',
    pointPersonEmail: 'marco.santos@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Nov 25, 2026',
    isPublished: true,
  ),
  CampusPost(
    id: '6',
    orgCode: 'ACCESS',
    orgFullName: 'ACCESS Organization',
    title: 'Annual membership fee',
    category: 'Membership Fee',
    dateBadge: '01 DEC',
    fullDate: 'Due Dec 01, 2026',
    timeRange: '8:00 AM - 5:00 PM',
    location: 'CICS Building Room 204',
    description:
    'Settle your 2026–2027 ACCESS membership dues to unlock workshop passes, voting rights, and org merchandise discounts.',
    pointPersonName: 'Claire Mendoza',
    pointPersonRole: 'ACCESS Finance Officer',
    pointPersonEmail: 'claire.mendoza@cics.edu',
    formUrl: 'https://forms.google.com',
    publishedDateLabel: 'Nov 20, 2026',
    isPublished: true,
  ),
];