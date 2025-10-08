import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/exam_subjects.dart';
import '../../constants/exam_type.dart';
import '../../constants/theme.dart';
import '../../models/weekly_plan.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/object_id.dart';

class AddPlanDialog extends StatefulWidget {
  final Function(String) showErrorSnackBar;
  final WeeklyPlan? currentPlan;
  final String day;

  const AddPlanDialog({
    super.key,
    required this.showErrorSnackBar,
    required this.currentPlan,
    required this.day,
  });

  @override
  State<AddPlanDialog> createState() => _AddPlanDialogState();
}

class _AddPlanDialogState extends State<AddPlanDialog> {
  String? selectedSubject;
  String? selectedTopic;
  final targetQuestionsController = TextEditingController();
  bool isMockExam = false;
  final mockExamPublisherController = TextEditingController();
  String? selectedExamType;
  String? selectedBranch;
  String? selectedSubBranch;
  bool showBranchSelection = false;
  AYTField? selectedAYTField;
  int? targetQuestions;

  @override
  void initState() {
    super.initState();
    // Deneme için soru sayısını otomatik doldur
    if (isMockExam && selectedExamType != null) {
      _updateTargetQuestions();
    }
  }

  void _updateTargetQuestions() {
    if (selectedExamType != null) {
      targetQuestionsController.text =
          ExamTypeHelper.totalQuestions[selectedExamType!].toString();
    }
  }

  String _buildExamTypeString() {
    if (selectedExamType == ExamType.TYT) return 'TYT';
    if (selectedExamType == ExamType.AYT && selectedAYTField != null) {
      return 'AYT ${selectedAYTField!.displayName}';
    }
    return '';
  }

  Future<void> _addPlan(DailyPlanItem plan) async {
    final userId = AuthService.instance.currentUser?.id?.toHexString();
    if (userId == null) {
      widget.showErrorSnackBar('Kullanıcı oturumu bulunamadı');
      return;
    }

    // examId'yi burada oluştur
    final examId = ObjectId().toHexString();
    final updatedPlan = plan.copyWith(examId: examId);

    final weeklyPlanProvider = Provider.of<WeeklyPlanProvider>(
      context,
      listen: false,
    );

    await weeklyPlanProvider.addDailyPlan(widget.day, updatedPlan, userId);
    if (mounted) Navigator.pop(context);
  }

