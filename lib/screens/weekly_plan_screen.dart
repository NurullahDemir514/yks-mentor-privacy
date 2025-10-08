import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yks_mentor/constants/exam_type.dart';
import 'package:yks_mentor/models/weekly_plan_statistics.dart';
import 'package:yks_mentor/widgets/weekly_plan/day_card.dart';
import 'package:yks_mentor/widgets/weekly_plan/past_plan_item.dart';
import 'package:yks_mentor/widgets/weekly_plan/past_week_card.dart';
import 'package:yks_mentor/widgets/weekly_plan/subject_distribution_card.dart';
import 'package:yks_mentor/widgets/weekly_plan/progress_card.dart';
import '../models/weekly_plan.dart';
import '../constants/theme.dart';
import 'package:provider/provider.dart';
import '../providers/weekly_plan_provider.dart';
import '../constants/exam_subjects.dart';
import 'package:intl/intl.dart';
import '../constants/weekly_plan_constants.dart';
import '../services/auth_service.dart';
import '../widgets/weekly_plan/add_plan_dialog.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/weekly_plan/day_detail_modal.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  BannerAd? _bannerAd;
  DateTime _selectedWeek = DateTime.now();

  String _formatWeekRange(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${DateFormat('d MMM', 'tr_TR').format(weekStart)} - ${DateFormat('d MMM', 'tr_TR').format(weekEnd)}';
  }

  void _goToNextWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    });
    context.read<WeeklyPlanProvider>().loadPlanForWeek(_selectedWeek);
  }

  void _goToPreviousWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    });
    context.read<WeeklyPlanProvider>().loadPlanForWeek(_selectedWeek);
  }

  @override
  void initState() {
    super.initState();
    // Verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeeklyPlanProvider>().loadPlanForWeek(_selectedWeek);
    });

    // Banner reklamı yükle
    _bannerAd = AdService.instance.createBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Bugünün haftanın hangi günü olduğunu bul
          final today = DateTime.now();
          final dayName = _getDayName(today.weekday);

          // Bugünün adını kullanarak ders ekle
          _showAddPlanDialog(dayName);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Hafta seçici
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _goToPreviousWeek,
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    _formatWeekRange(_selectedWeek),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: _goToNextWeek,
                    icon: Icon(
                      Icons.chevron_right,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<WeeklyPlanProvider>(
                builder: (context, provider, _) {
                  final currentPlan = provider.selectedWeekPlan;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...WeeklyPlanConstants.days.map((day) {
                        final plans = currentPlan?.dailyPlans[day] ?? [];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: DayCard(
                            day: day,
                            plans: plans,
                            onPlanItemTap: _handlePlanItemTap,
                            onPlanItemDelete: _handlePlanItemDelete,
                            onDayTap: _onDayTap,
                          ),
                        );
                      }).toList(),
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
    );
  }

  Future<void> _handlePlanItemTap(DailyPlanItem plan, String day) async {
    final provider = context.read<WeeklyPlanProvider>();
    final currentPlan = provider.selectedWeekPlan;
    if (currentPlan == null) return;

    final updatedPlan = plan.copyWith(isCompleted: !plan.isCompleted);
    provider.updatePlanItemOptimistic(day, plan, updatedPlan);

    try {
      await provider.updatePlanItem(day, plan, updatedPlan);
    } catch (e) {
      provider.updatePlanItemOptimistic(day, updatedPlan, plan);
      _showErrorSnackBar('Plan güncellenirken hata oluştu');
    }
  }

  Future<void> _handlePlanItemDelete(DailyPlanItem plan, String day) async {
    final provider = context.read<WeeklyPlanProvider>();
    final currentPlan = provider.selectedWeekPlan;
    if (currentPlan == null) return;

    provider.deletePlanItemOptimistic(day, plan);

    try {
      await provider.deletePlanItem(day, plan);
    } catch (e) {
      provider.addPlanItemOptimistic(day, plan);
      _showErrorSnackBar('Plan silinirken hata oluştu');
    }
  }

  void _showDayEditDialog(DateTime day) {
    final String formattedDay = DateFormat('d MMMM', 'tr_TR').format(day);
    final String dayName = _getDayName(day.weekday);
    final List<DailyPlanItem> dayPlans = _getPlansForDay(day);

    showDialog(
      context: context,
      builder: (context) => DayDetailModal(
        day: day,
        plans: dayPlans,
        onAddPlanTap: (_) => _showAddPlanDialog(dayName),
      ),
    );
  }

  void _showAddPlanDialog(String dayName) {
    showDialog(
      context: context,
      builder: (context) => AddPlanDialog(
        day: dayName,
        currentPlan: context.read<WeeklyPlanProvider>().selectedWeekPlan,
        showErrorSnackBar: _showErrorSnackBar,
      ),
    );
  }

  Widget _buildPastPlanItem(WeeklyPlan plan) {
    return PastPlanItem(plan: plan);
  }

  List<DailyPlanItem> _getPlansForDay(DateTime day) {
    final provider = Provider.of<WeeklyPlanProvider>(context, listen: false);
    final String formattedDay = DateFormat('yyyy-MM-dd').format(day);

    // Seçili haftalık planı al
    final currentPlan = provider.selectedWeekPlan;
    if (currentPlan == null) return [];

    // Haftanın günü adını bul
    final dayName = _getDayName(day.weekday);

    // O güne ait planları döndür
    return currentPlan.dailyPlans[dayName] ?? [];
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }

  void _onDayTap(DateTime day) {
    _showDayEditDialog(day);
  }
}
