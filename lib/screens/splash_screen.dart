import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';
import 'main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  final VerticeAppController controller;

  const SplashScreen({super.key, required this.controller});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _minimumDisplayTimer;
  bool _minimumTimeElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    widget.controller.addListener(_onControllerChanged);
    _minimumDisplayTimer = Timer(const Duration(milliseconds: 1500), () {
      _minimumTimeElapsed = true;
      _tryNavigate();
    });
    _tryNavigate();
  }

  void _onControllerChanged() => _tryNavigate();

  void _tryNavigate() {
    if (!mounted ||
        _hasNavigated ||
        !_minimumTimeElapsed ||
        !widget.controller.isInitialized) {
      return;
    }
    _hasNavigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              MainShellScreen(controller: widget.controller),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _minimumDisplayTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: VerticeColors.screenGlowGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VerticeLogoMark(
                    size: 108,
                    showText: true,
                    showSlogan: true,
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: VerticeColors.purpleNeon,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.controller.isLoadingCatalog
                        ? 'CARREGANDO CATÁLOGO MUSICAL'
                        : widget.controller.isInitialized
                            ? 'PREPARANDO SUA EXPERIÊNCIA'
                            : 'INICIALIZANDO VÉRTICE MUSIC',
                    style: const TextStyle(
                      color: VerticeColors.textMuted,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
