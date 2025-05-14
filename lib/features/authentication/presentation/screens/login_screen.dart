import 'dart:async'; 

import 'package:beatsync_app/core/router/app_routes.dart'; 
import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/login_cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';


class _AuthAnimatedItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideBeginOffset;

  const _AuthAnimatedItem({
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
    this.slideBeginOffset = const Offset(0, 0.2),
  });

  @override
  State<_AuthAnimatedItem> createState() => _AuthAnimatedItemState();
}

class _AuthAnimatedItemState extends State<_AuthAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(begin: widget.slideBeginOffset, end: Offset.zero)
        .animate(curvedAnimation);

    Future.delayed(Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
        () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const String screenTitle = "Welcome Back!";

    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        body: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {


              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Login Failed: ${state.message}'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating, 
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(10),
                  ),
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40), 
                    _AuthAnimatedItem(
                      index: 0,
                      child: Text(
                        screenTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _LoginForm(),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class _LoginForm extends HookWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final loginCubit = context.watch<LoginCubit>(); 
    final loginState = loginCubit.state;




    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AuthAnimatedItem(
            index: 1,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _AuthAnimatedItem(
            index: 2,
            child: TextFormField(
              controller: passwordController,
              obscureText: obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => obscurePassword.value = !obscurePassword.value,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          _AuthAnimatedItem(
            index: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Forgot Password Tapped (Not Implemented)')),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _AuthAnimatedItem(
            index: 4,
            child: FilledButton(
              onPressed: loginState is LoginLoading
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        loginCubit.login(
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loginState is LoginLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
          _AuthAnimatedItem(
            index: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () {
                    context.go(AppRoute.register.path);
                  },
                  child: const Text('Register',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
