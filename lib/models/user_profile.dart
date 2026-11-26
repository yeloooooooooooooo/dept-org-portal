class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String studentNumber;
  final String program;
  final String yearLevel;
  final String role; // 'student' or 'officer'
  final String orgCode;
  final List<String> completedPostIds;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.studentNumber,
    required this.program,
    required this.yearLevel,
    required this.role,
    this.orgCode = 'JPCS',
    this.completedPostIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'studentNumber': studentNumber,
      'program': program,
      'yearLevel': yearLevel,
      'role': role,
      'orgCode': orgCode,
      'completedPostIds': completedPostIds,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      fullName: (map['fullName'] ?? 'CICS Student').toString(),
      email: (map['email'] ?? 'student@cics.edu').toString(),
      studentNumber: (map['studentNumber'] ?? '2024-00142').toString(),
      program: (map['program'] ?? 'BSIT').toString(),
      yearLevel: (map['yearLevel'] ?? '3rd Year').toString(),
      role: (map['role'] ?? 'student').toString(),
      orgCode: (map['orgCode'] ?? 'JPCS').toString(),
      completedPostIds: List<String>.from(map['completedPostIds'] ?? []),
    );
  }
}