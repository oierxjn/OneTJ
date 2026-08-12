import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/settings/views/widgets/home_layout_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';
import 'package:onetj/features/settings/views/widgets/theme_color_card.dart';
import 'package:onetj/features/settings/views/widgets/upcoming_courses_card.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/theme_preferences.dart';

class SettingsSections extends StatelessWidget {
  const SettingsSections({
    required this.l10n,
    required this.maxWeekController,
    required this.dashboardCountController,
    required this.maxWeekDirty,
    required this.maxWeekInvalid,
    required this.timeSlotDirty,
    required this.upcomingDirty,
    required this.upcomingInvalid,
    required this.userCollectionDirty,
    required this.launchWallpaperDirty,
    required this.timeSlotSummary,
    required this.dashboardUpcomingSummary,
    required this.userCollectionSummary,
    required this.launchWallpaperSummary,
    required this.upcomingMode,
    required this.themeColor,
    required this.homeLayout,
    required this.enabled,
    required this.hiveMigrationLoading,
    required this.hiveMigrationStateLoaded,
    required this.legacyHiveDataAvailable,
    required this.onMaxWeekChanged,
    required this.onUpcomingModeChanged,
    required this.onDashboardCountChanged,
    required this.onThemeColorChanged,
    required this.onHomeLayoutChanged,
    required this.onOpenTimeSlotEditor,
    required this.onOpenUserCollectionPolicy,
    required this.onOpenLaunchWallpaperEditor,
    required this.onOpenCustomColor,
    required this.onOpenAbout,
    required this.onReset,
    required this.onTapDataMigration,
    required this.onOpenDeveloper,
    required this.onLogout,
    required this.logoutLoading,
    super.key,
  });

