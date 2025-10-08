import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/weekly_plan_screen.dart';
import '../screens/question_tracking_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/timer_screen.dart';
import '../constants/theme.dart';
import '../services/auth_service.dart';
import '../providers/timer_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'timer_widget.dart';
import '../services/notification_service.dart';
import '../screens/mock_exams_screen.dart';
import '../screens/calendar_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  static _AppScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppScaffoldState>();
  }

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;
  late final List<Widget> _pages;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isTimerWidgetVisible = false;
  bool _isTimerRunning = false;

  final List<String> _pageTitles = [
    'Ana Sayfa',
    'Haftalık Program',
    'Takvim',
    'Soru Takibi',
    'Zamanlayıcı',
    'Denemeler',
    'Profil',
  ];

  void changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToTimer() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  void showTimerWidget() {
    setState(() {
      _isTimerWidgetVisible = true;
    });
  }

  void hideTimerWidget() {
    setState(() {
      _isTimerWidgetVisible = false;
    });
  }

  void setTimerRunning(bool isRunning) {
    setState(() {
      _isTimerRunning = isRunning;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const WeeklyPlanScreen(),
      const CalendarScreen(),
      const QuestionTrackingScreen(),
      const TimerScreen(),
      const MockExamsScreen(),
      const ProfileScreen(),
    ];
    NotificationService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          drawer: Container(
            width: 280,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundTop,
                  AppTheme.backgroundCenter,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 24,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      'YKS Mentor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    children: [
                      _buildMenuItem(
                        icon: Icons.home_outlined,
                        label: 'Anasayfa',
                        index: 0,
                      ),
                      _buildMenuItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Haftalık Plan',
                        index: 1,
                      ),
                      _buildMenuItem(
                        icon: Icons.calendar_month_outlined,
                        label: 'Takvim',
                        index: 2,
                      ),
                      _buildMenuItem(
                        icon: Icons.track_changes_outlined,
                        label: 'Soru Takibi',
                        index: 3,
                      ),
                      _buildMenuItem(
                        icon: Icons.timer_outlined,
                        label: 'Zamanlayıcı',
                        index: 4,
                      ),
                      _buildMenuItem(
                        icon: Icons.assignment_outlined,
                        label: 'Denemeler',
                        index: 5,
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        label: 'Profil',
                        index: 6,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.backgroundTop,
                                  AppTheme.backgroundCenter,
                                ],
                              ),
                            ),
                            child: AlertDialog(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              title: const Text(
                                'Çıkış Yap',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: const Text(
                                'Çıkış yapmak istediğinizden emin misiniz?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'İptal',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Çıkış Yap',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (result == true) {
                          await AuthService.instance.logout();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.15),
                              Colors.red.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.red[300]?.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Çıkış Yap',
                              style: TextStyle(
                                color: Colors.red[300]?.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
          drawerEnableOpenDragGesture: true,
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16,
                      bottom: 0,
                    ),
                    height: MediaQuery.of(context).padding.top + 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.backgroundTop,
                          AppTheme.backgroundCenter,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _pageTitles[_selectedIndex],
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 360
                                  ? 16
                                  : 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildHeaderRight(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.2,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (details) {
                    _dragStartX = details.localPosition.dx;
                    _isDragging = true;
                  },
                  onHorizontalDragUpdate: (details) {
                    if (!_isDragging) return;
                    final dragDistance = details.localPosition.dx - _dragStartX;
                    if (dragDistance > 50) {
                      _isDragging = false;
                      _scaffoldKey.currentState?.openDrawer();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    _isDragging = false;
                  },
                ),
              ),
              if (_isTimerWidgetVisible)
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: TimerWidget(
                    onClose: hideTimerWidget,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                ),
            ],
          ),
          bottomNavigationBar: null,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Ekran boyutuna göre font ve ikon boyutlarını ayarla
    final fontSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final iconSize = isSmallScreen ? 18.0 : (isTablet ? 24.0 : 22.0);
    final horizontalPadding = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final verticalPadding = isSmallScreen ? 8.0 : (isTablet ? 14.0 : 12.0);
    final iconSpacing = isSmallScreen ? 10.0 : (isTablet ? 16.0 : 14.0);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : (isTablet ? 16 : 12), vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withOpacity(isSelected ? 1 : 0.6),
                  size: iconSize,
                ),
                SizedBox(width: iconSpacing),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(isSelected ? 1 : 0.6),
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Anasayfa';
      case 1:
        return 'Haftalık Plan';
      case 2:
        return 'Takvim';
      case 3:
        return 'Soru Takibi';
      case 4:
        return 'Zamanlayıcı';
      case 5:
        return 'Profil';
      default:
        return 'YKS Mentor';
    }
  }

  int _getRemainingDays() {
    final now = DateTime.now();
    final examDate = DateTime(2025, 6, 21); // 2024 YKS tarihi
    return examDate.difference(now).inDays;
  }

  Widget _buildHeaderRight() {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isSmallScreen = MediaQuery.of(context).size.width < 360;
        final textStyle = TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        );

        // Anasayfa ve zamanlayıcı ekranında timer'ı gösterme, sadece YKS sayacı görünsün
        if (_selectedIndex == 0 || _selectedIndex == 4) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF363B54),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YKS\'ye ${_getRemainingDays()} gün',
                  style: textStyle,
                ),
              ],
            ),
          );
        }

        // Diğer sayfalarda timer aktifse timer'ı, değilse YKS sayacını göster
        if (timerProvider.isRunning) {
          return GestureDetector(
            onTap: () {
              AppScaffold.of(context)?.changePage(4);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF363B54),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppTheme.primary,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Text(
                    timerProvider.formattedTime,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: isSmallScreen ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF363B54),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YKS\'ye ${_getRemainingDays()} gün',
                style: textStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
