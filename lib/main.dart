import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await NotificationService().init();
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return MaterialApp(
          title: 'Task Master',
          debugShowCheckedModeBanner: false,
          themeMode: taskProvider.themeMode,

          // ── DARK THEME ─────────────────────────────────────────────────────
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.dark,
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF5AC8FA),
              surface: const Color(0xFF1A1A2E),
              error: const Color(0xFFFF6B6B),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F1E),
            cardColor: const Color(0xFF1E1E3A),
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              bodyLarge:
                  TextStyle(fontSize: 16, color: Colors.white),
              bodyMedium:
                  TextStyle(fontSize: 14, color: Colors.white70),
              bodySmall:
                  TextStyle(fontSize: 12, color: Colors.white60),
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF6C63FF);
                }
                return Colors.transparent;
              }),
              side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            dropdownMenuTheme: DropdownMenuThemeData(
              textStyle: const TextStyle(color: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E1E3A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            dividerColor: Colors.white12,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),

          // ── LIGHT THEME ────────────────────────────────────────────────────
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.light,
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF3A7BD5),
              surface: Colors.white,
              error: const Color(0xFFE53935),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F4FB),
            cardColor: Colors.white,
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
              titleTextStyle: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF0F0FF),
              labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFD0CFF5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD0CFF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
              headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
              titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)),
              bodyLarge:
                  TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
              bodyMedium:
                  TextStyle(fontSize: 14, color: Color(0xFF4A4A6A)),
              bodySmall:
                  TextStyle(fontSize: 12, color: Color(0xFF7A7A9A)),
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF6C63FF);
                }
                return Colors.transparent;
              }),
              side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            dividerColor: const Color(0xFFE0E0F0),
            iconTheme: const IconThemeData(color: Color(0xFF4A4A6A)),
          ),

          home: const HomeScreen(),
        );
      },
    );
  }
}
