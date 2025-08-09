import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart' as functions;
import 'auth_service.dart';
import 'firestore_service.dart';

class BillingService {
  final Reader _read;
  BillingService(this._read);

  static const String monthlyId = 'geg_vpn_monthly';
  static const String yearlyId = 'geg_vpn_yearly';

  final InAppPurchase _iap = InAppPurchase.instance;
  final _productController = StreamController<List<ProductDetails>>.broadcast();
  Stream<List<ProductDetails>> get productsStream => _productController.stream;

  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    const ids = {monthlyId, yearlyId};
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('IAP query error: ${response.error}');
    }
    _productController.add(response.productDetails);
    _iap.purchaseStream.listen(_onPurchaseUpdated, onError: (e) => debugPrint('purchase err $e'));
  }

  Future<void> buy(ProductDetails details) async {
    final purchaseParam = PurchaseParam(productDetails: details);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        final ok = await _verifyWithServer(p);
        if (ok) {
          await _deliver(p);
          await _iap.completePurchase(p);
        }
      } else if (p.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${p.error}');
      }
    }
  }

  Future<bool> _verifyWithServer(PurchaseDetails p) async {
    try {
      final uid = _read(authServiceProvider).currentUser?.uid;
      if (uid == null) return false;
      final callable = functions.FirebaseFunctions.instance.httpsCallable('verifyPlaySubscription');
      final result = await callable.call({
        'purchaseToken': p.verificationData.serverVerificationData,
        'productId': p.productID,
        'packageName': p.verificationData.source, // plugin provides package name in source
        'uid': uid,
      });
      final data = result.data as Map<String, dynamic>;
      return data['valid'] == true;
    } catch (e) {
      debugPrint('Verification failed: $e');
      return false;
    }
  }

  Future<void> _deliver(PurchaseDetails p) async {
    final uid = _read(authServiceProvider).currentUser!.uid;
    final fs = _read(firestoreServiceProvider);
    final now = DateTime.now();
    final expiry = p.productID == yearlyId
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);
    await fs.setSubscribed(uid, subscribed: true, expiry: expiry);
    await fs.logPayment(uid, {
      'productId': p.productID,
      'purchaseID': p.purchaseID,
      'transactionDate': now,
    });
  }
}