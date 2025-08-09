import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _db.collection('users').doc(uid);

  Stream<UserProfile?> watchUserProfile(String uid) => _userDoc(uid).snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        final data = snap.data()!;
        return UserProfile(
          uid: uid,
          isSubscribed: data['isSubscribed'] ?? false,
          subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
          lastFreeAccessDate: (data['lastFreeAccessDate'] as Timestamp?)?.toDate(),
        );
      });

  Future<UserProfile> getUserProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data() ?? {};
    return UserProfile(
      uid: uid,
      isSubscribed: data['isSubscribed'] ?? false,
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
      lastFreeAccessDate: (data['lastFreeAccessDate'] as Timestamp?)?.toDate(),
    );
  }

  Future<void> setSubscribed(String uid, {required bool subscribed, DateTime? expiry}) async {
    await _userDoc(uid).set({
      'isSubscribed': subscribed,
      'subscriptionExpiry': expiry,
    }, SetOptions(merge: true));
  }

  Future<void> setLastFreeAccessDate(String uid, DateTime date) async {
    await _userDoc(uid).set({
      'lastFreeAccessDate': date,
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchServers() async {
    final query = await _db.collection('servers').where('enabled', isEqualTo: true).get();
    return query.docs.map((d) => d.data()).toList();
  }

  Future<void> logPayment(String uid, Map<String, dynamic> payload) async {
    await _db.collection('users').doc(uid).collection('payments').add(payload);
  }
}