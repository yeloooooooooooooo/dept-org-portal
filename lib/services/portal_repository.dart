import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campus_post.dart';

typedef OrgProfileMap = Map<String, Map<String, dynamic>>;

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String studentNumber;
  final String program;
  final String yearLevel;
  final String role; // 'student' or 'officer'
  final String orgCode;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentNumber,
    required this.program,
    required this.yearLevel,
    required this.role,
    required this.orgCode,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'CICS Student',
      studentNumber: map['student_number'] as String? ?? '',
      program: map['program'] as String? ?? 'BSIT',
      yearLevel: map['year_level'] as String? ?? '1st Year',
      role: map['role'] as String? ?? 'student',
      orgCode: map['org_code'] as String? ?? 'CICS SC',
    );
  }
}

class PortalRepository extends ChangeNotifier {
  PortalRepository._();
  static final PortalRepository instance = PortalRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  UserProfile? _loadedUser;

  UserProfile get currentUser =>
      _loadedUser ??
      const UserProfile(
        id: '',
        email: '',
        fullName: 'CICS Innovator',
        studentNumber: '',
        program: 'BSIT',
        yearLevel: '1st Year',
        role: 'student',
        orgCode: 'CICS SC',
      );

  bool get isLoggedIn => _loadedUser != null;

  /// Returns the organization codes relevant to the current user's program.
  /// Officers see all 4 orgs; BSIT excludes ACCESS; BSCS excludes INTESS.
  List<String> get allowedOrgCodes {
    final user = currentUser;
    if (user.role == 'officer') {
      return const ['JPCS', 'ACCESS', 'INTESS', 'CICS SC'];
    }
    final program = user.program.toUpperCase();
    if (program == 'BSIT') {
      return const ['JPCS', 'INTESS', 'CICS SC'];
    }
    if (program == 'BSCS') {
      return const ['JPCS', 'ACCESS', 'CICS SC'];
    }
    return const ['JPCS', 'ACCESS', 'INTESS', 'CICS SC'];
  }

  bool isOrgAllowedForCurrentUser(String orgCode) =>
      allowedOrgCodes.contains(orgCode);

  final Set<String> _completedPostIds = {};
  Set<String> get completedPostIds => Set.unmodifiable(_completedPostIds);

  bool isPostDone(String postId) => _completedPostIds.contains(postId);

  /// Loads completed post IDs for the current user from `student_tasks`.
  Future<void> _loadCompletedTasks(String uid) async {
    final rows = await _client
        .from('student_tasks')
        .select('post_id')
        .eq('user_id', uid)
        .eq('is_done', true);

    _completedPostIds
      ..clear()
      ..addAll(rows.map((r) => r['post_id'].toString()));
  }

  /// Toggles task completion locally AND upserts into `student_tasks` in Supabase.
  Future<void> togglePostDone(CampusPost post) async {
    post.isDone = !post.isDone;
    if (post.isDone) {
      _completedPostIds.add(post.id);
    } else {
      _completedPostIds.remove(post.id);
    }
    notifyListeners();

    final uid = _client.auth.currentUser?.id;
    if (uid != null) {
      await _client.from('student_tasks').upsert({
        'user_id': uid,
        'post_id': post.id,
        'is_done': post.isDone,
      });
    }
  }

