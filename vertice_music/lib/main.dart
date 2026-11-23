import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_controller.dart';
import 'core/firebase_bootstrap.dart';
import 'screens/splash_screen.dart';
import 'theme/vertice_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: VerticeColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await FirebaseBootstrap.initializeIfAvailable();

  final controller = VerticeAppController();
  await controller.initialize();

  runApp(VerticeMusicApp(controller: controller));
}

class VerticeMusicApp extends StatelessWidget {
  final VerticeAppController controller;

  const VerticeMusicApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VÉRTICE MUSIC',
      debugShowCheckedModeBanner: false,
      theme: VerticeTheme.darkTheme,
      home: SplashScreen(controller: controller),
    );
  }
}
