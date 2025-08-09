import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class AdsService {
  final Reader _read;
  AdsService(this._read);

  static const String bannerAdUnitId = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // test id
  );

  static const String rewardedAdUnitId = String.fromEnvironment(
    'REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // test id
  );

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;

  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadBanner() async {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      listener: const BannerAdListener(),
      request: const AdRequest(),
    )..load();
  }

  Future<bool> showRewarded() async {
    final completer = Completer<bool>();
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) {
            if (!completer.isCompleted) completer.complete(true);
          });
        },
        onAdFailedToLoad: (err) {
          completer.complete(false);
        },
      ),
    );
    return completer.future;
  }
}