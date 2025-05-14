import 'dart:async';

import 'package:beatsync_app/features/authentication/domain/entities/user_entity.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';


const String settingsScreenRoutePath = '/profile/settings';
const String statisticsScreenRoutePath = '/statistics'; 


class _AnimatedProfileListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayBase;
  final Duration duration;

  const _AnimatedProfileListItem({
    required this.index,
    required this.child,
    this.delayBase = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<_AnimatedProfileListItem> createState() => _AnimatedProfileListItemState();
}

class _AnimatedProfileListItemState extends State<_AnimatedProfileListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero) 
            .animate(curvedAnimation);
    _scaleAnimation =
        Tween<double>(begin: 0.98, end: 1.0).animate(curvedAnimation); 

    Future.delayed(Duration(milliseconds: widget.index * widget.delayBase.inMilliseconds),
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}


class _ProfileHeader extends StatelessWidget {
  final UserEntity? user;
  final bool isLoadingProfile;

  const _ProfileHeader({required this.user, required this.isLoadingProfile});

  String _getInitials(UserEntity? user) {
    if (user == null) return "";
    String initials = "";
    if (user.firstName.isNotEmpty) {
      initials += user.firstName[0];
    }
    if (user.lastName.isNotEmpty) {
      initials += user.lastName[0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double headerMinHeight = 220;
    final double avatarRadius = 50;

    final String displayName = isLoadingProfile
        ? "Loading..."
        : (user != null ? '${user!.firstName} ${user!.lastName}'.trim() : "Guest User");
    final String displayEmail = isLoadingProfile ? "Loading..." : (user?.email ?? "");
    final String initials = _getInitials(user);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: headerMinHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: avatarRadius), 
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24)), 
                ),
                height: headerMinHeight - avatarRadius,
              ),
              Positioned(
                bottom: 0,
                child: CircleAvatar(

                  radius: avatarRadius,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: isLoadingProfile && initials.isEmpty
                      ? CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onSecondaryContainer),
                        )
                      : Text(
                          initials.isNotEmpty ? initials : "?",
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            displayName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (displayEmail.isNotEmpty)
          Text(
            displayEmail,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 24), 
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor; 

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });
}

class _ActionListCard extends StatelessWidget {
  final List<_ActionItem> actions;

  const _ActionListCard({required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHigh,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: (action.iconColor ?? colorScheme.primary).withOpacity(0.1),
              child: Icon(action.icon,
                  color: action.iconColor ?? colorScheme.primary, size: 20),
            ),
            title: Text(action.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            onTap: action.onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          indent: 70, 
          endIndent: 16,
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
        padding: EdgeInsets
            .zero, 
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routePath = '/profile'; 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!; 

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      appBar: AppBar(
        title: Text(l10n.profileTitle), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: theme.colorScheme.onSurface,
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          UserEntity? currentUser;
          bool isLoadingProfile = false;

          if (state is Authenticated) {
            currentUser = state.user;
            if (currentUser == null) {
              isLoadingProfile = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted &&
                    context.read<AuthCubit>().state is Authenticated &&
                    (context.read<AuthCubit>().state as Authenticated).user == null) {
                  context.read<AuthCubit>().loadUserProfile();
                }
              });
            } else {
              isLoadingProfile = false;
            }
          } else if (state is AuthLoading || state is AuthInitial) {

            return const Center(child: CircularProgressIndicator());
          } else {



            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Not logged in', style: theme.textTheme.bodyLarge),
              ),
            );
          }


          final List<_ActionItem> profileActions = [
            _ActionItem(
              icon: Icons.settings_outlined,
              title: l10n.settingsTitle, 
              onTap: () {


                GoRouter.of(context).push(settingsScreenRoutePath); 
              },
            ),
          ];

          final List<Widget> listItems = [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: isLoadingProfile && _getInitials(currentUser) == "?"
                        ? CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onSecondaryContainer),
                          )
                        : Text(
                            _getInitials(currentUser),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    isLoadingProfile
                        ? l10n.loading
                        : (currentUser != null
                            ? '${currentUser.firstName} ${currentUser.lastName}'.trim()
                            : l10n.guestUser),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6.0),
                  if (currentUser != null &&
                      currentUser.email.isNotEmpty &&
                      !isLoadingProfile)
                    Text(
                      currentUser.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _ActionListCard(actions: profileActions),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 32.0), 
              child: OutlinedButton.icon(
                icon: Icon(Icons.logout_outlined, color: theme.colorScheme.error),
                label: Text(l10n.logoutButton,
                    style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
                  foregroundColor: theme.colorScheme.error,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _showLogoutConfirmationDialog(context, l10n, theme),
              ),
            )
          ];

          return ListView.builder(
            padding: EdgeInsets.zero, 
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              return _AnimatedProfileListItem(
                index: index,
                child: listItems[index],
              );
            },
          );
        },
      ),
    );
  }

  String _getInitials(UserEntity? user) {
    if (user == null) return "?";
    String initials = "";
    if (user.firstName.isNotEmpty) {
      initials += user.firstName[0];
    }
    if (user.lastName.isNotEmpty) {
      initials += user.lastName[0];
    }
    return initials.isEmpty ? "?" : initials.toUpperCase();
  }

  Future<void> _showLogoutConfirmationDialog(
      BuildContext context, AppLocalizations l10n, ThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog.adaptive(
          title: Text(l10n.confirmLogoutTitle),
          content: Text(l10n.confirmLogoutMessage),
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButton,
                  style: TextStyle(
                      color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(l10n.logoutButton,
                  style: TextStyle(
                      color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().loggedOut();
              },
            ),
          ],
        );
      },
    );
  }
}


























