import 'dart:async';

import 'package:beatsync_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});



  @override
  Widget build(BuildContext context) {
    useEffect(() {


      context.read<AuthCubit>().checkAuthStatus();
      return null; 
    }, const []);


    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 30), 

          ],
        ),
      ),
    );
  }
}

class AnimatedBeatSyncText extends HookWidget {
  const AnimatedBeatSyncText({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final List<String> letters = 'BeatSync'.split('');

    useEffect(() {
      animationController.forward();
      return animationController.dispose;
    }, const []);

    List<Widget> animatedLetters = [];
    for (int i = 0; i < letters.length; i++) {
      final startTime = (i * 0.1).clamp(0.0, 1.0);
      final endTime = (startTime + 0.5).clamp(0.0, 1.0);

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(startTime, endTime, curve: Curves.easeOutExpo),
        ),
      );

      final scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(startTime, endTime, curve: Curves.elasticOut),
        ),
      );

      animatedLetters.add(
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Text(
                  letters[i],
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: animatedLetters,
    );
  }
}

class PulsingLineAccent extends HookWidget {
  const PulsingLineAccent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 0.2),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0), weight: 0.6), 
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 0.2),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final widthAnimation = Tween<double>(begin: 50.0, end: 100.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    useEffect(() {

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (context.mounted) {

          controller.repeat(reverse: true);
        }
      });
      return () => controller.dispose();
    }, const []);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Container(
            width: widthAnimation.value,
            height: 3.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        );
      },
    );
  }
}
