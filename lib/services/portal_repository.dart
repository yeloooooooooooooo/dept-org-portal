import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campus_post.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

typedef JsonRow = Map<String, dynamic>;
typedef OrgProfileMap = Map<String, JsonRow>;
typedef TaskCountMap = Map<String, int>;

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

  factory UserProfile.fromMap(JsonRow map) {
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

  static const String _defaultWebVapidKey = 'BKrxuV704F_1qe9kA1C5nkUXv-XSdL8gHJNw8CPYAQaBkIGEU26lySfLEvFkwBH3xXWMoXCqtPHHzhB1yrYpGzk';

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

    final profileData = <String, dynamic>{
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
    await syncFcmToken();
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
    await syncFcmToken();
    notifyListeners();
    return _loadedUser!.role;
  }

  /// Requests push permission (where applicable) and saves the current FCM token
  /// to `profiles.fcm_token` for the active user.
Future<void> syncFcmToken({String? webVapidKey}) async {
    final uid = _client.auth.currentUser?.id ?? currentUser.id;
    if (uid.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;
      if (kIsWeb && !await messaging.isSupported()) {
        debugPrint('FCM web messaging not supported in this browser context.');
        return;
      }

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final effectiveVapidKey = webVapidKey ?? _defaultWebVapidKey;
      final token = kIsWeb
          ? await messaging.getToken(vapidKey: effectiveVapidKey)
          : await messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await _client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', uid);
      }
    } catch (e) {
      debugPrint('FCM token sync skipped: $e');
    }
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
    await syncFcmToken();
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

  /// Fetches aggregated student task completion counts keyed by post ID (officers only).
  Future<TaskCountMap> fetchOrgTaskCompletionCounts(String orgCode) async {
    final rows = await _client.rpc(
      'get_org_task_completion_counts',
      params: {'p_org_code': orgCode},
    );

    final TaskCountMap counts = {};
    if (rows is List) {
      for (final row in rows) {
        if (row is Map) {
          final id = row['post_id']?.toString() ?? '';
          final count = (row['completed_count'] as num?)?.toInt() ?? 0;
          if (id.isNotEmpty) {
            counts[id] = count;
          }
        }
      }
    }
    return counts;
  }

  /// Fetches eligible students and their task/payment completion status for a post (officers only).
  Future<List<JsonRow>> fetchPostStudentStatuses({
    required String postId,
    required String orgCode,
  }) async {
    final rows = await _client.rpc(
      'get_post_student_statuses',
      params: {
        'p_post_id': postId,
        'p_org_code': orgCode,
      },
    );

    if (rows is List) {
      return rows
        .whereType()
        .map((r) => JsonRow.from(r))
        .toList();
}
    return const [];
  }

  /// Sends in-app payment/clearance reminders to unpaid students (or a single target student).
  /// Returns the number of reminder notifications sent.
  Future<int> sendPostPaymentReminders({
    required String postId,
    required String orgCode,
    required String postTitle,
    String? targetUserId,
  }) async {
    final res = await _client.rpc(
      'send_post_payment_reminders',
      params: {
        'p_post_id': postId,
        'p_org_code': orgCode,
        'p_post_title': postTitle,
        if (targetUserId != null) 'p_target_user_id': targetUserId,
      },
    );

    if (res is num) return res.toInt();
    return int.tryParse(res?.toString() ?? '0') ?? 0;
  }

  /// Streams in-app notifications for the currently signed-in user (newest first).
  Stream<List<JsonRow>> watchMyNotifications() {
    final uid = _client.auth.currentUser?.id ?? currentUser.id;
    if (uid.isEmpty) {
      return Stream.value(const []);
    }

    return _client
        .from('portal_notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', uid)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows.map((r) => JsonRow.from(r)).toList(),
        );
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    await _client
        .from('portal_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Marks all current user's notifications as read.
  Future<void> markAllNotificationsRead() async {
    final uid = _client.auth.currentUser?.id ?? currentUser.id;
    if (uid.isEmpty) return;

    await _client
        .from('portal_notifications')
        .update({'is_read': true})
        .eq('recipient_id', uid)
        .eq('is_read', false);
  }
}