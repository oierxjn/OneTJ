// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OneTJ';

  @override
  String get authStateMismatch =>
      'Auth state mismatch, possible network attack';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabTimetable => 'Timetable';

  @override
  String get tabSettings => 'Settings';

  @override
  String get tabTools => 'Tools';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get timetableDayView => 'Day View';

  @override
  String get timetableWeekView => 'Week View';

  @override
  String timetableLoadFailed(Object error) {
    return 'Failed to load timetable: $error';
  }

  @override
  String get timetableNoData => 'No timetable data available';

  @override
  String timetableLastFetch(Object time) {
    return 'Last fetch: $time';
  }

  @override
  String get timetableLastFetchUnknown => '--';

  @override
  String get emptyClassesToday => 'No classes today';

  @override
  String get dashboardUpcomingTitle => 'Upcoming Courses';

  @override
  String get dashboardUpcomingEmpty => 'No upcoming courses this week';

  @override
  String get dashboardUpcomingEmptyThisWeek => 'No upcoming courses this week';

  @override
  String get dashboardUpcomingEmptyToday => 'No upcoming courses today';

  @override
  String get dashboardUpcomingEmptyByCount => 'No upcoming courses';

  @override
  String get courseDetailUnknownCourse => 'Unknown course';

  @override
  String get courseDetailSectionBasic => 'Basic Information';

  @override
  String get courseDetailSectionExtra => 'Extra Fields';

  @override
  String get courseDetailFieldCourseCode => 'Course Code';

  @override
  String get courseDetailFieldClassCode => 'Class Code';

  @override
  String get courseDetailFieldClassName => 'Class Name';

  @override
  String get courseDetailFieldTeacher => 'Teacher';

  @override
  String get courseDetailFieldDay => 'Day';

  @override
  String get courseDetailFieldTime => 'Time';

  @override
  String get courseDetailFieldPeriods => 'Periods';

  @override
  String get courseDetailFieldWeeks => 'Weeks';

  @override
  String get courseDetailFieldWeekNum => 'Week Range';

  @override
  String get courseDetailFieldRoom => 'Room';

  @override
  String get courseDetailFieldCampus => 'Campus';

  @override
  String get courseDetailFieldTeachingClassId => 'Teaching Class ID';

  @override
  String weekLabel(int week) {
    return 'Week $week';
  }

  @override
  String currentTeachingWeekText(int week) {
    return 'Current:Week $week';
  }

  @override
  String get scoreInquiryTitle => 'Score Inquiry';

  @override
  String get scoreInquirySubtitle => 'View your undergraduate scores';

  @override
  String get toolsSubtitle =>
      'Common tools and lab calculators will be collected here.';

  @override
  String get physicsLabTitle => 'Physics Lab Calculator';

  @override
  String get physicsLabToolSubtitle =>
      'Free up your hands to focus on the experiment';

  @override
  String get physicsLabSubtitle =>
      'Choose an experiment to open its calculator page.';

  @override
  String get physicsLabMichelsonTitle => 'Michelson Interferometer';

  @override
  String get physicsLabMichelsonSubtitle => 'Eyes are blind';

  @override
  String get physicsLabDiffractionGratingTitle =>
      'Diffraction Grating Wavelength';

  @override
  String get physicsLabDiffractionGratingSubtitle =>
      'Remember to turn on the mercury lamp!';

  @override
  String get physicsLabFranckHertzTitle => 'Franck-Hertz Experiment';

  @override
  String get physicsLabFranckHertzSubtitle => '160 sets of experimental data!';

  @override
  String get physicsLabFranckHertzIntroTitle => 'Experiment';

  @override
  String get physicsLabFranckHertzDescription =>
      'Fill in the experiment parameters and raw measurements, and the page will automatically identify curve features and report the peak-based, valley-based, and combined first excitation potential results.';

  @override
  String get physicsLabFranckHertzDataFlowHintLeading => 'Record';

  @override
  String get physicsLabFranckHertzDataFlowHintSeparator => ',';

  @override
  String get physicsLabFranckHertzDataFlowHintMiddle => 'first, then fill in';

  @override
  String get physicsLabFranckHertzDataFlowHintBetween =>
      'and the corresponding plate current';

  @override
  String get physicsLabFranckHertzDataFlowHintTrailing =>
      'row by row in measurement order.';

  @override
  String get physicsLabFranckHertzMetadataTitle => 'Shared Parameters';

  @override
  String get physicsLabFranckHertzMeasurementTitle => 'Raw Measurements';

  @override
  String get physicsLabFranckHertzRowLabel => 'No.';

  @override
  String get physicsLabFranckHertzActionLabel => 'Action';

  @override
  String get physicsLabFranckHertzPresetFillLabel => 'Fill Preset Values';

  @override
  String get physicsLabFranckHertzAddRowLabel => 'Add Row';

  @override
  String get physicsLabFranckHertzDeleteRowLabel => 'Delete Row';

  @override
  String get physicsLabFranckHertzClearAllLabel => 'Clear';

  @override
  String get physicsLabFranckHertzResultTitle => 'Results';

  @override
  String get physicsLabFranckHertzResultDescription =>
      'The page analyzes the completed raw measurements automatically and reports the peak-based, valley-based, and combined results.';

  @override
  String get physicsLabFranckHertzValidPointCountLabel => 'Valid points';

  @override
  String get physicsLabFranckHertzSmoothedPointCountLabel => 'Smoothed points';

  @override
  String get physicsLabFranckHertzPeakMethodTitle => 'Peak Method';

  @override
  String get physicsLabFranckHertzValleyMethodTitle => 'Valley Method';

  @override
  String get physicsLabFranckHertzPeakCountLabel => 'Detected peaks';

  @override
  String get physicsLabFranckHertzValleyCountLabel => 'Detected valleys';

  @override
  String get physicsLabFranckHertzAverageIntervalLabel => 'Average interval';

  @override
  String get physicsLabFranckHertzPeakMethodIncompleteHint =>
      'There are not enough peak points yet to produce a peak-based result.';

  @override
  String get physicsLabFranckHertzValleyMethodIncompleteHint =>
      'There are not enough valley points yet to produce a valley-based result.';

  @override
  String get physicsLabFranckHertzFinalExcitationPotentialLabel =>
      'Combined First Excitation Potential';

  @override
  String get physicsLabFranckHertzReferenceVoltageLabel => 'Reference';

  @override
  String get physicsLabFranckHertzFinalResultIncompleteHint =>
      'A combined result is available only after both the peak-based and valley-based results are valid.';

  @override
  String get physicsLabFranckHertzVoltUnit => 'V';

  @override
  String get physicsLabFranckHertzCurrentUnit => 'μA';

  @override
  String get physicsLabDiffractionGratingDescription =>
      'The first section derives the grating constant d from a known spectral line. The second and third sections reuse that d to calculate the target wavelengths. Each record accepts four raw angle readings and automatically computes two angle differences, γ, sinγ, and the final result.';

  @override
  String get physicsLabDiffractionGratingIntroTitle => 'Experiment';

  @override
  String get physicsLabDiffractionGratingFormulaTitle => 'Formula';

  @override
  String get physicsLabDiffractionGratingFormulaBody =>
      'For each record, compute two angle differences from the four raw readings, add them, divide by 4 to get γ, then use d = kλ₀/sinγ for the first section and λ = dsinγ/k for the second and third sections. Each wavelength section averages its two rows and compares the result against the entered reference wavelength.';

  @override
  String get physicsLabDiffractionGratingCalibrationHint =>
      'With the mercury yellow line wavelength known, this section uses the k = ±2 readings to calculate the grating constant d.';

  @override
  String get physicsLabDiffractionGratingCalibrationReferenceLabel =>
      'Calibration wavelength';

  @override
  String get physicsLabDiffractionGratingAverageGratingConstantLabel =>
      'Grating Constant d';

  @override
  String get physicsLabDiffractionGratingCalibrationIncompleteHint =>
      'Fill in all calibration readings and the calibration wavelength first.';

  @override
  String physicsLabDiffractionGratingWavelengthSectionTitle(int group) {
    return 'Group $group';
  }

  @override
  String get physicsLabDiffractionGratingWavelengthHint =>
      'Each section uses fixed ±1 and ±2 order rows and automatically reuses the d from section 1.';

  @override
  String get physicsLabDiffractionGratingInheritedGratingConstant =>
      'Inherited d';

  @override
  String get physicsLabDiffractionGratingReferenceLabel =>
      'Reference Wavelength';

  @override
  String physicsLabDiffractionGratingWavelengthRowTitle(int order) {
    return 'k = ±$order';
  }

  @override
  String get physicsLabDiffractionGratingAverageWavelengthLabel =>
      'Average Wavelength';

  @override
  String get physicsLabDiffractionGratingWavelengthIncompleteHint =>
      'Fill in all readings and the reference wavelength for this section first.';

  @override
  String get physicsLabDiffractionGratingNeedCalibrationHint =>
      'Complete section 1 and obtain a valid d first.';

  @override
  String get physicsLabDiffractionGratingDifferenceOneLabel => '|ψ2 - ψ1|';

  @override
  String get physicsLabDiffractionGratingDifferenceTwoLabel => '|ψ2\' - ψ1\'|';

  @override
  String get physicsLabDiffractionGratingGammaLabel => 'γ';

  @override
  String get physicsLabDiffractionGratingSinGammaLabel => 'sinγ';

  @override
  String get physicsLabDiffractionGratingDegreeHint => 'deg';

  @override
  String get physicsLabDiffractionGratingMinuteHint => 'min';

  @override
  String get physicsLabDiffractionGratingClearAllLabel => 'Clear';

  @override
  String get physicsLabDiffractionGratingPresetFillLabel =>
      'Fill Preset Values';

  @override
  String get physicsLabMichelsonDescription =>
      'Enter 10 measured positions for every 5 fringes in mm. The page computes the differences between item i+5 and item i, averages the 5 differences, divides the average difference by 75, converts the result to nm, and compares it against 623.8 nm.';

  @override
  String get physicsLabMichelsonIntroTitle => 'Experiment';

  @override
  String get physicsLabMichelsonFormulaTitle => 'Formula';

  @override
  String get physicsLabMichelsonFormulaBody =>
      'Compute 5 differences by subtracting positions 1-5 from positions 6-10 in mm, average the 5 differences, divide the average difference by 75, convert the result to nm, then calculate the relative error against 623.8 nm.';

  @override
  String get physicsLabMichelsonInputSectionTitle => 'Measurements';

  @override
  String get physicsLabMichelsonInputHint =>
      'Fill in 10 position values in measurement order. Integers and decimals are supported.';

  @override
  String get physicsLabMichelsonClearAllLabel => 'Clear';

  @override
  String get physicsLabMichelsonPresetFillLabel => 'Fill Preset Values';

  @override
  String get physicsLabMichelsonMillimeterUnit => 'mm';

  @override
  String get physicsLabMichelsonNanometerUnit => 'nm';

  @override
  String physicsLabMichelsonPositionLabel(int index) {
    return 'Position $index';
  }

  @override
  String get physicsLabMichelsonIncompleteHint =>
      'Fill in all 10 position values with valid numbers first.';

  @override
  String get physicsLabMichelsonResultSectionTitle => 'Results';

  @override
  String physicsLabMichelsonDifferenceLabel(int index, Object value) {
    return 'Difference $index: $value';
  }

  @override
  String physicsLabMichelsonDifferenceDetail(
      int differenceIndex,
      Object laterValue,
      int laterIndex,
      Object earlierValue,
      int earlierIndex,
      Object differenceValue) {
    return 'Difference $differenceIndex: Position $laterIndex $laterValue - Position $earlierIndex $earlierValue = $differenceValue';
  }

  @override
  String physicsLabMichelsonDifferenceMmDetail(
      int differenceIndex,
      int laterIndex,
      Object laterValue,
      int earlierIndex,
      Object earlierValue,
      Object differenceValue) {
    return 'Difference $differenceIndex: Position $laterIndex $laterValue - Position $earlierIndex $earlierValue = $differenceValue mm';
  }

  @override
  String physicsLabMichelsonWavelengthNmDetail(int index,
      Object differenceValue, Object divider, Object wavelengthValue) {
    return 'Wavelength $index: $differenceValue mm / $divider = $wavelengthValue nm';
  }

  @override
  String get physicsLabMichelsonAverageLabel => 'Average Difference';

  @override
  String get physicsLabMichelsonAverageWavelengthLabel => 'Final Wavelength';

  @override
  String get physicsLabMichelsonRelativeErrorLabel => 'Relative Error';

  @override
  String physicsLabMichelsonReferenceHint(Object reference) {
    return 'Reference: $reference';
  }

  @override
  String get scoresOverviewTitle => 'Overview';

  @override
  String get scoresListTitle => 'Course Scores';

  @override
  String get scoresSummaryGpa => 'GPA';

  @override
  String get scoresSummaryCredits => 'Credits';

  @override
  String get scoresSummaryFailed => 'Failed';

  @override
  String get scoresEmpty => 'No grades available';

  @override
  String scoresLoadFailed(Object error) {
    return 'Failed to load grades: $error';
  }

  @override
  String get retryLabel => 'Retry';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirmLabel => 'Are you sure you want to log out?';

  @override
  String get confirmLabel => 'Confirm';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get closeLabel => 'Close';

  @override
  String get saveLabel => 'Save';

  @override
  String get settingsMaxWeekTitle => 'Max Weeks';

  @override
  String get settingsMaxWeekSubtitle =>
      'Used by the timetable to display available weeks';

  @override
  String get settingsMaxWeekInvalidFormat => 'Max week must be a number.';

  @override
  String get settingsMaxWeekInvalidRange =>
      'Max week must be between 1 and 52.';

  @override
  String get settingsTimeSlotsTitle => 'Time Slots';

  @override
  String get settingsTimeSlotsEmpty => 'No time slots configured';

  @override
  String settingsTimeSlotsSummary(int count, Object first, Object last) {
    return '$count slots - $first to $last';
  }

  @override
  String get settingsTimeSlotsEditorTitle => 'Edit Time Slots';

  @override
  String get settingsTimeSlotsEditorHint =>
      'Tap each slot to edit start and end time. Slots must stay in chronological order and cannot overlap.';

  @override
  String get settingsTimeSlotsStartLabel => 'Start';

  @override
  String get settingsTimeSlotsEndLabel => 'End';

  @override
  String get settingsTimeSlotsInvalidEmpty => 'At least one slot is required.';

  @override
  String get settingsTimeSlotsInvalidRange =>
      'Start time must be earlier than end time.';

  @override
  String get settingsTimeSlotsInvalidOverlap =>
      'Adjacent slots must not overlap.';

  @override
  String get settingsTimeSlotsInvalidOrder =>
      'Time slots must be strictly increasing.';

  @override
  String get settingsTimeSlotsResetToDefault => 'Reset to defaults';

  @override
  String get settingsDashboardUpcomingTitle => 'Dashboard Upcoming Courses';

  @override
  String get settingsDashboardUpcomingModeThisWeek => 'This week';

  @override
  String get settingsDashboardUpcomingModeToday => 'Today';

  @override
  String get settingsDashboardUpcomingModeCount => 'By count';

  @override
  String settingsDashboardUpcomingModeCountSummary(int count) {
    return 'Show up to $count courses';
  }

  @override
  String get settingsDashboardUpcomingCountLabel => 'Course count';

  @override
  String get settingsDashboardUpcomingCountHint => 'Valid range: 1 to 20';

  @override
  String get settingsDashboardUpcomingCountInvalidFormat =>
      'Course count must be a number.';

  @override
  String get settingsDashboardUpcomingCountInvalidRange =>
      'Course count must be between 1 and 20.';

  @override
  String get settingsAdvancedSectionTitle => 'Advanced';

  @override
  String get settingsCommonSectionTitle => 'Common';

  @override
  String get settingsAppearanceSectionTitle => 'Appearance';

  @override
  String get settingsAppearanceThemeColorTitle => 'Theme color';

  @override
  String get settingsAppearanceThemeColorSystem => 'Follow system';

  @override
  String get settingsAppearanceThemeColorLight => 'Light';

  @override
  String get settingsAppearanceThemeColorDark => 'Dark';

  @override
  String get settingsAppearanceCustomColorTitle => 'Custom colors';

  @override
  String get settingsAppearanceHomeLayoutTitle => 'Home layout';

  @override
  String get settingsAppearanceHomeLayoutBottomNavigation =>
      'Bottom navigation';

  @override
  String get settingsAppearanceHomeLayoutFunctionGrid => 'Function grid home';

  @override
  String get gridHomeBackToHome => 'Back to home';

  @override
  String get colorPickerTitle => 'Color themes';

  @override
  String get colorPickerUndo => 'Undo';

  @override
  String get colorPickerShare => 'Share';

  @override
  String get colorPickerImport => 'Import';

  @override
  String get colorPickerImportTitle => 'Import color preset';

  @override
  String get colorPickerImportHint => 'Paste the shared color preset text';

  @override
  String get colorPickerImportConfirm => 'Import';

  @override
  String get colorPickerImportSuccess => 'Color preset imported';

  @override
  String get colorPickerImportInvalidFormat =>
      'Invalid format: need 4 #-separated hex colors';

  @override
  String get colorPickerImportInvalidLightSeed => 'Invalid light primary color';

  @override
  String get colorPickerPresetsTab => 'Presets';

  @override
  String get colorPickerCustomTab => 'Custom';

  @override
  String get colorPickerLightSeed => 'Light primary';

  @override
  String get colorPickerLightSecondary => 'Light secondary';

  @override
  String get colorPickerDarkSeed => 'Dark primary';

  @override
  String get colorPickerDarkSecondary => 'Dark secondary';

  @override
  String get colorPickerPresetNameHint => 'Preset name';

  @override
  String get colorPickerDeletePreset => 'Delete preset';

  @override
  String colorPickerPresetNameDefault(int n) {
    return 'Preset $n';
  }

  @override
  String get colorPickerResetToPrimary => 'Reset to primary';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutSubtitle => 'App info and project link';

  @override
  String get settingsDeveloperTitle => 'Developer Options';

  @override
  String get settingsDeveloperSubtitle => 'Diagnostics and logs';

  @override
  String get settingsDeveloperPageTitle => 'Developer Options';

  @override
  String get settingsLogsTitle => 'Logs';

  @override
  String get settingsLogsSubtitle => 'View application log files';

  @override
  String get settingsLogsEmpty => 'No logs yet';

  @override
  String get settingsLogsFileEmpty => 'The selected log file is empty';

  @override
  String get settingsLogsCurrentFileLabel => 'Current';

  @override
  String get settingsLogsSwitchFileAction => 'Switch log file';

  @override
  String settingsLogsLoadFailed(Object error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get settingsLogsExportAction => 'Export logs';

  @override
  String settingsLogsExportSuccess(Object fileName) {
    return 'Logs exported: $fileName';
  }

  @override
  String settingsLogsExportFailed(Object error) {
    return 'Failed to export logs: $error';
  }

  @override
  String get settingsLogsExportCanceled => 'Log export canceled';

  @override
  String get settingsLogsOpenFileAction => 'Open file';

  @override
  String settingsLogsOpenFileFailed(Object error) {
    return 'Failed to open exported file: $error';
  }

  @override
  String get settingsDebugEndpointTitle => 'Debug Upload Endpoint';

  @override
  String settingsDebugEndpointSubtitle(Object endpoint) {
    return 'Current endpoint: $endpoint';
  }

  @override
  String get settingsDebugEndpointDialogTitle => 'Set Debug Upload Endpoint';

  @override
  String get settingsDebugEndpointHint =>
      'Enter a full URL (http:// or https://)';

  @override
  String get settingsDebugEndpointInvalid => 'Invalid endpoint format';

  @override
  String get settingsDebugEndpointInvalidFormat =>
      'Invalid endpoint format. Please enter a full URL.';

  @override
  String get settingsDebugEndpointInvalidScheme =>
      'Endpoint scheme must be http or https.';

  @override
  String get settingsDebugUploadTitle => 'Send to Local Debug Server';

  @override
  String settingsDebugUploadSubtitle(Object endpoint) {
    return 'Send user collection data to $endpoint';
  }

  @override
  String get settingsDebugUploadSuccess => 'Sent to local debug server';

  @override
  String settingsDebugUploadFailed(Object error) {
    return 'Send failed: $error';
  }

  @override
  String get settingsUserCollectionPolicyTitle => 'User Collection Policy';

  @override
  String settingsUserCollectionPolicySummary(int selected, int total) {
    return '$selected/$total fields selected';
  }

  @override
  String get settingsUserCollectionPolicySelectAll => 'Select all';

  @override
  String get settingsUserCollectionPolicyClearAll => 'Clear all';

  @override
  String get settingsLaunchWallpaperTitle => 'Launch Wallpaper';

  @override
  String get settingsLaunchWallpaperDefaultSummary =>
      'Using built-in default wallpaper';

  @override
  String get settingsLaunchWallpaperCustomSummary => 'Using custom wallpaper';

  @override
  String get settingsLaunchWallpaperEditorCurrentTitle => 'Current selection';

  @override
  String get settingsLaunchWallpaperLibraryEmpty => 'No local wallpapers yet';

  @override
  String get settingsLaunchWallpaperLoadingPreview => 'Loading preview...';

  @override
  String get settingsLaunchWallpaperPreviewLoadFailed =>
      'Preview failed to load';

  @override
  String get settingsLaunchWallpaperPreviewUnavailable =>
      'Wallpaper file is unavailable';

  @override
  String get settingsLaunchWallpaperRenameAction => 'Rename';

  @override
  String get settingsLaunchWallpaperRenameTitle => 'Rename wallpaper';

  @override
  String get settingsLaunchWallpaperRenameHint => 'Wallpaper name';

  @override
  String get settingsLaunchWallpaperDeleteAction => 'Delete';

  @override
  String get settingsLaunchWallpaperDeleteTitle => 'Delete wallpaper';

  @override
  String settingsLaunchWallpaperDeleteBody(String name) {
    return 'Delete \"$name\" from local wallpaper library?';
  }

  @override
  String get settingsLaunchWallpaperPickAction => 'Choose from gallery';

  @override
  String get settingsLaunchWallpaperPickSubtitle =>
      'Pick an image from the system gallery for the launch screen wallpaper';

  @override
  String get settingsLaunchWallpaperResetAction => 'Restore default wallpaper';

  @override
  String get settingsLaunchWallpaperResetSubtitle =>
      'Switch back to the built-in launch screen wallpaper';

  @override
  String get settingsLaunchWallpaperPickSuccess =>
      'Custom launch wallpaper selected';

  @override
  String get settingsLaunchWallpaperResetDone =>
      'Launch wallpaper restored to default';

  @override
  String get settingsUserCollectionFieldUserid => 'Student ID';

  @override
  String get settingsUserCollectionFieldUsername => 'Name';

  @override
  String get settingsUserCollectionFieldClientVersion => 'Client version';

  @override
  String get settingsUserCollectionFieldDeviceBrand => 'Device brand';

  @override
  String get settingsUserCollectionFieldDeviceModel => 'Device model';

  @override
  String get settingsUserCollectionFieldDeptName => 'Department';

  @override
  String get settingsUserCollectionFieldSchoolName => 'School';

  @override
  String get settingsUserCollectionFieldGender => 'Gender';

  @override
  String get settingsUserCollectionFieldPlatform => 'Platform';

  @override
  String get settingsResetTitle => 'Reset Settings';

  @override
  String get settingsResetSubtitle => 'Restore all settings to defaults';

  @override
  String get settingsResetConfirmTitle => 'Reset all settings?';

  @override
  String get settingsResetConfirmLabel =>
      'This only resets app settings and does not affect your account or cache.';

  @override
  String get settingsDataMigrationTitle => 'Migrate Local Data';

  @override
  String get settingsDataMigrationSubtitle =>
      'Migrate local data from the legacy directory to the new directory';

  @override
  String get settingsDataMigrationLoading => 'Processing, please wait';

  @override
  String get settingsDataMigrationConfirmTitle => 'Migrate local data now?';

  @override
  String get settingsDataMigrationConfirmBody =>
      'This will copy Hive data from the legacy directory to the new directory. Please restart the app after migration.';

  @override
  String get settingsDataMigrationSuccess => 'Data migration completed';

  @override
  String get settingsDataMigrationNoData => 'No legacy data found to migrate';

  @override
  String get settingsDataMigrationFailed =>
      'Data migration failed. Please try again later';

  @override
  String get settingsDataMigrationRestartHint =>
      'Please restart the app to apply changes';

  @override
  String get settingsDataCleanupAction => 'Clean Legacy Cache';

  @override
  String get settingsDataCleanupSuccess => 'Legacy data cache cleaned';

  @override
  String get settingsDataCleanupNoData => 'No legacy data cache found';

  @override
  String get settingsDataCleanupFailed =>
      'Failed to clean legacy data cache. Please try again later';

  @override
  String get settingsResetDone => 'Settings reset to defaults';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get aboutDescription =>
      'A third-party client for Tongji University services.';

  @override
  String get aboutAppNameLabel => 'App Name';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutBuildLabel => 'Build Number';

  @override
  String get aboutRepoLabel => 'Project Repository';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copyFailed => 'Copy failed';

  @override
  String get aboutCopied => 'Repository link copied';

  @override
  String get aboutQqGroupTitle => 'QQ Discussion Group';

  @override
  String get aboutQqGroupSubtitle => 'Tap to view the QR code';

  @override
  String get aboutQqGroupNumberLabel => 'Group Number';

  @override
  String get aboutQqGroupCopyLabel => 'Copy Group Number';

  @override
  String get aboutQqGroupCopied => 'QQ group number copied';

  @override
  String get aboutContributorsTitle => 'Contributors';

  @override
  String get aboutAcknowledgementsTitle => 'Acknowledgements';

  @override
  String get aboutAckFlutterDescription =>
      'Flutter, Google\'s open-source cross-platform UI framework that serves as this project\'s foundation.';

  @override
  String get aboutAckTjpbDescription =>
      'An internet team guided by the Information Office of Tongji University, providing technical support for this project.';

  @override
  String get appUpdateCheckTitle => 'Check for updates';

  @override
  String get appUpdateCheckSubtitle =>
      'Check the latest version and install package';

  @override
  String get appUpdateAlreadyLatest => 'You are on the latest version';

  @override
  String appUpdateDialogTitle(Object version) {
    return 'New version available: $version';
  }

  @override
  String get appUpdateNotesEmpty => 'No release notes';

  @override
  String get appUpdateNow => 'Update now';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appUpdateSkipVersion => 'Skip this version';

  @override
  String get appUpdateDownloadingTitle => 'Downloading update';

  @override
  String get appUpdateDownloadingBody =>
      'Downloading package and verifying integrity...';

  @override
  String get appUpdateVerifyingBody => 'Verifying package integrity...';

  @override
  String get appUpdateInstallingBody => 'Starting installer...';

  @override
  String appUpdateDownloadedBytesKnown(Object received, Object total) {
    return '$received / $total';
  }

  @override
  String appUpdateDownloadedBytesUnknown(Object received) {
    return 'Downloaded $received';
  }

  @override
  String get appUpdateInstallTriggered =>
      'Installer has been started, please follow system prompts';

  @override
  String get appUpdateInstallPermissionRequired =>
      'Allow installs from unknown apps in system settings. Installation will resume automatically when you return.';

  @override
  String appUpdateFailed(Object error) {
    return 'Update failed: $error';
  }

  @override
  String appUpdateMigrationTitle(Object version) {
    return 'Migration required: $version';
  }

  @override
  String appUpdateMigrationSummary(Object currentVersion) {
    return 'Your current version $currentVersion is no longer supported. The new release must be installed as a separate app and cannot overwrite this one directly.';
  }

  @override
  String get appUpdateMigrationStepsTitle =>
      'Please follow these steps (suggested to take screenshots of each step):';

  @override
  String get appUpdateMigrationStepDownload =>
      '1. Tap \"Download new app\" to download the new installer in your browser.';

  @override
  String get appUpdateMigrationStepLocate =>
      '2. After the download completes, find the installer in your browser downloads or notification tray.';

  @override
  String get appUpdateMigrationStepUninstall =>
      '3. Uninstall the current old app first.';

  @override
  String get appUpdateMigrationStepInstall =>
      '4. Then open the downloaded installer and install the new app.';

  @override
  String get appUpdateMigrationRisk =>
      'After uninstalling the old app, local cache, login state, and downloaded files may be lost.';

  @override
  String get appUpdateMigrationCopyLink => 'Copy download link';

  @override
  String get appUpdateMigrationDownloadNow =>
      'Download new app from external source';

  @override
  String get appUpdateMigrationLinkCopied => 'Download link copied';

  @override
  String appUpdateMigrationOpenDownloadFailed(Object url) {
    return 'Unable to open the download link. Copy and open it manually in your browser: $url';
  }

  @override
  String get cetScoreTitle => 'CET Scores';

  @override
  String get cetScoreSubtitle => 'View your College English Test scores.';

  @override
  String get cetScoreToolSubtitle => 'View CET-4 and CET-6 scores';

  @override
  String get cetScoreEmpty => 'No CET score data is available.';

  @override
  String get cetScoreTicketNumberLabel => 'Ticket No.';

  @override
  String get cetScoreStudentLabel => 'Student';

  @override
  String get cetScoreSubjectLabel => 'Written test';

  @override
  String get cetScoreOralScoreLabel => 'Oral test';
}
