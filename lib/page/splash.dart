import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laundry_app/page/home.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Ready for a fresh start?';
    if (hour < 18) return 'Hope you\'re having a productive day!';
    return 'Perfect time for daily tasks!';
  }

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A0B2E),
                Color(0xFF2D1B69),
                Color(0xFF900C46),
                Color(0xFFFF6B6B),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              ...List.generate(
                20,
                (index) => AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    final angle =
                        (_rotateAnimation.value * 2 * math.pi) +
                        (index * 0.314);
                    final radius = 100 + (index * 10);
                    final x = screenWidth / 2 + radius * 0.5 * math.cos(angle);
                    final y = screenHeight / 2 + radius * 0.3 * math.sin(angle);

                    return Positioned(
                      left: x,
                      top: y,
                      child: Opacity(
                        opacity: 0.1 + (index % 3) * 0.05,
                        child: Container(
                          width: 4 + (index % 4),
                          height: 4 + (index % 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),

                            // Logo section with glassmorphism effect
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          width: 160,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.9),
                                                Colors.white.withOpacity(0.7),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF900C46,
                                                ).withOpacity(0.4),
                                                blurRadius: 40,
                                                spreadRadius: 8,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 25,
                                                offset: const Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Image.asset(
                                                'assets/IKON.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // App title with modern typography
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.5),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback:
                                          (bounds) => const LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Color(0xFFFFE4E1),
                                              Colors.white,
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        "HOUSEKEEPING",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 2.0,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        "L A U N D R Y • L O G B O O K",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          letterSpacing: 4.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Greeting with better styling
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.3),
                              child: Opacity(
                                opacity: _fadeAnimation.value * 0.9,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white.withOpacity(0.15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getGreeting(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // Bottom section with hotel info
                            Transform.translate(
                              offset: Offset(0, -_slideAnimation.value * 0.3),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.9),
                                            Colors.white.withOpacity(0.7),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.8),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 25,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/naga.png',
                                        width: 100,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'PADJAJARAN • BOGOR',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Tap indicator
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tap anywhere to continue',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}
