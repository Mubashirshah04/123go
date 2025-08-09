import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  @override
  void initState() {
    super.initState();
    ref.read(adsServiceProvider).loadBanner();
  }

  @override
  Widget build(BuildContext context) {
    final ad = ref.watch(adsServiceProvider).bannerAd;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      height: ad.size.height.toDouble(),
      width: ad.size.width.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}