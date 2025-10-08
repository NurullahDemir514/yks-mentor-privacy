import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_helper.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService instance = AdService._init();
  AdService._init();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner reklam yüklendi.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner reklam yüklenemedi: $error');
          ad.dispose();
        },
      ),
    );
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Tam sayfa reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Tam sayfa reklam yüklenemedi: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady) {
      debugPrint('Tam sayfa reklam henüz hazır değil.');
      return;
    }

    _interstitialAd?.show();
    _isInterstitialAdReady = false;
    _interstitialAd = null;
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Ödüllü reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Ödüllü reklam yüklenemedi: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  Future<void> showRewardedAd({
    required Function onRewarded,
    required Function onDismissed,
  }) async {
    if (!_isRewardedAdReady) {
      debugPrint('Ödüllü reklam henüz hazır değil.');
      return;
    }

    _rewardedAd?.show(
      onUserEarnedReward: (_, reward) {
        onRewarded();
      },
    );

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        onDismissed();
        _isRewardedAdReady = false;
        _rewardedAd = null;
      },
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
