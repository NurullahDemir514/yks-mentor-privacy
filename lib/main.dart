import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/weekly_plan_provider.dart';
import './providers/question_tracking_provider.dart';
import './providers/theme_provider.dart';
import './providers/auth_provider.dart';
import './providers/timer_provider.dart';
import './constants/theme.dart';
import './widgets/app_scaffold.dart';
import './screens/auth/login_screen.dart';
import './screens/profile/change_password_screen.dart';
import 'dart:ui';
import 'services/auth_service.dart';
import './screens/profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reklam servisini başlat
  await AdService.instance.initialize();

  await AuthService.instance.init();
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyPlanProvider()),
        ChangeNotifierProvider(create: (_) => QuestionTrackingProvider()),
        ChangeNotifierProvider(
            create: (context) => TimerProvider(
                Provider.of<WeeklyPlanProvider>(context, listen: false))),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'YKS Mentor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'),
          ],
          locale: const Locale('tr', 'TR'),
          navigatorKey: navigatorKey,
          home: AuthService.instance.currentUser != null
              ? const AppScaffold()
              : const LoginScreen(),
          routes: {
            '/home': (context) => const AppScaffold(),
            '/login': (context) => const LoginScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
          },
        );
      }),
    );
  }
}
