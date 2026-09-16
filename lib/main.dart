import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'FazLauncher',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const FazLauncherApp());
}

class FazLauncherApp extends StatelessWidget {
  const FazLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FazLauncher',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        // Using System fonts that look better on Windows
        fontFamily: 'Segoe UI', 
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.red,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Segoe UI', fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(fontFamily: 'Segoe UI', fontWeight: FontWeight.w900),
          bodyLarge: TextStyle(fontFamily: 'Segoe UI'),
          bodyMedium: TextStyle(fontFamily: 'Segoe UI'),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
