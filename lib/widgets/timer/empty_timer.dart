import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../app_scaffold.dart';

class EmptyTimer extends StatelessWidget {
  const EmptyTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 32),
          _buildHomeButton(context),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.timer_outlined,
        size: 64,
        color: AppTheme.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Zamanlayıcı Boşta',
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Çalışmaya başlamak için anasayfadan\nbir ders seçebilirsiniz',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 15,
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: () {
          final scaffold = AppScaffold.of(context);
          if (scaffold != null) {
            scaffold.changePage(0);
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white.withOpacity(0.9),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(
          Icons.home_rounded,
          size: 22,
        ),
        label: const Text(
          'Anasayfaya Dön',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