  final AppLocalizations l10n;
  final TextEditingController maxWeekController;
  final TextEditingController dashboardCountController;
  final bool maxWeekDirty;
  final bool maxWeekInvalid;
  final bool timeSlotDirty;
  final bool upcomingDirty;
  final bool upcomingInvalid;
  final bool userCollectionDirty;
  final bool launchWallpaperDirty;
  final String timeSlotSummary;
  final String dashboardUpcomingSummary;
  final String userCollectionSummary;
  final String launchWallpaperSummary;
  final DashboardUpcomingMode upcomingMode;
  final ThemeMode themeColor;
  final HomeLayout homeLayout;
  final bool enabled;
  final bool hiveMigrationLoading;
  final bool hiveMigrationStateLoaded;
  final bool legacyHiveDataAvailable;
  final ValueChanged<String> onMaxWeekChanged;
  final ValueChanged<DashboardUpcomingMode> onUpcomingModeChanged;
  final ValueChanged<String> onDashboardCountChanged;
  final ValueChanged<ThemeMode> onThemeColorChanged;
  final ValueChanged<HomeLayout> onHomeLayoutChanged;
  final VoidCallback onOpenTimeSlotEditor;
  final VoidCallback onOpenUserCollectionPolicy;
  final VoidCallback onOpenLaunchWallpaperEditor;
  final VoidCallback onOpenCustomColor;
  final VoidCallback onOpenAbout;
  final VoidCallback onReset;
  final VoidCallback onTapDataMigration;
  final VoidCallback onOpenDeveloper;
  final VoidCallback onLogout;
  final bool logoutLoading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _SettingsSectionTitle(title: l10n.settingsCommonSectionTitle),
        const SizedBox(height: 8),
        _buildMaxWeekCard(),
        const SizedBox(height: 12),
        _buildTimeSlotCard(),
        const SizedBox(height: 12),
        _buildDashboardUpcomingCard(),
        const SizedBox(height: 12),
        _buildUserCollectionPolicyCard(),
        const SizedBox(height: 12),
        _buildLaunchWallpaperCard(),
        const SizedBox(height: 12),
        _buildAboutCard(),
        const SizedBox(height: 24),
        _SettingsSectionTitle(title: l10n.settingsAppearanceSectionTitle),
        const SizedBox(height: 8),
        ThemeColorCard(
          l10n: l10n,
          color: themeColor,
          enabled: enabled,
          onColorChanged: onThemeColorChanged,
        ),
        const SizedBox(height: 12),
        HomeLayoutCard(
          l10n: l10n,
          layout: homeLayout,
          enabled: enabled,
          onChanged: onHomeLayoutChanged,
        ),
        const SizedBox(height: 12),
        _buildCustomColorCard(),
        const SizedBox(height: 24),
        _SettingsSectionTitle(title: l10n.settingsAdvancedSectionTitle),
        const SizedBox(height: 8),
        _buildResetCard(),
        const SizedBox(height: 12),
        _buildDataMigrationCard(),
        const SizedBox(height: 12),
        _buildDeveloperCard(),
        const SizedBox(height: 24),
        Center(
          child: FilledButton(
            onPressed: logoutLoading ? null : onLogout,
            child: Text(l10n.logOut),
          ),
        ),
      ],
    );
  }

  SettingsCardStatus _status({required bool isDirty, bool hasError = false}) {
    if (hasError) {
      return SettingsCardStatus.error;
    }
    return isDirty ? SettingsCardStatus.dirty : SettingsCardStatus.normal;
  }

  Widget _buildMaxWeekCard() {
    return SettingsCard(
      status: _status(isDirty: maxWeekDirty, hasError: maxWeekInvalid),
      title: Text(l10n.settingsMaxWeekTitle),
      subtitle: Text(l10n.settingsMaxWeekSubtitle),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: maxWeekController,
          onChanged: onMaxWeekChanged,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          enabled: enabled,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard() => SettingsCard(
        status: _status(isDirty: timeSlotDirty),
        leading: const Icon(Icons.schedule),
        title: Text(l10n.settingsTimeSlotsTitle),
        subtitle: Text(timeSlotSummary),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onOpenTimeSlotEditor : null,
      );

  Widget _buildDashboardUpcomingCard() => UpcomingCoursesCard(
        l10n: l10n,
        mode: upcomingMode,
        countController: dashboardCountController,
        enabled: enabled,
        summaryText: dashboardUpcomingSummary,
        onModeChanged: onUpcomingModeChanged,
        onCountChanged: onDashboardCountChanged,
        status: _status(isDirty: upcomingDirty, hasError: upcomingInvalid),
      );

  Widget _buildUserCollectionPolicyCard() => SettingsCard(
        status: _status(isDirty: userCollectionDirty),
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(l10n.settingsUserCollectionPolicyTitle),
        subtitle: Text(userCollectionSummary),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onOpenUserCollectionPolicy : null,
      );

  Widget _buildLaunchWallpaperCard() => SettingsCard(
        status: _status(isDirty: launchWallpaperDirty),
        leading: const Icon(Icons.wallpaper_outlined),
        title: Text(l10n.settingsLaunchWallpaperTitle),
        subtitle: Text(launchWallpaperSummary),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onOpenLaunchWallpaperEditor : null,
      );

  Widget _buildAboutCard() => SettingsCard(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.settingsAboutTitle),
        subtitle: Text(l10n.settingsAboutSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenAbout,
      );

  Widget _buildCustomColorCard() => SettingsCard(
        leading: const Icon(Icons.colorize),
        title: Text(l10n.settingsAppearanceCustomColorTitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onOpenCustomColor : null,
      );

  Widget _buildResetCard() => SettingsCard(
        leading: const Icon(Icons.restore),
        title: Text(l10n.settingsResetTitle),
        subtitle: Text(l10n.settingsResetSubtitle),
        onTap: enabled ? onReset : null,
      );

  Widget _buildDataMigrationCard() {
    final bool canTap = enabled && !hiveMigrationLoading;
    final String subtitle;
    if (hiveMigrationLoading) {
      subtitle = l10n.settingsDataMigrationLoading;
    } else if (!hiveMigrationStateLoaded) {
      subtitle = l10n.settingsDataMigrationSubtitle;
    } else if (!legacyHiveDataAvailable) {
      subtitle = l10n.settingsDataMigrationNoData;
    } else {
      subtitle = l10n.settingsDataMigrationSubtitle;
    }
    return SettingsCard(
      leading: const Icon(Icons.move_down),
      title: Text(l10n.settingsDataMigrationTitle),
      subtitle: Text(subtitle),
      onTap: canTap ? onTapDataMigration : null,
    );
  }

  Widget _buildDeveloperCard() => SettingsCard(
        leading: const Icon(Icons.developer_mode),
        title: Text(l10n.settingsDeveloperTitle),
        subtitle: Text(l10n.settingsDeveloperSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenDeveloper,
      );
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
