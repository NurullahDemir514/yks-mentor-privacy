import 'package:flutter/material.dart';
import '../../models/weekly_plan.dart';
import '../../constants/theme.dart';
import '../../constants/exam_subjects.dart';
import '../../providers/weekly_plan_provider.dart';
import 'package:provider/provider.dart';

class EditLessonPlanModal extends StatefulWidget {
  final DailyPlanItem plan;
  final String day;

  const EditLessonPlanModal({
    super.key,
    required this.plan,
    required this.day,
  });

  @override
  State<EditLessonPlanModal> createState() => _EditLessonPlanModalState();
}

class _EditLessonPlanModalState extends State<EditLessonPlanModal>
    with SingleTickerProviderStateMixin {
  String? selectedSubject;
  String? selectedTopic;
  final targetQuestionsController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.plan.subject;
    selectedTopic = widget.plan.topic;
    targetQuestionsController.text = widget.plan.targetQuestions.toString();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    targetQuestionsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: const Color(0xFF252837),
                  ),
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      hint,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF252837),
                    underline: const SizedBox(),
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 18,
                      color: Colors.white.withOpacity(0.6),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF252837),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    const Text(
                      'Dersi Düzenle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.6),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              // Ayırıcı çizgi
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: Colors.white.withOpacity(0.06),
                  height: 1,
                ),
              ),

              // Form alanları
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown(
                      value: selectedSubject,
                      label: 'Ders',
                      hint: 'Ders Seçin',
                      items: ExamSubjects.getAllSubjects(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubject = value;
                          selectedTopic = null;
                        });
                      },
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    if (selectedSubject != null)
                      AnimatedOpacity(
                        opacity: selectedSubject != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: _buildDropdown(
                          value: selectedTopic,
                          label: 'Konu',
                          hint: 'Konu Seçin',
                          items: ExamSubjects.getAllTopicsForSubject(
                              selectedSubject!),
                          onChanged: (value) {
                            setState(() {
                              selectedTopic = value;
                            });
                          },
                          prefixIcon: Icons.topic_outlined,
                        ),
                      ),
                    if (selectedSubject != null) const SizedBox(height: 16),
                    _buildTextField(
                      controller: targetQuestionsController,
                      label: 'Hedef Soru Sayısı',
                      hint: 'Hedef soru sayısını girin',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.format_list_numbered_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Butonlar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedSubject == null) {
                              _showErrorSnackBar('Lütfen bir ders seçin');
                              return;
                            }

                            if (selectedTopic == null) {
                              _showErrorSnackBar('Lütfen bir konu seçin');
                              return;
                            }

                            final targetQuestions =
                                int.tryParse(targetQuestionsController.text);
                            if (targetQuestions == null ||
                                targetQuestions <= 0) {
                              _showErrorSnackBar(
                                  'Geçerli bir soru sayısı girin');
                              return;
                            }

                            final updatedPlan = DailyPlanItem(
                              subject: selectedSubject!,
                              topic: selectedTopic!,
                              targetQuestions: targetQuestions,
                              isCompleted: widget.plan.isCompleted,
                              isMockExam: false,
                              date: widget.plan.date,
                            );

                            context.read<WeeklyPlanProvider>().updatePlanItem(
                                  widget.day,
                                  widget.plan,
                                  updatedPlan,
                                );

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
