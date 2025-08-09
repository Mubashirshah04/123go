import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/billing_service.dart';
import '../services/ads_service.dart';
import '../services/vpn_service.dart';
import '../services/free_access_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.read));

final billingServiceProvider = Provider<BillingService>((ref) => BillingService(ref.read));

final adsServiceProvider = Provider<AdsService>((ref) => AdsService(ref.read));

final vpnServiceProvider = Provider<VpnService>((ref) => VpnService(ref.read));

final freeAccessServiceProvider = Provider<FreeAccessService>((ref) => FreeAccessService(ref.read));