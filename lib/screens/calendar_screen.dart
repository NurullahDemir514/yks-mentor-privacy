import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yks_mentor/features/weekly_plan/presentation/widgets/calendar/calendar_view.dart';
import '../providers/weekly_plan_provider.dart';
import '../constants/theme.dart';
import 'package:intl/intl.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdService.instance.createBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Consumer<WeeklyPlanProvider>(
        builder: (context, provider, _) {
          final allPlans = provider.allPlans;

          return Column(
            children: [
              Expanded(
                child: CalendarView(plans: allPlans),
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
          );
        },
      ),
    );
  }
}