  /// Registers a new student account in Supabase Auth + inserts their `profiles` row.
  Future<String> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required String program,
    required String yearLevel,
  }) async {
    final authRes = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final uid = authRes.user?.id;
    if (uid == null) {
      throw Exception('Sign up failed: no user ID returned.');
    }

    final profileData = {
      'id': uid,
      'email': email,
      'full_name': fullName,
      'student_number': studentNumber,
      'program': program,
      'year_level': yearLevel,
      'role': 'student',
      'org_code': 'CICS SC',
    };

    await _client.from('profiles').upsert(profileData);
    _loadedUser = UserProfile.fromMap(profileData);
    _completedPostIds.clear();
    notifyListeners();
    return _loadedUser!.role;
  }

  /// Signs in with Supabase Auth and loads the user's profile + tasks.
  Future<String> signInAndLoadProfile({
    required String email,
    required String password,
  }) async {
    final authRes = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final uid = authRes.user?.id;
    if (uid == null) {
      throw Exception('Authentication succeeded, but no user ID was returned.');
    }

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();

    _loadedUser = UserProfile.fromMap(data);
    await _loadCompletedTasks(uid);
    notifyListeners();
    return _loadedUser!.role;
  }

  /// Restores the profile if a Supabase session is already active.
  Future<String?> restoreSessionProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;
    _loadedUser = UserProfile.fromMap(data);
    await _loadCompletedTasks(uid);
    notifyListeners();
    return _loadedUser!.role;
  }

  /// Signs out of Supabase Auth and clears local state.
  Future<void> signOut() async {
    await _client.auth.signOut();
    _loadedUser = null;
    _completedPostIds.clear();
    notifyListeners();
  }

  /// Sends a password reset email via Supabase Auth.
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  /// Real-time stream of all campus posts.
  Stream<List<CampusPost>> watchPosts() {
    return _client
        .from('campus_posts')
        .stream(primaryKey: ['id'])
        .map(
          (rows) => rows
              .map(
                (row) => CampusPost.fromMap(
                  row['id'].toString(),
                  row,
                  completedIds: _completedPostIds.toList(),
                ),
              )
              .toList(),
        );
  }

  /// Creates a new post or updates an existing post in Supabase.
  Future<void> savePost(CampusPost post, {bool isNew = true}) async {
    final uid = _client.auth.currentUser?.id;

    final payload = <String, dynamic>{
      ...post.toMap(),
      'isArchived': post.isArchived,
      if (isNew && uid != null) 'created_by': uid,
    };

    if (isNew) {
      await _client.from('campus_posts').insert(payload);
    } else {
      await _client.from('campus_posts').update(payload).eq('id', post.id);
    }
  }

  /// Toggles archived status on a post in Supabase.
  Future<void> toggleArchivePost(CampusPost post) async {
    await _client
        .from('campus_posts')
        .update({'isArchived': !post.isArchived})
        .eq('id', post.id);
  }

  /// Deletes a post by ID from Supabase.
  Future<void> deletePost(String postId) async {
    await _client.from('campus_posts').delete().eq('id', postId);
  }

  /// Real-time stream of organization profiles keyed by orgCode.
  Stream<OrgProfileMap> watchOrgProfiles() {
    return _client
        .from('org_profiles')
        .stream(primaryKey: ['org_code'])
        .map((rows) {
      final OrgProfileMap result = {};
      for (final row in rows) {
        final code = row['org_code']?.toString() ?? '';
        if (code.isNotEmpty) {
          result[code] = row;
        }
      }
      return result;
    });
  }

/// Updates an organization's editable profile fields in Supabase.
  Future<void> updateOrgProfile({
    required String orgCode,
    required String motto,
    required String about,
    required String adviser,
    required String officeLocation,
    List<dynamic>? officers,
  }) async {
    await _client.from('org_profiles').update({
      'motto': motto,
      'about': about,
      'adviser': adviser,
      'office_location': officeLocation,
      if (officers != null) 'officers': officers,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('org_code', orgCode);
  }

  /// Fetches registered student members within the officer's organizational scope.
  /// ACCESS -> BSCS; INTESS -> BSIT; JPCS / CICS SC -> all CICS students.
  Future<List<UserProfile>> fetchOrgStudentMembers(String orgCode) async {
    var query = _client.from('profiles').select().eq('role', 'student');

    final code = orgCode.toUpperCase();
    if (code == 'ACCESS') {
      query = query.eq('program', 'BSCS');
    } else if (code == 'INTESS') {
      query = query.eq('program', 'BSIT');
    }

    final rows = await query.order('full_name', ascending: true);
    return rows.map((r) => UserProfile.fromMap(r)).toList();
  }
  
}