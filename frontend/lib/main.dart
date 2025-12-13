import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'models/user.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/medication_viewmodel.dart';
import 'viewmodels/checkin_viewmodel.dart';
import 'app_con/screens/dashboard_screen.dart';
import 'app_parent/screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Log mode (Mock hoặc Live)
  AppConfig.logMode();
  
  // Khởi tạo services - Tạm comment để build nhanh hơn
  // await NotificationService().initialize();
  // await BackgroundService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthViewModel()),
              ChangeNotifierProvider(create: (_) => MedicationViewModel()),
              ChangeNotifierProvider(create: (_) => CheckInViewModel()),
            ],
            child: MaterialApp(
              title: 'An Tâm',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('vi', 'VN'),
                Locale('en', 'US'),
              ],
              locale: const Locale('vi', 'VN'),
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2196F3),
                  brightness: Brightness.light,
                  primary: const Color(0xFF2196F3),
                  secondary: const Color(0xFF03A9F4),
                  surface: Colors.white,
                  surfaceContainerHighest: const Color(0xFFF5F5F5),
                ),
                textTheme: GoogleFonts.interTextTheme().copyWith(
                  displayLarge: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  displayMedium: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  displaySmall: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  headlineLarge: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  headlineMedium: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  headlineSmall: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                  titleLarge: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    decoration: TextDecoration.none,
                  ),
                  titleMedium: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                  titleSmall: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                  bodyLarge: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                  bodyMedium: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                    decoration: TextDecoration.none,
                  ),
                  bodySmall: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                    decoration: TextDecoration.none,
                  ),
                  labelLarge: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                  labelMedium: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                  labelSmall: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                ),
                cardTheme: CardThemeData(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                  color: Colors.white,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                chipTheme: ChipThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              home: const AppSelector(),
            ),
          );
        },
    );
  }
}

class AppSelector extends StatefulWidget {
  const AppSelector({super.key});

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  @override
  void initState() {
    super.initState();
    // Load saved user when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().loadSavedUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authViewModel.isAuthenticated) {
          final user = authViewModel.currentUser!;
          // Chuyển đến màn hình tương ứng với loại user
          print('🔍 [APP] User type: ${user.type}, toString: ${user.type.toString()}');
          print('🔍 [APP] Checking if elder: ${user.type == UserType.elder}');
          
          if (user.type == UserType.elder) {
            print('✅ [APP] Navigating to ParentMainScreen (Elder)');
            return const ParentMainScreen();
          } else {
            print('✅ [APP] Navigating to DashboardScreen (Carer)');
            return const DashboardScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}

