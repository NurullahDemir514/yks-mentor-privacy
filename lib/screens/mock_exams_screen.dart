import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/weekly_plan.dart';
import '../models/mock_exam.dart';
import 'package:provider/provider.dart';
import '../providers/weekly_plan_provider.dart';
import '../providers/question_tracking_provider.dart';
import '../widgets/mock_exam/mock_exam_tab_content.dart';
import '../services/mock_exam_service.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MockExamsScreen extends StatefulWidget {
  const MockExamsScreen({super.key});

  @override
  State<MockExamsScreen> createState() => _MockExamsScreenState();
}

class _MockExamsScreenState extends State<MockExamsScreen> {
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
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBar(
            tabs: const [
              Tab(
                child: Text(
                  'TYT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'AYT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Branş',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            indicatorColor: AppTheme.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer2<WeeklyPlanProvider, QuestionTrackingProvider>(
                  builder: (context, weeklyPlanProvider,
                      questionTrackingProvider, _) {
                    final allMockExams = <DailyPlanItem>[];
                    final dailyPlans =
                        weeklyPlanProvider.selectedWeekPlan?.dailyPlans ?? {};
                    dailyPlans.forEach((day, plans) {
                      allMockExams
                          .addAll(plans.where((plan) => plan.isMockExam));
                    });

                    return TabBarView(
                      children: [
                        MockExamTabContent(examType: 'TYT'),
                        MockExamTabContent(examType: 'AYT'),
                        MockExamTabContent(examType: 'BRANCH'),
                      ],
                    );
                  },
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
        ),
      ),
    );
  }
}

class BranchExamTabContent extends StatelessWidget {
  final List<DailyPlanItem> plans;

  const BranchExamTabContent({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      return const Center(
        child: Text('Kullanıcı oturumu bulunamadı'),
      );
    }

    return FutureBuilder<Map<String, Map<String, double>>>(
      future: MockExamService.getBranchPerformanceSummary(userId.toHexString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        }

        final summary = snapshot.data ?? {};
        if (summary.isEmpty &&
            plans.where((p) => p.subject.contains('Branş:')).isEmpty) {
          return const Center(
            child: Text('Henüz branş denemesi bulunmuyor'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: summary.length,
          itemBuilder: (context, index) {
            final branch = summary.keys.elementAt(index);
            final stats = summary[branch]!;

            // Bu branşa ait denemeleri filtrele
            final branchExams = plans
                .where((p) => p.subject.contains('Branş: $branch'))
                .toList();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFF252837),
              child: ExpansionTile(
                title: Text(
                  branch,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow('Ortalama Net', stats['average']!),
                        const SizedBox(height: 8),
                        _buildStatRow('En Yüksek Net', stats['highest']!),
                        const SizedBox(height: 8),
                        _buildStatRow('En Düşük Net', stats['lowest']!),
                        const SizedBox(height: 8),
                        _buildStatRow('Son Net', stats['latest']!),
                        if (branchExams.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            'Denemeler',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...branchExams.map((exam) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  exam.topic, // Yayınevi
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  exam.subject.split(' - ')[1], // Konu
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: exam.isCompleted
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    exam.isCompleted
                                        ? 'Tamamlandı'
                                        : 'Bekliyor',
                                    style: TextStyle(
                                      color: exam.isCompleted
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
