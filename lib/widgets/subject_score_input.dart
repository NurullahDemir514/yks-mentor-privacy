import 'package:flutter/material.dart';

class SubjectScoreInput extends StatefulWidget {
  final String subject;
  final List<TextEditingController> controllers;
  final VoidCallback onWrongTopicsTap;
  final VoidCallback onTopicsToStudyTap;

  const SubjectScoreInput({
    super.key,
    required this.subject,
    required this.controllers,
    required this.onWrongTopicsTap,
    required this.onTopicsToStudyTap,
  });

  @override
  State<SubjectScoreInput> createState() => _SubjectScoreInputState();
}

class _SubjectScoreInputState extends State<SubjectScoreInput> {
  double _calculateNet() {
    final correct = int.tryParse(widget.controllers[0].text) ?? 0;
    final wrong = int.tryParse(widget.controllers[1].text) ?? 0;
    return correct - (wrong / 4);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers[0],
                    decoration: const InputDecoration(
                      labelText: 'Doğru',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 40) {
                          return 'Geçersiz sayı';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers[1],
                    decoration: const InputDecoration(
                      labelText: 'Yanlış',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 40) {
                          return 'Geçersiz sayı';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: widget.controllers[2],
                    decoration: const InputDecoration(
                      labelText: 'Boş',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 40) {
                          return 'Geçersiz sayı';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  'Net: ${_calculateNet().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: widget.onWrongTopicsTap,
                      icon: const Icon(Icons.error_outline),
                      tooltip: 'Yanlışlar',
                      constraints: const BoxConstraints(minWidth: 40),
                    ),
                    IconButton(
                      onPressed: widget.onTopicsToStudyTap,
                      icon: const Icon(Icons.book_outlined),
                      tooltip: 'Çalışılacaklar',
                      constraints: const BoxConstraints(minWidth: 40),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
