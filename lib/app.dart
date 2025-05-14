import 'package:beatsync_app/core/router/app_router.dart';
import 'package:beatsync_app/core/settings/app_settings.dart';
import 'package:beatsync_app/core/settings/app_settings_cubit.dart';
import 'package:beatsync_app/core/theme/app_theme.dart';
import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AppSettingsCubit>()),
        BlocProvider(create: (context) => sl<AuthCubit>()),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettings>(
        builder: (context, appSettings) {
          Locale? currentLocale;
          if (appSettings.language == AppLanguage.tr) {
            currentLocale = const Locale('tr');
          } else {
            currentLocale = const Locale('en');
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            onGenerateTitle: (BuildContext context) {
              return AppLocalizations.of(context)?.appTitle ?? 'Beatsync App';
            },
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appSettings.themeMode,
            locale: currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.themeSwitcherPageTitle ?? 'Theme Switcher'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                l10n?.currentThemeModeLabel ?? 'Current ThemeMode:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              BlocBuilder<AppSettingsCubit, AppSettings>(
                builder: (context, appSettings) {
                  return Text(
                    appSettings.themeMode.name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context
                    .read<AppSettingsCubit>()
                    .updateThemePreference(AppThemePreference.light),
                child: Text(l10n?.lightThemeButton ?? 'Light Theme'),
              ),
              ElevatedButton(
                onPressed: () => context
                    .read<AppSettingsCubit>()
                    .updateThemePreference(AppThemePreference.dark),
                child: Text(l10n?.darkThemeButton ?? 'Dark Theme'),
              ),
              ElevatedButton(
                onPressed: () => context
                    .read<AppSettingsCubit>()
                    .updateThemePreference(AppThemePreference.system),
                child: Text(l10n?.systemThemeButton ?? 'System Theme'),
              ),
              const SizedBox(height: 30),
              Text(l10n?.sampleThemedElementsLabel ?? 'Sample themed elements:'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l10n?.sampleCardText ?? 'This is a Card'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n?.sampleTextFieldLabel ?? 'Sample TextField',
                  hintText: l10n?.sampleTextFieldHint ?? 'Enter text here',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
