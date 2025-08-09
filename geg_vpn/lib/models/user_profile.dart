class UserProfile {
  final String uid;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final DateTime? lastFreeAccessDate;

  const UserProfile({
    required this.uid,
    required this.isSubscribed,
    this.subscriptionExpiry,
    this.lastFreeAccessDate,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      isSubscribed: (data['isSubscribed'] ?? false) as bool,
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
      lastFreeAccessDate: (data['lastFreeAccessDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'isSubscribed': isSubscribed,
        'subscriptionExpiry': subscriptionExpiry,
        'lastFreeAccessDate': lastFreeAccessDate,
      };
}

// Firestore Timestamp shim for strong mode without importing Firestore here
class Timestamp {
  final DateTime _dateTime;
  Timestamp.fromDate(this._dateTime);
  DateTime toDate() => _dateTime;
}