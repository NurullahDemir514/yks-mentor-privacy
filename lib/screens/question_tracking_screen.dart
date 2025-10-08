import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_tracking.dart';
import '../providers/question_tracking_provider.dart';
import '../constants/theme.dart';
import 'question_tracking/daily_tracking_tab.dart';
import 'question_tracking/analysis_tab.dart';
import '../constants/exam_subjects.dart';
import '../constants/exam_type.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class QuestionTrackingScreen extends StatefulWidget {
  const QuestionTrackingScreen({super.key});

  @override
  State<QuestionTrackingScreen> createState() => _QuestionTrackingScreenState();
}

class _QuestionTrackingScreenState extends State<QuestionTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bannerAd = AdService.instance.createBannerAd()..load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _deleteTracking(QuestionTracking tracking) async {
    try {
      await Provider.of<QuestionTrackingProvider>(context, listen: false)
          .deleteTracking(tracking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soru kaydı silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editTracking(QuestionTracking tracking) async {
    try {
      await Provider.of<QuestionTrackingProvider>(context, listen: false)
          .updateTracking(tracking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soru kaydı güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: AppTheme.primary,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 16),
              ),
              padding: EdgeInsets.zero,
              tabs: [
                Tab(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.today_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Günlük'),
                    ],
                  ),
                ),
                Tab(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.analytics_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Analiz'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DailyTrackingTab(
                  onDelete: _deleteTracking,
                  onEdit: _editTracking,
                ),
                const AnalysisTab(),
              ],
            ),
          ),
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
