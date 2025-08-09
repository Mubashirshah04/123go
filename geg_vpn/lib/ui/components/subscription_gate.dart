import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class SubscriptionGate extends ConsumerWidget {
  final Widget child;
  const SubscriptionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return child; // not logged in => show ads
    return FutureBuilder(
      future: ref.read(firestoreServiceProvider).getUserProfile(user.uid),
      builder: (context, snap) {
        final isSubscribed = snap.data?.isSubscribed == true;
        if (isSubscribed) return const SizedBox.shrink();
        return child;
      },
    );
  }
}