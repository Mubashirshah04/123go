import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/providers.dart';
import 'ads_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'vpn_service.dart';

const String kEndFreeAccessTask = 'end_free_access_task';

class FreeAccessService {
  final Reader _read;
  FreeAccessService(this._read);

  Future<void> initBackground() async {
    try {
      await Workmanager().initialize(_callbackDispatcher, isInDebugMode: kDebugMode);
    } catch (_) {}
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == kEndFreeAccessTask) {
        // We cannot access Riverpod here; in a real app, integrate a background channel to disconnect.
        // As a minimal approach, nothing is done here; the VPN SDK will be disconnected when app is opened next time by app logic.
        return Future.value(true);
      }
      return Future.value(true);
    });
  }

  Future<bool> canUseFreeAccessToday(String uid) async {
    final profile = await _read(firestoreServiceProvider).getUserProfile(uid);
    if (profile.lastFreeAccessDate == null) return true;
    final last = profile.lastFreeAccessDate!;
    final now = DateTime.now();
    return !(last.year == now.year && last.month == now.month && last.day == now.day);
  }

  Future<bool> startDailyFreeAccess() async {
    final auth = _read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) throw Exception('Login required');

    final allowed = await canUseFreeAccessToday(user.uid);
    if (!allowed) return false;

    final watched = await _read(adsServiceProvider).showRewarded();
    if (!watched) return false;

    await _read(firestoreServiceProvider).setLastFreeAccessDate(user.uid, DateTime.now());

    // Connect VPN and schedule disconnection after 1 hour
    await _read(vpnServiceProvider).connect();

    _scheduleEndAfterOneHour();

    return true;
  }

  void _scheduleEndAfterOneHour() {
    final end = DateTime.now().add(const Duration(hours: 1));
    Workmanager().registerOneOffTask('end_free_${end.millisecondsSinceEpoch}', kEndFreeAccessTask,
        initialDelay: const Duration(hours: 1));
  }
}