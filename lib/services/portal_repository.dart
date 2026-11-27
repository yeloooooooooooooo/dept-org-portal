import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campus_post.dart';

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

  final Set<String> _completedPostIds = {};
  Set<String> get completedPostIds => Set.unmodifiable(_completedPostIds);

  bool isPostDone(String postId) => _completedPostIds.contains(postId);

  Future<void> togglePostDone(CampusPost post) async {
    post.isDone = !post.isDone;
    if (post.isDone) {
      _completedPostIds.add(post.id);
    } else {
      _completedPostIds.remove(post.id);
    }
    notifyListeners();
  }

  /// Signs in with Supabase Auth and loads the user's profile + role from `profiles`.
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

  /// Real-time stream of all campus posts ordered newest first.
  Stream<List<CampusPost>> watchPosts() {
    return _client
        .from('campus_posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
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
}