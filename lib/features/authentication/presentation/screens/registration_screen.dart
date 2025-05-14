import 'dart:async'; 

import 'package:beatsync_app/core/router/app_routes.dart';
import 'package:beatsync_app/di/main_injection.dart';

import 'package:beatsync_app/features/authentication/presentation/cubit/registration_cubit/registration_cubit.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/registration_cubit/registration_state.dart';
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

class RegistrationScreen extends HookWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const String screenTitle = "Create Your Account";

    return BlocProvider<RegisterCubit>(




      create: (_) => RegisterCubit(sl()), 
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        body: BlocListener<RegisterCubit, RegistrationState>(
            listener: (context, state) {
              if (state is RegistrationSuccess) {

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(content: Text('Registration Successful! Please login.')),
                );
                context.go(AppRoute.login.path);
              } else if (state is RegistrationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20), 
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
                    const SizedBox(height: 30), 
                    const _RegistrationForm(),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class _RegistrationForm extends HookWidget {
  const _RegistrationForm();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final registerCubit = context.watch<RegisterCubit>();
    final registrationState = registerCubit.state;




    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AuthAnimatedItem(
            index: 1,
            child: TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: const Icon(Icons.person_outline),
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
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _AuthAnimatedItem(
            index: 2,
            child: TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: const Icon(Icons.person_outline),
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
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _AuthAnimatedItem(
            index: 3,
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
          const SizedBox(height: 16),
          _AuthAnimatedItem(
            index: 4,
            child: TextFormField(
              controller: passwordController,
              obscureText: obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
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
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          _AuthAnimatedItem(
            index: 5,
            child: FilledButton(
              onPressed: registrationState is RegistrationLoading
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        registerCubit.registerUser(
                          email: emailController.text,
                          password: passwordController.text,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                        );
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: registrationState is RegistrationLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
          _AuthAnimatedItem(
            index: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () {
                    context.go(AppRoute.login.path);
                  },
                  child:
                      const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
