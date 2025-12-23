import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Neu
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const BudgetyApp());
}

class BudgetyApp extends StatelessWidget {
  const BudgetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Budgety',
          debugShowCheckedModeBanner: false,

          // --- LOKALISIERUNG HINZUFÜGEN ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de', 'DE'), // Deutsch
          ],
          locale: const Locale('de', 'DE'), // Standardmäßig Deutsch
          // --------------------------------

          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
