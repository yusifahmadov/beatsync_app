import 'dart:async'; 

import 'package:beatsync_app/core/settings/app_settings.dart';
import 'package:beatsync_app/core/settings/app_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 


class _AnimatedSettingsListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayBase;
  final Duration duration;

  const _AnimatedSettingsListItem({
    required this.index,
    required this.child,
    this.delayBase = const Duration(milliseconds: 120), 
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<_AnimatedSettingsListItem> createState() => _AnimatedSettingsListItemState();
}

class _AnimatedSettingsListItemState extends State<_AnimatedSettingsListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic), 
    );

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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}


class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _SettingsSectionCard({
    required this.title,
    required this.children,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, 
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),

      ),
      color: colorScheme.surfaceContainerHigh, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(

                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12), 
            ...children,
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const String routePath = '/profile/settings';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest, 
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettings>(
        builder: (context, appSettings) {
          return _buildModernSettingsContent(
              context, appSettings, l10n, colorScheme, theme);
        },
      ),
    );
  }

  Widget _buildModernSettingsContent(BuildContext context, AppSettings settings,
      AppLocalizations l10n, ColorScheme colorScheme, ThemeData theme) {
    final cubit = context.read<AppSettingsCubit>();

    final List<Widget> settingsSections = [
      _buildModernLanguageSection(context, settings, l10n, cubit, colorScheme, theme),
      _buildModernThemeSection(context, settings, l10n, cubit, colorScheme, theme),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: settingsSections.length,
      itemBuilder: (context, index) {
        return _AnimatedSettingsListItem(
          index: index,
          child: settingsSections[index],
        );
      },
    );
  }

  Widget _buildModernLanguageSection(
      BuildContext context,
      AppSettings settings,
      AppLocalizations l10n,
      AppSettingsCubit cubit,
      ColorScheme colorScheme,
      ThemeData theme) {


    final availableLanguages = [
      {'label': l10n.languageEnglish, 'value': AppLanguage.en},
      {'label': l10n.languageTurkish, 'value': AppLanguage.tr},

    ];

    return _SettingsSectionCard(
      title: l10n.languageSettingTitle,
      colorScheme: colorScheme,
      theme: theme,
      children: availableLanguages.map((lang) {
        return RadioListTile<AppLanguage>(
          title: Text(lang['label'] as String,
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
          value: lang['value'] as AppLanguage,
          groupValue: settings.language,
          onChanged: (AppLanguage? value) {
            if (value != null) {
              cubit.updateLanguage(value);
            }
          },
          activeColor: colorScheme.primary,
          contentPadding: EdgeInsets.zero, 
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildModernThemeSection(
      BuildContext context,
      AppSettings settings,
      AppLocalizations l10n,
      AppSettingsCubit cubit,
      ColorScheme colorScheme,
      ThemeData theme) {
    return _SettingsSectionCard(
      title: l10n.themeSettingTitle,
      colorScheme: colorScheme,
      theme: theme,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SegmentedButton<AppThemePreference>(
            segments: <ButtonSegment<AppThemePreference>>[
              ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode_outlined)),
              ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode_outlined)),
              ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.system,
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto_outlined)),
            ],
            selected: {settings.themePreference},
            onSelectionChanged: (Set<AppThemePreference> newSelection) {
              if (newSelection.isNotEmpty) {

                cubit.updateThemePreference(newSelection.first);
              }
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainer,
              foregroundColor:
                  colorScheme.onSurfaceVariant, 
              selectedForegroundColor: colorScheme.onPrimary,
              selectedBackgroundColor: colorScheme.primary,


            ),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}