  DateTime _getPlanDate() {
    final now = DateTime.now();
    final weekDays = {
      'Pazartesi': DateTime.monday,
      'Salı': DateTime.tuesday,
      'Çarşamba': DateTime.wednesday,
      'Perşembe': DateTime.thursday,
      'Cuma': DateTime.friday,
      'Cumartesi': DateTime.saturday,
      'Pazar': DateTime.sunday,
    };

    final targetDay = weekDays[widget.day] ?? now.weekday;
    final daysToAdd = (targetDay - now.weekday) % 7;
    return DateTime(now.year, now.month, now.day + daysToAdd);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1D2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF252837),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isMockExam
                          ? Icons.assignment_outlined
                          : Icons.add_task_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMockExam ? 'Yeni Deneme' : 'Yeni Plan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.day,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deneme/Ders seçimi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252837),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  color: AppTheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Plan Türü',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: Text(
                                'Deneme Sınavı',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Deneme sınavı eklemek için aktifleştirin',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              value: isMockExam,
                              onChanged: (value) {
                                setState(() {
                                  isMockExam = value;
                                  selectedSubject = null;
                                  selectedTopic = null;
                                  selectedExamType = null;
                                  selectedBranch = null;
                                  selectedSubBranch = null;
                                  showBranchSelection = false;
                                });
                              },
                              activeColor: AppTheme.primary,
                              inactiveTrackColor: Colors.white.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isMockExam) ...[
                        // Yayınevi
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252837),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Yayınevi Bilgileri',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: mockExamPublisherController,
                                hint: 'Yayınevi',
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                value: selectedExamType,
                                hint: 'Deneme Türü',
                                items: [
                                  'TYT Denemesi',
                                  'AYT Denemesi',
                                  'Branş Denemesi'
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedExamType = value;
                                    selectedBranch = null;
                                    selectedSubBranch = null;
                                    showBranchSelection =
                                        value == 'Branş Denemesi';
                                    selectedAYTField = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (showBranchSelection) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF252837),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        color: AppTheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Branş Seçimi',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFF353745)),
                                _buildBranchSection(
                                  title: 'TYT Dersleri',
                                  color: Colors.blue,
                                  branches: ExamSubjects.getAllBranches().where(
                                      (branch) => branch.startsWith('TYT')),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFF353745)),
                                _buildBranchSection(
                                  title: 'AYT Dersleri',
                                  color: Colors.orange,
                                  branches: ExamSubjects.getAllBranches().where(
                                      (branch) => branch.startsWith('AYT')),
                                ),
                              ],
                            ),
                          ),
                          if (selectedBranch != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bu branş denemesi ${ExamSubjects.getBranchExamQuestionCount(selectedBranch!)} sorudan oluşacak',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                        if (selectedExamType == 'AYT Denemesi') ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252837),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: AppTheme.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AYT Alan Seçimi',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildDropdown(
                                  value: selectedAYTField?.displayName,
                                  hint: 'AYT Alanı',
                                  items: AYTField.values
                                      .map((e) => e.displayName)
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAYTField =
                                          AYTField.values.firstWhere(
                                        (field) => field.displayName == value,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252837),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ders ve Konu Seçimi',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                value: selectedSubject,
                                hint: 'Ders Seçin',
                                items: ExamSubjects.getAllSubjects(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSubject = value;
                                    selectedTopic = null;
                                  });
                                },
                              ),
                              if (selectedSubject != null) ...[
                                const SizedBox(height: 12),
                                _buildDropdown(
                                  value: selectedTopic,
                                  hint: 'Konu Seçin',
                                  items: ExamSubjects.getAllTopicsForSubject(
                                      selectedSubject!),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTopic = value;
                                    });
                                  },
                                ),
                              ],
                              if (!isMockExam) ...[
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: targetQuestionsController,
                                  hint: 'Hedef Soru Sayısı',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF252837),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('İptal'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      if (isMockExam) {
                        if (mockExamPublisherController.text.isEmpty) {
                          widget.showErrorSnackBar('Lütfen yayınevi girin');
                          return;
                        }

                        if (showBranchSelection) {
                          if (selectedBranch == null) {
                            widget.showErrorSnackBar('Lütfen branş seçin');
                            return;
                          }

                          final plan = DailyPlanItem(
                            subject: selectedBranch!,
                            topic: mockExamPublisherController.text,
                            targetQuestions:
                                ExamSubjects.getBranchExamQuestionCount(
                                    selectedBranch!),
                            isMockExam: true,
                            isCompleted: false,
                            date: _getPlanDate(),
                            examId: ObjectId().toHexString(),
                          );

                          await _addPlan(plan);
                          return;
                        }

                        if (selectedExamType == null) {
                          widget
                              .showErrorSnackBar('Lütfen deneme türünü seçin');
                          return;
                        }

                        if (selectedExamType == 'TYT Denemesi') {
                          final plan = DailyPlanItem(
                            subject: 'TYT',
                            topic: mockExamPublisherController.text,
                            targetQuestions: 120,
                            isMockExam: true,
                            isCompleted: false,
                            date: _getPlanDate(),
                            examId: ObjectId().toHexString(),
                          );
                          await _addPlan(plan);
                        } else if (selectedExamType == 'AYT Denemesi') {
                          if (selectedAYTField == null) {
                            widget
                                .showErrorSnackBar('Lütfen AYT alanını seçin');
                            return;
                          }
                          final plan = DailyPlanItem(
                            subject: 'AYT ${selectedAYTField!.displayName}',
                            topic: mockExamPublisherController.text,
                            targetQuestions: 80,
                            isMockExam: true,
                            isCompleted: false,
                            date: _getPlanDate(),
                            examId: ObjectId().toHexString(),
                          );
                          await _addPlan(plan);
                        }
                      } else {
                        if (selectedSubject == null || selectedTopic == null) {
                          widget.showErrorSnackBar(
                              'Lütfen tüm alanları doldurun');
                          return;
                        }

                        final targetQuestions =
                            int.tryParse(targetQuestionsController.text);
                        if (targetQuestions == null || targetQuestions <= 0) {
                          widget.showErrorSnackBar(
                              'Geçerli bir soru sayısı girin');
                          return;
                        }

                        final plan = DailyPlanItem(
                          subject: selectedSubject!,
                          topic: selectedTopic!,
                          targetQuestions: targetQuestions,
                          isCompleted: false,
                          isMockExam: false,
                          date: _getPlanDate(),
                        );

                        await _addPlan(plan);
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ekle'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252837),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        dropdownColor: const Color(0xFF252837),
        style: const TextStyle(color: Colors.white),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF252837),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildBranchSection({
    required String title,
    required Color color,
    required Iterable<String> branches,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...branches.map((branch) => RadioListTile<String>(
              value: branch,
              groupValue: selectedBranch,
              onChanged: (value) {
                setState(() {
                  selectedBranch = value;
                });
              },
              title: Text(
                branch.substring(4), // TYT/AYT prefix'ini kaldır
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${ExamSubjects.getBranchExamQuestionCount(branch)} Soru',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              activeColor: color,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            )),
      ],
    );
  }
}
