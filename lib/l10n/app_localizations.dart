import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OneTJ'**
  String get appTitle;

  /// No description provided for @authStateMismatch.
  ///
  /// In en, this message translates to:
  /// **'Auth state mismatch, possible network attack'**
  String get authStateMismatch;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get tabTimetable;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @tabTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tabTools;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @timetableDayView.
  ///
  /// In en, this message translates to:
  /// **'Day View'**
  String get timetableDayView;

  /// No description provided for @timetableWeekView.
  ///
  /// In en, this message translates to:
  /// **'Week View'**
  String get timetableWeekView;

  /// No description provided for @timetableLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load timetable: {error}'**
  String timetableLoadFailed(Object error);

  /// No description provided for @timetableNoData.
  ///
  /// In en, this message translates to:
  /// **'No timetable data available'**
  String get timetableNoData;

  /// No description provided for @timetableLastFetch.
  ///
  /// In en, this message translates to:
  /// **'Last fetch: {time}'**
  String timetableLastFetch(Object time);

  /// No description provided for @timetableLastFetchUnknown.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get timetableLastFetchUnknown;

  /// No description provided for @emptyClassesToday.
  ///
  /// In en, this message translates to:
  /// **'No classes today'**
  String get emptyClassesToday;

  /// No description provided for @dashboardUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Courses'**
  String get dashboardUpcomingTitle;

  /// No description provided for @dashboardUpcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No upcoming courses this week'**
  String get dashboardUpcomingEmpty;

  /// No description provided for @dashboardUpcomingEmptyThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No upcoming courses this week'**
  String get dashboardUpcomingEmptyThisWeek;

  /// No description provided for @dashboardUpcomingEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'No upcoming courses today'**
  String get dashboardUpcomingEmptyToday;

  /// No description provided for @dashboardUpcomingEmptyByCount.
  ///
  /// In en, this message translates to:
  /// **'No upcoming courses'**
  String get dashboardUpcomingEmptyByCount;

  /// No description provided for @courseDetailUnknownCourse.
  ///
  /// In en, this message translates to:
  /// **'Unknown course'**
  String get courseDetailUnknownCourse;

  /// No description provided for @courseDetailSectionBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get courseDetailSectionBasic;

  /// No description provided for @courseDetailSectionExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra Fields'**
  String get courseDetailSectionExtra;

  /// No description provided for @courseDetailFieldCourseCode.
  ///
  /// In en, this message translates to:
  /// **'Course Code'**
  String get courseDetailFieldCourseCode;

  /// No description provided for @courseDetailFieldClassCode.
  ///
  /// In en, this message translates to:
  /// **'Class Code'**
  String get courseDetailFieldClassCode;

  /// No description provided for @courseDetailFieldClassName.
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get courseDetailFieldClassName;

  /// No description provided for @courseDetailFieldTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get courseDetailFieldTeacher;

  /// No description provided for @courseDetailFieldDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get courseDetailFieldDay;

  /// No description provided for @courseDetailFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get courseDetailFieldTime;

  /// No description provided for @courseDetailFieldPeriods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get courseDetailFieldPeriods;

  /// No description provided for @courseDetailFieldWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get courseDetailFieldWeeks;

  /// No description provided for @courseDetailFieldWeekNum.
  ///
  /// In en, this message translates to:
  /// **'Week Range'**
  String get courseDetailFieldWeekNum;

  /// No description provided for @courseDetailFieldRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get courseDetailFieldRoom;

  /// No description provided for @courseDetailFieldCampus.
  ///
  /// In en, this message translates to:
  /// **'Campus'**
  String get courseDetailFieldCampus;

  /// No description provided for @courseDetailFieldTeachingClassId.
  ///
  /// In en, this message translates to:
  /// **'Teaching Class ID'**
  String get courseDetailFieldTeachingClassId;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weekLabel(int week);

  /// No description provided for @currentTeachingWeekText.
  ///
  /// In en, this message translates to:
  /// **'Current:Week {week}'**
  String currentTeachingWeekText(int week);

  /// No description provided for @scoreInquiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Inquiry'**
  String get scoreInquiryTitle;

  /// No description provided for @scoreInquirySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your undergraduate scores'**
  String get scoreInquirySubtitle;

  /// No description provided for @toolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Common tools and lab calculators will be collected here.'**
  String get toolsSubtitle;

  /// No description provided for @physicsLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Physics Lab Calculator'**
  String get physicsLabTitle;

  /// No description provided for @physicsLabToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free up your hands to focus on the experiment'**
  String get physicsLabToolSubtitle;

  /// No description provided for @physicsLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an experiment to open its calculator page.'**
  String get physicsLabSubtitle;

  /// No description provided for @physicsLabMichelsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Michelson Interferometer'**
  String get physicsLabMichelsonTitle;

  /// No description provided for @physicsLabMichelsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Eyes are blind'**
  String get physicsLabMichelsonSubtitle;

  /// No description provided for @physicsLabDiffractionGratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Diffraction Grating Wavelength'**
  String get physicsLabDiffractionGratingTitle;

  /// No description provided for @physicsLabDiffractionGratingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to turn on the mercury lamp!'**
  String get physicsLabDiffractionGratingSubtitle;

  /// No description provided for @physicsLabFranckHertzTitle.
  ///
  /// In en, this message translates to:
  /// **'Franck-Hertz Experiment'**
  String get physicsLabFranckHertzTitle;

  /// No description provided for @physicsLabFranckHertzSubtitle.
  ///
  /// In en, this message translates to:
  /// **'160 sets of experimental data!'**
  String get physicsLabFranckHertzSubtitle;

  /// No description provided for @physicsLabFranckHertzIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get physicsLabFranckHertzIntroTitle;

  /// No description provided for @physicsLabFranckHertzDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in the experiment parameters and raw measurements, and the page will automatically identify curve features and report the peak-based, valley-based, and combined first excitation potential results.'**
  String get physicsLabFranckHertzDescription;

  /// No description provided for @physicsLabFranckHertzDataFlowHintLeading.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get physicsLabFranckHertzDataFlowHintLeading;

  /// No description provided for @physicsLabFranckHertzDataFlowHintSeparator.
  ///
  /// In en, this message translates to:
  /// **','**
  String get physicsLabFranckHertzDataFlowHintSeparator;

  /// No description provided for @physicsLabFranckHertzDataFlowHintMiddle.
  ///
  /// In en, this message translates to:
  /// **'first, then fill in'**
  String get physicsLabFranckHertzDataFlowHintMiddle;

  /// No description provided for @physicsLabFranckHertzDataFlowHintBetween.
  ///
  /// In en, this message translates to:
  /// **'and the corresponding plate current'**
  String get physicsLabFranckHertzDataFlowHintBetween;

  /// No description provided for @physicsLabFranckHertzDataFlowHintTrailing.
  ///
  /// In en, this message translates to:
  /// **'row by row in measurement order.'**
  String get physicsLabFranckHertzDataFlowHintTrailing;

  /// No description provided for @physicsLabFranckHertzMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared Parameters'**
  String get physicsLabFranckHertzMetadataTitle;

  /// No description provided for @physicsLabFranckHertzMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw Measurements'**
  String get physicsLabFranckHertzMeasurementTitle;

  /// No description provided for @physicsLabFranckHertzRowLabel.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get physicsLabFranckHertzRowLabel;

  /// No description provided for @physicsLabFranckHertzActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get physicsLabFranckHertzActionLabel;

  /// No description provided for @physicsLabFranckHertzPresetFillLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill Preset Values'**
  String get physicsLabFranckHertzPresetFillLabel;

  /// No description provided for @physicsLabFranckHertzAddRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Row'**
  String get physicsLabFranckHertzAddRowLabel;

  /// No description provided for @physicsLabFranckHertzDeleteRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Row'**
  String get physicsLabFranckHertzDeleteRowLabel;

  /// No description provided for @physicsLabFranckHertzClearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get physicsLabFranckHertzClearAllLabel;

  /// No description provided for @physicsLabFranckHertzResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get physicsLabFranckHertzResultTitle;

  /// No description provided for @physicsLabFranckHertzResultDescription.
  ///
  /// In en, this message translates to:
  /// **'The page analyzes the completed raw measurements automatically and reports the peak-based, valley-based, and combined results.'**
  String get physicsLabFranckHertzResultDescription;

  /// No description provided for @physicsLabFranckHertzValidPointCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid points'**
  String get physicsLabFranckHertzValidPointCountLabel;

  /// No description provided for @physicsLabFranckHertzSmoothedPointCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Smoothed points'**
  String get physicsLabFranckHertzSmoothedPointCountLabel;

  /// No description provided for @physicsLabFranckHertzPeakMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Method'**
  String get physicsLabFranckHertzPeakMethodTitle;

  /// No description provided for @physicsLabFranckHertzValleyMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Valley Method'**
  String get physicsLabFranckHertzValleyMethodTitle;

  /// No description provided for @physicsLabFranckHertzPeakCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected peaks'**
  String get physicsLabFranckHertzPeakCountLabel;

  /// No description provided for @physicsLabFranckHertzValleyCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected valleys'**
  String get physicsLabFranckHertzValleyCountLabel;

  /// No description provided for @physicsLabFranckHertzAverageIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Average interval'**
  String get physicsLabFranckHertzAverageIntervalLabel;

  /// No description provided for @physicsLabFranckHertzPeakMethodIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'There are not enough peak points yet to produce a peak-based result.'**
  String get physicsLabFranckHertzPeakMethodIncompleteHint;

  /// No description provided for @physicsLabFranckHertzValleyMethodIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'There are not enough valley points yet to produce a valley-based result.'**
  String get physicsLabFranckHertzValleyMethodIncompleteHint;

  /// No description provided for @physicsLabFranckHertzFinalExcitationPotentialLabel.
  ///
  /// In en, this message translates to:
  /// **'Combined First Excitation Potential'**
  String get physicsLabFranckHertzFinalExcitationPotentialLabel;

  /// No description provided for @physicsLabFranckHertzReferenceVoltageLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get physicsLabFranckHertzReferenceVoltageLabel;

  /// No description provided for @physicsLabFranckHertzFinalResultIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'A combined result is available only after both the peak-based and valley-based results are valid.'**
  String get physicsLabFranckHertzFinalResultIncompleteHint;

  /// No description provided for @physicsLabFranckHertzVoltUnit.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get physicsLabFranckHertzVoltUnit;

  /// No description provided for @physicsLabFranckHertzCurrentUnit.
  ///
  /// In en, this message translates to:
  /// **'μA'**
  String get physicsLabFranckHertzCurrentUnit;

  /// No description provided for @physicsLabDiffractionGratingDescription.
  ///
  /// In en, this message translates to:
  /// **'The first section derives the grating constant d from a known spectral line. The second and third sections reuse that d to calculate the target wavelengths. Each record accepts four raw angle readings and automatically computes two angle differences, γ, sinγ, and the final result.'**
  String get physicsLabDiffractionGratingDescription;

  /// No description provided for @physicsLabDiffractionGratingIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get physicsLabDiffractionGratingIntroTitle;

  /// No description provided for @physicsLabDiffractionGratingFormulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get physicsLabDiffractionGratingFormulaTitle;

  /// No description provided for @physicsLabDiffractionGratingFormulaBody.
  ///
  /// In en, this message translates to:
  /// **'For each record, compute two angle differences from the four raw readings, add them, divide by 4 to get γ, then use d = kλ₀/sinγ for the first section and λ = dsinγ/k for the second and third sections. Each wavelength section averages its two rows and compares the result against the entered reference wavelength.'**
  String get physicsLabDiffractionGratingFormulaBody;

  /// No description provided for @physicsLabDiffractionGratingCalibrationHint.
  ///
  /// In en, this message translates to:
  /// **'With the mercury yellow line wavelength known, this section uses the k = ±2 readings to calculate the grating constant d.'**
  String get physicsLabDiffractionGratingCalibrationHint;

  /// No description provided for @physicsLabDiffractionGratingCalibrationReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Calibration wavelength'**
  String get physicsLabDiffractionGratingCalibrationReferenceLabel;

  /// No description provided for @physicsLabDiffractionGratingAverageGratingConstantLabel.
  ///
  /// In en, this message translates to:
  /// **'Grating Constant d'**
  String get physicsLabDiffractionGratingAverageGratingConstantLabel;

  /// No description provided for @physicsLabDiffractionGratingCalibrationIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in all calibration readings and the calibration wavelength first.'**
  String get physicsLabDiffractionGratingCalibrationIncompleteHint;

  /// No description provided for @physicsLabDiffractionGratingWavelengthSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Group {group}'**
  String physicsLabDiffractionGratingWavelengthSectionTitle(int group);

  /// No description provided for @physicsLabDiffractionGratingWavelengthHint.
  ///
  /// In en, this message translates to:
  /// **'Each section uses fixed ±1 and ±2 order rows and automatically reuses the d from section 1.'**
  String get physicsLabDiffractionGratingWavelengthHint;

  /// No description provided for @physicsLabDiffractionGratingInheritedGratingConstant.
  ///
  /// In en, this message translates to:
  /// **'Inherited d'**
  String get physicsLabDiffractionGratingInheritedGratingConstant;

  /// No description provided for @physicsLabDiffractionGratingReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference Wavelength'**
  String get physicsLabDiffractionGratingReferenceLabel;

  /// No description provided for @physicsLabDiffractionGratingWavelengthRowTitle.
  ///
  /// In en, this message translates to:
  /// **'k = ±{order}'**
  String physicsLabDiffractionGratingWavelengthRowTitle(int order);

  /// No description provided for @physicsLabDiffractionGratingAverageWavelengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Wavelength'**
  String get physicsLabDiffractionGratingAverageWavelengthLabel;

  /// No description provided for @physicsLabDiffractionGratingWavelengthIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in all readings and the reference wavelength for this section first.'**
  String get physicsLabDiffractionGratingWavelengthIncompleteHint;

  /// No description provided for @physicsLabDiffractionGratingNeedCalibrationHint.
  ///
  /// In en, this message translates to:
  /// **'Complete section 1 and obtain a valid d first.'**
  String get physicsLabDiffractionGratingNeedCalibrationHint;

  /// No description provided for @physicsLabDiffractionGratingDifferenceOneLabel.
  ///
  /// In en, this message translates to:
  /// **'|ψ2 - ψ1|'**
  String get physicsLabDiffractionGratingDifferenceOneLabel;

  /// No description provided for @physicsLabDiffractionGratingDifferenceTwoLabel.
  ///
  /// In en, this message translates to:
  /// **'|ψ2\' - ψ1\'|'**
  String get physicsLabDiffractionGratingDifferenceTwoLabel;

  /// No description provided for @physicsLabDiffractionGratingGammaLabel.
  ///
  /// In en, this message translates to:
  /// **'γ'**
  String get physicsLabDiffractionGratingGammaLabel;

  /// No description provided for @physicsLabDiffractionGratingSinGammaLabel.
  ///
  /// In en, this message translates to:
  /// **'sinγ'**
  String get physicsLabDiffractionGratingSinGammaLabel;

  /// No description provided for @physicsLabDiffractionGratingDegreeHint.
  ///
  /// In en, this message translates to:
  /// **'deg'**
  String get physicsLabDiffractionGratingDegreeHint;

  /// No description provided for @physicsLabDiffractionGratingMinuteHint.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get physicsLabDiffractionGratingMinuteHint;

  /// No description provided for @physicsLabDiffractionGratingClearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get physicsLabDiffractionGratingClearAllLabel;

  /// No description provided for @physicsLabDiffractionGratingPresetFillLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill Preset Values'**
  String get physicsLabDiffractionGratingPresetFillLabel;

  /// No description provided for @physicsLabMichelsonDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter 10 measured positions for every 5 fringes in mm. The page computes the differences between item i+5 and item i, averages the 5 differences, divides the average difference by 75, converts the result to nm, and compares it against 623.8 nm.'**
  String get physicsLabMichelsonDescription;

  /// No description provided for @physicsLabMichelsonIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get physicsLabMichelsonIntroTitle;

  /// No description provided for @physicsLabMichelsonFormulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get physicsLabMichelsonFormulaTitle;

  /// No description provided for @physicsLabMichelsonFormulaBody.
  ///
  /// In en, this message translates to:
  /// **'Compute 5 differences by subtracting positions 1-5 from positions 6-10 in mm, average the 5 differences, divide the average difference by 75, convert the result to nm, then calculate the relative error against 623.8 nm.'**
  String get physicsLabMichelsonFormulaBody;

  /// No description provided for @physicsLabMichelsonInputSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get physicsLabMichelsonInputSectionTitle;

  /// No description provided for @physicsLabMichelsonInputHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in 10 position values in measurement order. Integers and decimals are supported.'**
  String get physicsLabMichelsonInputHint;

  /// No description provided for @physicsLabMichelsonClearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get physicsLabMichelsonClearAllLabel;

  /// No description provided for @physicsLabMichelsonPresetFillLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill Preset Values'**
  String get physicsLabMichelsonPresetFillLabel;

  /// No description provided for @physicsLabMichelsonMillimeterUnit.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get physicsLabMichelsonMillimeterUnit;

  /// No description provided for @physicsLabMichelsonNanometerUnit.
  ///
  /// In en, this message translates to:
  /// **'nm'**
  String get physicsLabMichelsonNanometerUnit;

  /// No description provided for @physicsLabMichelsonPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position {index}'**
  String physicsLabMichelsonPositionLabel(int index);

  /// No description provided for @physicsLabMichelsonIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in all 10 position values with valid numbers first.'**
  String get physicsLabMichelsonIncompleteHint;

  /// No description provided for @physicsLabMichelsonResultSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get physicsLabMichelsonResultSectionTitle;

  /// No description provided for @physicsLabMichelsonDifferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Difference {index}: {value}'**
  String physicsLabMichelsonDifferenceLabel(int index, Object value);

  /// No description provided for @physicsLabMichelsonDifferenceDetail.
  ///
  /// In en, this message translates to:
  /// **'Difference {differenceIndex}: Position {laterIndex} {laterValue} - Position {earlierIndex} {earlierValue} = {differenceValue}'**
  String physicsLabMichelsonDifferenceDetail(
      int differenceIndex,
      Object laterValue,
      int laterIndex,
      Object earlierValue,
      int earlierIndex,
      Object differenceValue);

  /// No description provided for @physicsLabMichelsonDifferenceMmDetail.
  ///
  /// In en, this message translates to:
  /// **'Difference {differenceIndex}: Position {laterIndex} {laterValue} - Position {earlierIndex} {earlierValue} = {differenceValue} mm'**
  String physicsLabMichelsonDifferenceMmDetail(
      int differenceIndex,
      int laterIndex,
      Object laterValue,
      int earlierIndex,
      Object earlierValue,
      Object differenceValue);

  /// No description provided for @physicsLabMichelsonWavelengthNmDetail.
  ///
  /// In en, this message translates to:
  /// **'Wavelength {index}: {differenceValue} mm / {divider} = {wavelengthValue} nm'**
  String physicsLabMichelsonWavelengthNmDetail(int index,
      Object differenceValue, Object divider, Object wavelengthValue);

  /// No description provided for @physicsLabMichelsonAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Difference'**
  String get physicsLabMichelsonAverageLabel;

  /// No description provided for @physicsLabMichelsonAverageWavelengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Wavelength'**
  String get physicsLabMichelsonAverageWavelengthLabel;

  /// No description provided for @physicsLabMichelsonRelativeErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Relative Error'**
  String get physicsLabMichelsonRelativeErrorLabel;

  /// No description provided for @physicsLabMichelsonReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}'**
  String physicsLabMichelsonReferenceHint(Object reference);

  /// No description provided for @scoresOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get scoresOverviewTitle;

  /// No description provided for @scoresListTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Scores'**
  String get scoresListTitle;

  /// No description provided for @scoresSummaryGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get scoresSummaryGpa;

  /// No description provided for @scoresSummaryCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get scoresSummaryCredits;

  /// No description provided for @scoresSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get scoresSummaryFailed;

  /// No description provided for @scoresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No grades available'**
  String get scoresEmpty;

  /// No description provided for @scoresLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grades: {error}'**
  String scoresLoadFailed(Object error);

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirmLabel;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @settingsMaxWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Weeks'**
  String get settingsMaxWeekTitle;

  /// No description provided for @settingsMaxWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used by the timetable to display available weeks'**
  String get settingsMaxWeekSubtitle;

  /// No description provided for @settingsMaxWeekInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Max week must be a number.'**
  String get settingsMaxWeekInvalidFormat;

  /// No description provided for @settingsMaxWeekInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Max week must be between 1 and 52.'**
  String get settingsMaxWeekInvalidRange;

  /// No description provided for @settingsTimeSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get settingsTimeSlotsTitle;

  /// No description provided for @settingsTimeSlotsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No time slots configured'**
  String get settingsTimeSlotsEmpty;

  /// No description provided for @settingsTimeSlotsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} slots - {first} to {last}'**
  String settingsTimeSlotsSummary(int count, Object first, Object last);

  /// No description provided for @settingsTimeSlotsEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Time Slots'**
  String get settingsTimeSlotsEditorTitle;

  /// No description provided for @settingsTimeSlotsEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Tap each slot to edit start and end time. Slots must stay in chronological order and cannot overlap.'**
  String get settingsTimeSlotsEditorHint;

  /// No description provided for @settingsTimeSlotsStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get settingsTimeSlotsStartLabel;

  /// No description provided for @settingsTimeSlotsEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get settingsTimeSlotsEndLabel;

  /// No description provided for @settingsTimeSlotsInvalidEmpty.
  ///
  /// In en, this message translates to:
  /// **'At least one slot is required.'**
  String get settingsTimeSlotsInvalidEmpty;

  /// No description provided for @settingsTimeSlotsInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Start time must be earlier than end time.'**
  String get settingsTimeSlotsInvalidRange;

  /// No description provided for @settingsTimeSlotsInvalidOverlap.
  ///
  /// In en, this message translates to:
  /// **'Adjacent slots must not overlap.'**
  String get settingsTimeSlotsInvalidOverlap;

  /// No description provided for @settingsTimeSlotsInvalidOrder.
  ///
  /// In en, this message translates to:
  /// **'Time slots must be strictly increasing.'**
  String get settingsTimeSlotsInvalidOrder;

  /// No description provided for @settingsTimeSlotsResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settingsTimeSlotsResetToDefault;

  /// No description provided for @settingsDashboardUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Upcoming Courses'**
  String get settingsDashboardUpcomingTitle;

  /// No description provided for @settingsDashboardUpcomingModeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get settingsDashboardUpcomingModeThisWeek;

  /// No description provided for @settingsDashboardUpcomingModeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get settingsDashboardUpcomingModeToday;

  /// No description provided for @settingsDashboardUpcomingModeCount.
  ///
  /// In en, this message translates to:
  /// **'By count'**
  String get settingsDashboardUpcomingModeCount;

  /// No description provided for @settingsDashboardUpcomingModeCountSummary.
  ///
  /// In en, this message translates to:
  /// **'Show up to {count} courses'**
  String settingsDashboardUpcomingModeCountSummary(int count);

  /// No description provided for @settingsDashboardUpcomingCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Course count'**
  String get settingsDashboardUpcomingCountLabel;

  /// No description provided for @settingsDashboardUpcomingCountHint.
  ///
  /// In en, this message translates to:
  /// **'Valid range: 1 to 20'**
  String get settingsDashboardUpcomingCountHint;

  /// No description provided for @settingsDashboardUpcomingCountInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Course count must be a number.'**
  String get settingsDashboardUpcomingCountInvalidFormat;

  /// No description provided for @settingsDashboardUpcomingCountInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Course count must be between 1 and 20.'**
  String get settingsDashboardUpcomingCountInvalidRange;

  /// No description provided for @settingsAdvancedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvancedSectionTitle;

  /// No description provided for @settingsCommonSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get settingsCommonSectionTitle;

  /// No description provided for @settingsAppearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSectionTitle;

  /// No description provided for @settingsAppearanceThemeColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get settingsAppearanceThemeColorTitle;

  /// No description provided for @settingsAppearanceThemeColorSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsAppearanceThemeColorSystem;

  /// No description provided for @settingsAppearanceThemeColorLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsAppearanceThemeColorLight;

  /// No description provided for @settingsAppearanceThemeColorDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsAppearanceThemeColorDark;

  /// No description provided for @settingsAppearanceCustomColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom colors'**
  String get settingsAppearanceCustomColorTitle;

  /// No description provided for @settingsAppearanceHomeLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Home layout'**
  String get settingsAppearanceHomeLayoutTitle;

  /// No description provided for @settingsAppearanceHomeLayoutBottomNavigation.
  ///
  /// In en, this message translates to:
  /// **'Bottom navigation'**
  String get settingsAppearanceHomeLayoutBottomNavigation;

  /// No description provided for @settingsAppearanceHomeLayoutFunctionGrid.
  ///
  /// In en, this message translates to:
  /// **'Function grid home'**
  String get settingsAppearanceHomeLayoutFunctionGrid;

  /// No description provided for @gridHomeBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get gridHomeBackToHome;

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Color themes'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get colorPickerUndo;

  /// No description provided for @colorPickerShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get colorPickerShare;

  /// No description provided for @colorPickerImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get colorPickerImport;

  /// No description provided for @colorPickerImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import color preset'**
  String get colorPickerImportTitle;

  /// No description provided for @colorPickerImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the shared color preset text'**
  String get colorPickerImportHint;

  /// No description provided for @colorPickerImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get colorPickerImportConfirm;

  /// No description provided for @colorPickerImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Color preset imported'**
  String get colorPickerImportSuccess;

  /// No description provided for @colorPickerImportInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format: need 4 #-separated hex colors'**
  String get colorPickerImportInvalidFormat;

  /// No description provided for @colorPickerImportInvalidLightSeed.
  ///
  /// In en, this message translates to:
  /// **'Invalid light primary color'**
  String get colorPickerImportInvalidLightSeed;

  /// No description provided for @colorPickerPresetsTab.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get colorPickerPresetsTab;

  /// No description provided for @colorPickerCustomTab.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get colorPickerCustomTab;

  /// No description provided for @colorPickerLightSeed.
  ///
  /// In en, this message translates to:
  /// **'Light primary'**
  String get colorPickerLightSeed;

  /// No description provided for @colorPickerLightSecondary.
  ///
  /// In en, this message translates to:
  /// **'Light secondary'**
  String get colorPickerLightSecondary;

  /// No description provided for @colorPickerDarkSeed.
  ///
  /// In en, this message translates to:
  /// **'Dark primary'**
  String get colorPickerDarkSeed;

  /// No description provided for @colorPickerDarkSecondary.
  ///
  /// In en, this message translates to:
  /// **'Dark secondary'**
  String get colorPickerDarkSecondary;

  /// No description provided for @colorPickerPresetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get colorPickerPresetNameHint;

  /// No description provided for @colorPickerDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get colorPickerDeletePreset;

  /// No description provided for @colorPickerPresetNameDefault.
  ///
  /// In en, this message translates to:
  /// **'Preset {n}'**
  String colorPickerPresetNameDefault(int n);

  /// No description provided for @colorPickerResetToPrimary.
  ///
  /// In en, this message translates to:
  /// **'Reset to primary'**
  String get colorPickerResetToPrimary;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App info and project link'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get settingsDeveloperTitle;

  /// No description provided for @settingsDeveloperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics and logs'**
  String get settingsDeveloperSubtitle;

  /// No description provided for @settingsDeveloperPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get settingsDeveloperPageTitle;

  /// No description provided for @settingsLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get settingsLogsTitle;

  /// No description provided for @settingsLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View application log files'**
  String get settingsLogsSubtitle;

  /// No description provided for @settingsLogsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get settingsLogsEmpty;

  /// No description provided for @settingsLogsFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected log file is empty'**
  String get settingsLogsFileEmpty;

  /// No description provided for @settingsLogsCurrentFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get settingsLogsCurrentFileLabel;

  /// No description provided for @settingsLogsSwitchFileAction.
  ///
  /// In en, this message translates to:
  /// **'Switch log file'**
  String get settingsLogsSwitchFileAction;

  /// No description provided for @settingsLogsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String settingsLogsLoadFailed(Object error);

  /// No description provided for @settingsLogsExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export logs'**
  String get settingsLogsExportAction;

  /// No description provided for @settingsLogsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logs exported: {fileName}'**
  String settingsLogsExportSuccess(Object fileName);

  /// No description provided for @settingsLogsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export logs: {error}'**
  String settingsLogsExportFailed(Object error);

  /// No description provided for @settingsLogsExportCanceled.
  ///
  /// In en, this message translates to:
  /// **'Log export canceled'**
  String get settingsLogsExportCanceled;

  /// No description provided for @settingsLogsOpenFileAction.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get settingsLogsOpenFileAction;

  /// No description provided for @settingsLogsOpenFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open exported file: {error}'**
  String settingsLogsOpenFileFailed(Object error);

  /// No description provided for @settingsDebugEndpointTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Upload Endpoint'**
  String get settingsDebugEndpointTitle;

  /// No description provided for @settingsDebugEndpointSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current endpoint: {endpoint}'**
  String settingsDebugEndpointSubtitle(Object endpoint);

  /// No description provided for @settingsDebugEndpointDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Debug Upload Endpoint'**
  String get settingsDebugEndpointDialogTitle;

  /// No description provided for @settingsDebugEndpointHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a full URL (http:// or https://)'**
  String get settingsDebugEndpointHint;

  /// No description provided for @settingsDebugEndpointInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid endpoint format'**
  String get settingsDebugEndpointInvalid;

  /// No description provided for @settingsDebugEndpointInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid endpoint format. Please enter a full URL.'**
  String get settingsDebugEndpointInvalidFormat;

  /// No description provided for @settingsDebugEndpointInvalidScheme.
  ///
  /// In en, this message translates to:
  /// **'Endpoint scheme must be http or https.'**
  String get settingsDebugEndpointInvalidScheme;

  /// No description provided for @settingsDebugUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to Local Debug Server'**
  String get settingsDebugUploadTitle;

  /// No description provided for @settingsDebugUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send user collection data to {endpoint}'**
  String settingsDebugUploadSubtitle(Object endpoint);

  /// No description provided for @settingsDebugUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sent to local debug server'**
  String get settingsDebugUploadSuccess;

  /// No description provided for @settingsDebugUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String settingsDebugUploadFailed(Object error);

  /// No description provided for @settingsUserCollectionPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'User Collection Policy'**
  String get settingsUserCollectionPolicyTitle;

  /// No description provided for @settingsUserCollectionPolicySummary.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} fields selected'**
  String settingsUserCollectionPolicySummary(int selected, int total);

  /// No description provided for @settingsUserCollectionPolicySelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get settingsUserCollectionPolicySelectAll;

  /// No description provided for @settingsUserCollectionPolicyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get settingsUserCollectionPolicyClearAll;

  /// No description provided for @settingsLaunchWallpaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch Wallpaper'**
  String get settingsLaunchWallpaperTitle;

  /// No description provided for @settingsLaunchWallpaperDefaultSummary.
  ///
  /// In en, this message translates to:
  /// **'Using built-in default wallpaper'**
  String get settingsLaunchWallpaperDefaultSummary;

  /// No description provided for @settingsLaunchWallpaperCustomSummary.
  ///
  /// In en, this message translates to:
  /// **'Using custom wallpaper'**
  String get settingsLaunchWallpaperCustomSummary;

  /// No description provided for @settingsLaunchWallpaperEditorCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current selection'**
  String get settingsLaunchWallpaperEditorCurrentTitle;

  /// No description provided for @settingsLaunchWallpaperLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No local wallpapers yet'**
  String get settingsLaunchWallpaperLibraryEmpty;

  /// No description provided for @settingsLaunchWallpaperLoadingPreview.
  ///
  /// In en, this message translates to:
  /// **'Loading preview...'**
  String get settingsLaunchWallpaperLoadingPreview;

  /// No description provided for @settingsLaunchWallpaperPreviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed to load'**
  String get settingsLaunchWallpaperPreviewLoadFailed;

  /// No description provided for @settingsLaunchWallpaperPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper file is unavailable'**
  String get settingsLaunchWallpaperPreviewUnavailable;

  /// No description provided for @settingsLaunchWallpaperRenameAction.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get settingsLaunchWallpaperRenameAction;

  /// No description provided for @settingsLaunchWallpaperRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename wallpaper'**
  String get settingsLaunchWallpaperRenameTitle;

  /// No description provided for @settingsLaunchWallpaperRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper name'**
  String get settingsLaunchWallpaperRenameHint;

  /// No description provided for @settingsLaunchWallpaperDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsLaunchWallpaperDeleteAction;

  /// No description provided for @settingsLaunchWallpaperDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wallpaper'**
  String get settingsLaunchWallpaperDeleteTitle;

  /// No description provided for @settingsLaunchWallpaperDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from local wallpaper library?'**
  String settingsLaunchWallpaperDeleteBody(String name);

  /// No description provided for @settingsLaunchWallpaperPickAction.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get settingsLaunchWallpaperPickAction;

  /// No description provided for @settingsLaunchWallpaperPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick an image from the system gallery for the launch screen wallpaper'**
  String get settingsLaunchWallpaperPickSubtitle;

  /// No description provided for @settingsLaunchWallpaperResetAction.
  ///
  /// In en, this message translates to:
  /// **'Restore default wallpaper'**
  String get settingsLaunchWallpaperResetAction;

  /// No description provided for @settingsLaunchWallpaperResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch back to the built-in launch screen wallpaper'**
  String get settingsLaunchWallpaperResetSubtitle;

  /// No description provided for @settingsLaunchWallpaperPickSuccess.
  ///
  /// In en, this message translates to:
  /// **'Custom launch wallpaper selected'**
  String get settingsLaunchWallpaperPickSuccess;

  /// No description provided for @settingsLaunchWallpaperResetDone.
  ///
  /// In en, this message translates to:
  /// **'Launch wallpaper restored to default'**
  String get settingsLaunchWallpaperResetDone;

  /// No description provided for @settingsUserCollectionFieldUserid.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get settingsUserCollectionFieldUserid;

  /// No description provided for @settingsUserCollectionFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsUserCollectionFieldUsername;

  /// No description provided for @settingsUserCollectionFieldClientVersion.
  ///
  /// In en, this message translates to:
  /// **'Client version'**
  String get settingsUserCollectionFieldClientVersion;

  /// No description provided for @settingsUserCollectionFieldDeviceBrand.
  ///
  /// In en, this message translates to:
  /// **'Device brand'**
  String get settingsUserCollectionFieldDeviceBrand;

  /// No description provided for @settingsUserCollectionFieldDeviceModel.
  ///
  /// In en, this message translates to:
  /// **'Device model'**
  String get settingsUserCollectionFieldDeviceModel;

  /// No description provided for @settingsUserCollectionFieldDeptName.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get settingsUserCollectionFieldDeptName;

  /// No description provided for @settingsUserCollectionFieldSchoolName.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get settingsUserCollectionFieldSchoolName;

  /// No description provided for @settingsUserCollectionFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get settingsUserCollectionFieldGender;

  /// No description provided for @settingsUserCollectionFieldPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get settingsUserCollectionFieldPlatform;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to defaults'**
  String get settingsResetSubtitle;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'This only resets app settings and does not affect your account or cache.'**
  String get settingsResetConfirmLabel;

  /// No description provided for @settingsDataMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate Local Data'**
  String get settingsDataMigrationTitle;

  /// No description provided for @settingsDataMigrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate local data from the legacy directory to the new directory'**
  String get settingsDataMigrationSubtitle;

  /// No description provided for @settingsDataMigrationLoading.
  ///
  /// In en, this message translates to:
  /// **'Processing, please wait'**
  String get settingsDataMigrationLoading;

  /// No description provided for @settingsDataMigrationConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate local data now?'**
  String get settingsDataMigrationConfirmTitle;

  /// No description provided for @settingsDataMigrationConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will copy Hive data from the legacy directory to the new directory. Please restart the app after migration.'**
  String get settingsDataMigrationConfirmBody;

  /// No description provided for @settingsDataMigrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data migration completed'**
  String get settingsDataMigrationSuccess;

  /// No description provided for @settingsDataMigrationNoData.
  ///
  /// In en, this message translates to:
  /// **'No legacy data found to migrate'**
  String get settingsDataMigrationNoData;

  /// No description provided for @settingsDataMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Data migration failed. Please try again later'**
  String get settingsDataMigrationFailed;

  /// No description provided for @settingsDataMigrationRestartHint.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to apply changes'**
  String get settingsDataMigrationRestartHint;

  /// No description provided for @settingsDataCleanupAction.
  ///
  /// In en, this message translates to:
  /// **'Clean Legacy Cache'**
  String get settingsDataCleanupAction;

  /// No description provided for @settingsDataCleanupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Legacy data cache cleaned'**
  String get settingsDataCleanupSuccess;

  /// No description provided for @settingsDataCleanupNoData.
  ///
  /// In en, this message translates to:
  /// **'No legacy data cache found'**
  String get settingsDataCleanupNoData;

  /// No description provided for @settingsDataCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clean legacy data cache. Please try again later'**
  String get settingsDataCleanupFailed;

  /// No description provided for @settingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetDone;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A third-party client for Tongji University services.'**
  String get aboutDescription;

  /// No description provided for @aboutAppNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get aboutAppNameLabel;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutBuildLabel.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get aboutBuildLabel;

  /// No description provided for @aboutRepoLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Repository'**
  String get aboutRepoLabel;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy failed'**
  String get copyFailed;

  /// No description provided for @aboutCopied.
  ///
  /// In en, this message translates to:
  /// **'Repository link copied'**
  String get aboutCopied;

  /// No description provided for @aboutQqGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'QQ Discussion Group'**
  String get aboutQqGroupTitle;

  /// No description provided for @aboutQqGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view the QR code'**
  String get aboutQqGroupSubtitle;

  /// No description provided for @aboutQqGroupNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Number'**
  String get aboutQqGroupNumberLabel;

  /// No description provided for @aboutQqGroupCopyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy Group Number'**
  String get aboutQqGroupCopyLabel;

  /// No description provided for @aboutQqGroupCopied.
  ///
  /// In en, this message translates to:
  /// **'QQ group number copied'**
  String get aboutQqGroupCopied;

  /// No description provided for @aboutContributorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get aboutContributorsTitle;

  /// No description provided for @aboutAcknowledgementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get aboutAcknowledgementsTitle;

  /// No description provided for @aboutAckFlutterDescription.
  ///
  /// In en, this message translates to:
  /// **'Flutter, Google\'s open-source cross-platform UI framework that serves as this project\'s foundation.'**
  String get aboutAckFlutterDescription;

  /// No description provided for @aboutAckTjpbDescription.
  ///
  /// In en, this message translates to:
  /// **'An internet team guided by the Information Office of Tongji University, providing technical support for this project.'**
  String get aboutAckTjpbDescription;

  /// No description provided for @appUpdateCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get appUpdateCheckTitle;

  /// No description provided for @appUpdateCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the latest version and install package'**
  String get appUpdateCheckSubtitle;

  /// No description provided for @appUpdateAlreadyLatest.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get appUpdateAlreadyLatest;

  /// No description provided for @appUpdateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available: {version}'**
  String appUpdateDialogTitle(Object version);

  /// No description provided for @appUpdateNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No release notes'**
  String get appUpdateNotesEmpty;

  /// No description provided for @appUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get appUpdateNow;

  /// No description provided for @appUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get appUpdateLater;

  /// No description provided for @appUpdateSkipVersion.
  ///
  /// In en, this message translates to:
  /// **'Skip this version'**
  String get appUpdateSkipVersion;

  /// No description provided for @appUpdateDownloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading update'**
  String get appUpdateDownloadingTitle;

  /// No description provided for @appUpdateDownloadingBody.
  ///
  /// In en, this message translates to:
  /// **'Downloading package and verifying integrity...'**
  String get appUpdateDownloadingBody;

  /// No description provided for @appUpdateVerifyingBody.
  ///
  /// In en, this message translates to:
  /// **'Verifying package integrity...'**
  String get appUpdateVerifyingBody;

  /// No description provided for @appUpdateInstallingBody.
  ///
  /// In en, this message translates to:
  /// **'Starting installer...'**
  String get appUpdateInstallingBody;

  /// No description provided for @appUpdateDownloadedBytesKnown.
  ///
  /// In en, this message translates to:
  /// **'{received} / {total}'**
  String appUpdateDownloadedBytesKnown(Object received, Object total);

  /// No description provided for @appUpdateDownloadedBytesUnknown.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {received}'**
  String appUpdateDownloadedBytesUnknown(Object received);

  /// No description provided for @appUpdateInstallTriggered.
  ///
  /// In en, this message translates to:
  /// **'Installer has been started, please follow system prompts'**
  String get appUpdateInstallTriggered;

  /// No description provided for @appUpdateInstallPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Allow installs from unknown apps in system settings. Installation will resume automatically when you return.'**
  String get appUpdateInstallPermissionRequired;

  /// No description provided for @appUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String appUpdateFailed(Object error);

  /// No description provided for @appUpdateMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration required: {version}'**
  String appUpdateMigrationTitle(Object version);

  /// No description provided for @appUpdateMigrationSummary.
  ///
  /// In en, this message translates to:
  /// **'Your current version {currentVersion} is no longer supported. The new release must be installed as a separate app and cannot overwrite this one directly.'**
  String appUpdateMigrationSummary(Object currentVersion);

  /// No description provided for @appUpdateMigrationStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Please follow these steps (suggested to take screenshots of each step):'**
  String get appUpdateMigrationStepsTitle;

  /// No description provided for @appUpdateMigrationStepDownload.
  ///
  /// In en, this message translates to:
  /// **'1. Tap \"Download new app\" to download the new installer in your browser.'**
  String get appUpdateMigrationStepDownload;

  /// No description provided for @appUpdateMigrationStepLocate.
  ///
  /// In en, this message translates to:
  /// **'2. After the download completes, find the installer in your browser downloads or notification tray.'**
  String get appUpdateMigrationStepLocate;

  /// No description provided for @appUpdateMigrationStepUninstall.
  ///
  /// In en, this message translates to:
  /// **'3. Uninstall the current old app first.'**
  String get appUpdateMigrationStepUninstall;

  /// No description provided for @appUpdateMigrationStepInstall.
  ///
  /// In en, this message translates to:
  /// **'4. Then open the downloaded installer and install the new app.'**
  String get appUpdateMigrationStepInstall;

  /// No description provided for @appUpdateMigrationRisk.
  ///
  /// In en, this message translates to:
  /// **'After uninstalling the old app, local cache, login state, and downloaded files may be lost.'**
  String get appUpdateMigrationRisk;

  /// No description provided for @appUpdateMigrationCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy download link'**
  String get appUpdateMigrationCopyLink;

  /// No description provided for @appUpdateMigrationDownloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download new app from external source'**
  String get appUpdateMigrationDownloadNow;

  /// No description provided for @appUpdateMigrationLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Download link copied'**
  String get appUpdateMigrationLinkCopied;

  /// No description provided for @appUpdateMigrationOpenDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the download link. Copy and open it manually in your browser: {url}'**
  String appUpdateMigrationOpenDownloadFailed(Object url);

  /// No description provided for @cetScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'CET Scores'**
  String get cetScoreTitle;

  /// No description provided for @cetScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your College English Test scores.'**
  String get cetScoreSubtitle;

  /// No description provided for @cetScoreToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View CET-4 and CET-6 scores'**
  String get cetScoreToolSubtitle;

  /// No description provided for @cetScoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No CET score data is available.'**
  String get cetScoreEmpty;

  /// No description provided for @cetScoreTicketNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket No.'**
  String get cetScoreTicketNumberLabel;

  /// No description provided for @cetScoreStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get cetScoreStudentLabel;

  /// No description provided for @cetScoreSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Written test'**
  String get cetScoreSubjectLabel;

  /// No description provided for @cetScoreOralScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Oral test'**
  String get cetScoreOralScoreLabel;

  /// No description provided for @studentExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Exams'**
  String get studentExamsTitle;

  /// No description provided for @studentExamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your current term\'s exam and course arrangements.'**
  String get studentExamsSubtitle;

  /// No description provided for @studentExamsToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View exam times and rooms'**
  String get studentExamsToolSubtitle;

  /// No description provided for @studentExamsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exam arrangements are available.'**
  String get studentExamsEmpty;

  /// No description provided for @studentExamsTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get studentExamsTermLabel;

  /// No description provided for @studentExamsCourseCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Course code'**
  String get studentExamsCourseCodeLabel;

  /// No description provided for @studentExamsTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get studentExamsTimeLabel;

  /// No description provided for @studentExamsRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get studentExamsRoomLabel;

  /// No description provided for @studentExamsRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get studentExamsRemarkLabel;

  /// No description provided for @studentExamsFormalLabel.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get studentExamsFormalLabel;

  /// No description provided for @studentExamsArrangementLabel.
  ///
  /// In en, this message translates to:
  /// **'Course arrangement'**
  String get studentExamsArrangementLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
