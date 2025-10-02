import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../core/localization/localization_service.dart';
import '../../core/providers/app_providers.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/theme_app.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/settings_section.dart';
import '../../shared/widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: 'settings.title'.tr(), showBackButton: true),
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, Colors.transparent],
              stops: [0.0, 0.2],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGeneralSettings(context, ref, settings),
                const SizedBox(height: 16),
                _buildAudioSettings(context, ref, settings),
                const SizedBox(height: 16),
                _buildDisplaySettings(context, ref, settings, theme, language),
                const SizedBox(height: 16),
                _buildAccountSettings(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return SettingsSection(
      title: 'settings.general'.tr(),
      children: [
        SettingsTile.switchTile(
          title: 'settings.soundEffects'.tr(),
          subtitle: 'settings.soundEffectsDesc'.tr(),
          leading: Icons.volume_up_outlined,
          value: settings.soundEffects,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setSoundEffects(value);
          },
        ),
        SettingsTile.switchTile(
          title: 'settings.backgroundMusic'.tr(),
          subtitle: 'settings.backgroundMusicDesc'.tr(),
          leading: Icons.music_note_outlined,
          value: settings.backgroundMusic,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setBackgroundMusic(value);
          },
        ),
        SettingsTile.switchTile(
          title: 'settings.animations'.tr(),
          subtitle: 'settings.animationsDesc'.tr(),
          leading: Icons.animation_outlined,
          value: settings.animations,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setAnimations(value);
          },
        ),
      ],
    );
  }

  Widget _buildAudioSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return SettingsSection(
      title: 'settings.audio'.tr(),
      children: [
        SettingsTile.navigationTile(
          title: 'settings.voiceSettings'.tr(),
          subtitle: 'settings.voiceSettingsDesc'.tr(),
          leading: Icons.record_voice_over_outlined,
          onTap: () => _showVoiceSettingsDialog(context, ref),
        ),
        SettingsTile.sliderTile(
          title: 'settings.speechRate'.tr(),
          subtitle: 'settings.speechRateDesc'.tr(),
          leading: Icons.speed_outlined,
          value: settings.speechRate,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setSpeechRate(value);
          },
          min: 0.1,
          max: 2,
          divisions: 19,
        ),
        SettingsTile.sliderTile(
          title: 'settings.speechPitch'.tr(),
          subtitle: 'settings.speechPitchDesc'.tr(),
          leading: Icons.tune_outlined,
          value: settings.speechPitch,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setSpeechPitch(value);
          },
          min: 0.5,
          max: 2,
          divisions: 15,
        ),
        SettingsTile.sliderTile(
          title: 'settings.speechVolume'.tr(),
          subtitle: 'settings.speechVolumeDesc'.tr(),
          leading: Icons.volume_up_outlined,
          value: settings.speechVolume,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setSpeechVolume(value);
          },
          divisions: 10,
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    ThemeMode theme,
    Locale language,
  ) {
    return SettingsSection(
      title: 'settings.display'.tr(),
      children: [
        SettingsTile.navigationTile(
          title: 'settings.language'.tr(),
          subtitle: 'settings.languageDesc'.tr(),
          leading: Icons.language_outlined,
          onTap: () => _showLanguageDialog(context, ref, language),
        ),
        SettingsTile.navigationTile(
          title: 'settings.theme'.tr(),
          subtitle: 'settings.themeDesc'.tr(),
          leading: Icons.palette_outlined,
          onTap: () => _showThemeDialog(context, ref, theme),
        ),
        SettingsTile.sliderTile(
          title: 'settings.fontSize'.tr(),
          subtitle: 'settings.fontSizeDesc'.tr(),
          leading: Icons.text_fields_outlined,
          value: settings.fontSize,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setFontSize(value);
          },
          min: 12,
          max: 24,
          divisions: 12,
        ),
        SettingsTile.switchTile(
          title: 'settings.highContrast'.tr(),
          subtitle: 'settings.highContrastDesc'.tr(),
          leading: Icons.contrast_outlined,
          value: settings.highContrast,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setHighContrast(value);
          },
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      title: 'settings.account'.tr(),
      children: [
        SettingsTile.navigationTile(
          title: 'settings.profile'.tr(),
          subtitle: 'settings.manageProfile'.tr(),
          leading: Icons.person_outline,
          onTap: () => context.go(AppRoutes.profile),
        ),
        SettingsTile.navigationTile(
          title: 'settings.resetSettings'.tr(),
          subtitle: 'settings.resetSettingsDesc'.tr(),
          leading: Icons.restore_outlined,
          onTap: () => _showResetDialog(context, ref),
        ),
        SettingsTile.navigationTile(
          title: 'auth.signOut'.tr(),
          subtitle: 'auth.signOutDesc'.tr(),
          leading: Icons.logout_outlined,
          textColor: AppTheme.errorColor,
          onTap: () => _showSignOutDialog(context, ref),
        ),
      ],
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  final newLocale = Locale(value);
                  ref.read(languageProvider.notifier).setLanguage(newLocale);
                  LocalizationService.changeLanguage(context, newLocale);
                  context.pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  final newLocale = Locale(value);
                  ref.read(languageProvider.notifier).setLanguage(newLocale);
                  LocalizationService.changeLanguage(context, newLocale);
                  context.pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.theme'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text('settings.lightTheme'.tr()),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('settings.darkTheme'.tr()),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('settings.systemTheme'.tr()),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showVoiceSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.voiceSettings'.tr()),
        content: Text('settings.voiceSettingsDesc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.resetSettings'.tr()),
        content: Text('settings.resetSettingsDesc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetSettings();
              Navigator.of(context).pop();
            },
            child: Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth.signOut'.tr()),
        content: Text('auth.signOutDesc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              // Sign out logic here
              if (await ref.read(authStateProvider.notifier).signOut()) {
                if (context.mounted) {
                  context.goNamed('login');
                }
              }
            },
            child: Text('auth.signOut'.tr()),
          ),
        ],
      ),
    );
  }
}
