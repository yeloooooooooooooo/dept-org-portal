import 'dart:async';
import '../models/campus_post.dart';
import '../models/user_profile.dart';

class PortalRepository {
  PortalRepository._();
  static final PortalRepository instance = PortalRepository._();

  final _postsController = StreamController<List<CampusPost>>.broadcast();

  UserProfile currentUser = const UserProfile(
    uid: 'local_user_1',
    fullName: 'CICS Student',
    email: 'student@cics.edu',
    studentNumber: '2024-00142',
    program: 'BSIT',
    yearLevel: '3rd Year',
    role: 'student',
  );

  Stream<List<CampusPost>> watchPosts() async* {
    yield List<CampusPost>.from(sampleCampusPosts);
    yield* _postsController.stream;
  }

  void _notifyPostsChanged() {
    _postsController.add(List<CampusPost>.from(sampleCampusPosts));
  }

  Future<void> savePost(CampusPost post, {bool isNew = false}) async {
    if (isNew) {
      sampleCampusPosts.insert(0, post);
    } else {
      final index = sampleCampusPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        sampleCampusPosts[index] = post;
      }
    }
    _notifyPostsChanged();
  }

  Future<void> deletePost(String postId) async {
    sampleCampusPosts.removeWhere((p) => p.id == postId);
    _notifyPostsChanged();
  }

  // Archive or restore a finished event
  Future<void> toggleArchivePost(CampusPost post) async {
    post.isArchived = !post.isArchived;
    // TODO(Firebase): await FirebaseFirestore.instance.collection('posts').doc(post.id).update({'isArchived': post.isArchived});
    _notifyPostsChanged();
  }

  Future<void> togglePostDone(CampusPost post) async {
    post.isDone = !post.isDone;
    _notifyPostsChanged();
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String studentNumber,
    required String program,
    required String yearLevel,
  }) async {
    currentUser = UserProfile(
      uid: currentUser.uid,
      fullName: fullName,
      email: currentUser.email,
      studentNumber: studentNumber,
      program: program,
      yearLevel: yearLevel,
      role: currentUser.role,
      orgCode: currentUser.orgCode,
      completedPostIds: currentUser.completedPostIds,
    );
  }
}