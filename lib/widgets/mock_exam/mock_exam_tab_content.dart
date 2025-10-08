import 'package:flutter/material.dart';
import 'package:yks_mentor/constants/exam_type.dart';
import 'package:yks_mentor/models/weekly_plan.dart';
import 'package:yks_mentor/widgets/app_scaffold.dart';
import '../../models/mock_exam.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../services/mock_exam_service.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'empty_state_widget.dart';
import '../../constants/theme.dart';
import 'performance_chart.dart';
import 'exam_performance_card.dart';
import 'exam_list_item.dart';
import 'exam_pagination.dart';

// Tab içeriği için abstract class (Interface Segregation)
abstract class IMockExamTab {
  Widget buildTabContent(List<MockExam> mockExams);
}

// TYT tab içeriği (Single Responsibility)
class TYTTabContent extends StatelessWidget implements IMockExamTab {
  final List<MockExam> mockExams;

  const TYTTabContent({super.key, required this.mockExams});

  @override
  Widget buildTabContent(List<MockExam> mockExams) {
    final completedExams =
        mockExams.where((exam) => exam.result != null).toList();

    if (completedExams.isEmpty) {
      return const EmptyStateWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedExams.length,
      itemBuilder: (context, index) =>
          ExamListItem(exam: completedExams[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildTabContent(mockExams);
  }
}

// AYT tab içeriği (Single Responsibility)
class AYTTabContent extends StatelessWidget implements IMockExamTab {
  final List<MockExam> mockExams;

  const AYTTabContent({super.key, required this.mockExams});

  @override
  Widget buildTabContent(List<MockExam> mockExams) {
    final completedExams =
        mockExams.where((exam) => exam.result != null).toList();

    if (completedExams.isEmpty) {
      return const EmptyStateWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedExams.length,
      itemBuilder: (context, index) =>
          ExamListItem(exam: completedExams[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildTabContent(mockExams);
  }
}

// Ana içerik widget'ı (Single Responsibility)
class MockExamTabContent extends StatefulWidget {
  final String examType;

  const MockExamTabContent({
    super.key,
    required this.examType,
  });

  @override
  State<MockExamTabContent> createState() => _MockExamTabContentState();
}

class _MockExamTabContentState extends State<MockExamTabContent> {
  String? _selectedBranch;

  List<String> _getAvailableBranches(List<DailyPlanItem> plans) {
    return plans
        .where((plan) => (plan.subject.startsWith('TYT ') ||
            plan.subject.startsWith('AYT ')))
        .map((plan) => plan.subject)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<MockExam>> _loadMockExams() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return [];

    final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(
      context,
      listen: false,
    );

    final allPlans = <DailyPlanItem>[];
    weeklyPlanProvider.selectedWeekPlan?.dailyPlans.forEach((day, plans) {
      allPlans
          .addAll(plans.where((plan) => plan.isMockExam && !plan.isDeleted));
    });

    // Filtreleme
    switch (widget.examType) {
      case 'BRANCH':
        // Branş denemeleri
        final branchPlans = allPlans
            .where((plan) =>
                (plan.subject.startsWith('TYT ') ||
                    plan.subject.startsWith('AYT ')) &&
                plan.isCompleted &&
                (_selectedBranch == null || plan.subject == _selectedBranch))
            .toList();
        return MockExamService.filterByType(
            branchPlans, widget.examType, userId.toHexString());

      case 'TYT':
        // TYT denemeleri (branş olmayan)
        final tytPlans = allPlans
            .where((plan) => plan.subject == 'TYT' && plan.isCompleted)
            .toList();
        return MockExamService.filterByType(
            tytPlans, widget.examType, userId.toHexString());

      case 'AYT':
        // AYT denemeleri (branş olmayan)
        final aytPlans = allPlans
            .where((plan) =>
                plan.subject.startsWith('AYT ') &&
                !plan.subject.contains('AYT Matematik') &&
                !plan.subject.contains('AYT Fizik') &&
                !plan.subject.contains('AYT Kimya') &&
                !plan.subject.contains('AYT Biyoloji') &&
                !plan.subject.contains('AYT Edebiyat') &&
                !plan.subject.contains('AYT Tarih') &&
                !plan.subject.contains('AYT Coğrafya') &&
                !plan.subject.contains('AYT Felsefe') &&
                plan.isCompleted)
            .toList();
        return MockExamService.filterByType(
            aytPlans, widget.examType, userId.toHexString());

      default:
        return [];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.examType == 'BRANCH'
                ? Icons.assignment_outlined
                : Icons.assignment,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            widget.examType == 'BRANCH'
                ? 'Henüz branş denemesi eklenmemiş'
                : 'Henüz ${widget.examType} denemesi eklenmemiş',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.examType == 'BRANCH'
                ? 'Haftalık plana branş denemesi ekleyerek başlayabilirsin'
                : 'Haftalık plana ${widget.examType} denemesi ekleyerek başlayabilirsin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              AppScaffold.of(context)?.changePage(1);
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Deneme Ekle'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyPlanProvider>(
      builder: (context, weeklyPlanProvider, _) {
        final currentPlan = weeklyPlanProvider.selectedWeekPlan;
        if (currentPlan == null) {
          return const Center(
            child: Text('Plan bulunamadı'),
          );
        }

        final userId = AuthService.instance.currentUser?.id;
        if (userId == null) {
          return const Center(
            child: Text('Kullanıcı oturumu bulunamadı'),
          );
        }

        final allPlans =
            currentPlan.dailyPlans.values.expand((e) => e).toList();

        return FutureBuilder<List<MockExam>>(
          future: _loadMockExams(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Bir hata oluştu: ${snapshot.error}'),
              );
            }

            final mockExams = snapshot.data ?? [];
            if (mockExams.isEmpty && _selectedBranch == null) {
              return _buildEmptyState();
            }

            final completedExams =
                mockExams.where((exam) => exam.result != null).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.examType == 'BRANCH') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedBranch,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list_rounded,
                                      size: 18,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tüm Branşlar',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1F1D2B),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.filter_list_rounded,
                                          size: 18,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tüm Branşlar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ..._getAvailableBranches(allPlans)
                                      .map((branch) {
                                    IconData icon;
                                    if (branch.startsWith('TYT')) {
                                      icon = Icons.assignment_outlined;
                                    } else {
                                      icon = Icons.assignment_late_outlined;
                                    }
                                    return DropdownMenuItem(
                                      value: branch,
                                      child: Row(
                                        children: [
                                          Icon(
                                            icon,
                                            size: 18,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            branch,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBranch = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (completedExams.isNotEmpty) ...[
                    ExamPerformanceCard(
                      examType: widget.examType,
                      completedExams: completedExams,
                      selectedBranch: _selectedBranch,
                    ),
                    const SizedBox(height: 24),
                    if (completedExams.length >= 2) ...[
                      Text(
                        _selectedBranch == null
                            ? 'Son 5 Deneme Performansı'
                            : '$_selectedBranch - Son 5 Deneme Performansı',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PerformanceChart(
                        completedExams: completedExams,
                        selectedBranch: _selectedBranch,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                  Text(
                    'Tüm Denemeler',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaginatedExamList(mockExams),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaginatedExamList(List<MockExam> mockExams) {
    return StatefulBuilder(
      builder: (context, setState) {
        final pageSize = 5;
        final totalPages = (mockExams.length / pageSize).ceil();
        final currentPage = ValueNotifier<int>(0);

        return Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, _) {
                final start = page * pageSize;
                final end = (start + pageSize) > mockExams.length
                    ? mockExams.length
                    : start + pageSize;
                final currentExams =
                    mockExams.reversed.toList().sublist(start, end);

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentExams.length,
                      itemBuilder: (context, index) => ExamListItem(
                        exam: currentExams[index],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExamPagination(
                      currentPage: page,
                      totalPages: totalPages,
                      onPageChanged: (newPage) => currentPage.value = newPage,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
