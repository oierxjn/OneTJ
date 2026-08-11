import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/user_collection_field.dart';
import 'package:onetj/app/exception/app_exception.dart';

class SettingsData {
  const SettingsData({
    required this.maxWeek,
    required this.timeSlotRanges,
    required this.dashboardUpcomingMode,
    required this.dashboardUpcomingCount,
    required this.userCollectionFields,
    required this.selectedLaunchWallpaperRef,
  });

  final int maxWeek;
  final List<TimePeriodRangeData> timeSlotRanges;
  final DashboardUpcomingMode dashboardUpcomingMode;
  final int dashboardUpcomingCount;
  final Set<UserCollectionField> userCollectionFields;
  final LaunchWallpaperRef selectedLaunchWallpaperRef;

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    final int maxWeek = _readMaxWeekWithFallback(json);
    final List<TimePeriodRangeData> timeSlotRanges =
        _readTimeSlotRangesWithFallback(json);
    return SettingsData(
      maxWeek: maxWeek,
      timeSlotRanges: timeSlotRanges,
      dashboardUpcomingMode: _readDashboardUpcomingModeWithFallback(json),
      dashboardUpcomingCount: _readDashboardUpcomingCountWithFallback(json),
      userCollectionFields: _readUserCollectionFieldsWithFallback(json),
      selectedLaunchWallpaperRef:
          _readSelectedLaunchWallpaperRefWithFallback(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxWeek': maxWeek,
      'timeSlotRanges': timeSlotRanges.map((item) => item.toJson()).toList(),
      'dashboardUpcomingMode': dashboardUpcomingMode.jsonValue,
      'dashboardUpcomingCount': dashboardUpcomingCount,
      'userCollectionFields': UserCollectionField.values
          .where((field) => userCollectionFields.contains(field))
          .map((field) => field.jsonKey)
          .toList(growable: false),
      'selectedLaunchWallpaperRef': selectedLaunchWallpaperRef.toJson(),
    };
  }

  SettingsData copyWith({
    int? maxWeek,
    List<TimePeriodRangeData>? timeSlotRanges,
    DashboardUpcomingMode? dashboardUpcomingMode,
    int? dashboardUpcomingCount,
    Set<UserCollectionField>? userCollectionFields,
    LaunchWallpaperRef? selectedLaunchWallpaperRef,
  }) {
    return SettingsData(
      maxWeek: maxWeek ?? this.maxWeek,
      timeSlotRanges: timeSlotRanges ?? this.timeSlotRanges,
      dashboardUpcomingMode:
          dashboardUpcomingMode ?? this.dashboardUpcomingMode,
      dashboardUpcomingCount:
          dashboardUpcomingCount ?? this.dashboardUpcomingCount,
      userCollectionFields: userCollectionFields ?? this.userCollectionFields,
      selectedLaunchWallpaperRef:
          selectedLaunchWallpaperRef ?? this.selectedLaunchWallpaperRef,
    );
  }

  static int _readMaxWeekWithFallback(Map<String, dynamic> json) {
    if (!json.containsKey('maxWeek')) {
      return kDefaultMaxWeek;
    }
    try {
      return _parseMaxWeek(json['maxWeek']);
    } on SettingsResolveException {
      return kDefaultMaxWeek;
    }
  }

  static List<TimePeriodRangeData> _readTimeSlotRangesWithFallback(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey('timeSlotRanges')) {
      try {
        return _parseTimeSlotRanges(json['timeSlotRanges']);
      } on SettingsResolveException {
        return _defaultTimeSlotRanges();
      } on SettingsValidationException {
        return _defaultTimeSlotRanges();
      }
    }
    if (json.containsKey('timeSlotStartMinutes')) {
      try {
        final List<int> starts = _parseTimeSlotStartMinutes(
          json['timeSlotStartMinutes'],
        );
        return _deriveRangesFromStarts(starts);
      } on SettingsResolveException {
        return _defaultTimeSlotRanges();
      } on SettingsValidationException {
        return _defaultTimeSlotRanges();
      }
    }
    return _defaultTimeSlotRanges();
  }

  static DashboardUpcomingMode _readDashboardUpcomingModeWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('dashboardUpcomingMode')) {
      return kDefaultDashboardUpcomingMode;
    }
    return DashboardUpcomingMode.fromJsonValue(
      json['dashboardUpcomingMode'],
      defaultValue: kDefaultDashboardUpcomingMode,
    );
  }

  static int _readDashboardUpcomingCountWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('dashboardUpcomingCount')) {
      return kDefaultDashboardUpcomingCount;
    }
    final Object? value = json['dashboardUpcomingCount'];
    if (value is! int) {
      return kDefaultDashboardUpcomingCount;
    }
    if (value < kMinDashboardUpcomingCount ||
        value > kMaxDashboardUpcomingCount) {
      return kDefaultDashboardUpcomingCount;
    }
    return value;
  }

  static Set<UserCollectionField> _readUserCollectionFieldsWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('userCollectionFields')) {
      return kDefaultUserCollectionFields;
    }
    final Object? values = json['userCollectionFields'];
    if (values is! List) {
      return kDefaultUserCollectionFields;
    }
    return values
        .map<UserCollectionField?>(
          (Object? item) => UserCollectionField.fromJsonKey(item),
        )
        .whereType<UserCollectionField>()
        .toSet();
  }

  static LaunchWallpaperRef _readSelectedLaunchWallpaperRefWithFallback(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('selectedLaunchWallpaperRef')) {
      return LaunchWallpaperRef.defaultValue;
    }
    return LaunchWallpaperRef.fromJson(json['selectedLaunchWallpaperRef']);
  }

  static int _parseMaxWeek(Object? value) {
    if (value is! int) {
      throw SettingsResolveException(message: 'maxWeek must be int');
    }
    return value;
  }

  static List<int> _parseTimeSlotStartMinutes(Object? values) {
    if (values is! List) {
      throw SettingsResolveException(
          message:
              'timeSlotStartMinutes(${values.runtimeType}) must be a list');
    }
    return values.map<int>((item) {
      if (item is! int) {
        throw SettingsResolveException(
          message: 'timeSlotStartMinutes item must be int',
        );
      }
      return item;
    }).toList(growable: false);
  }

  static List<TimePeriodRangeData> _parseTimeSlotRanges(Object? values) {
    if (values is! List) {
      throw SettingsResolveException(
        message: 'timeSlotRanges(${values.runtimeType}) must be a list',
      );
    }
    final List<TimePeriodRangeData> ranges =
        values.map<TimePeriodRangeData>((item) {
      if (item is! Map<String, dynamic>) {
        throw SettingsResolveException(
          message: 'timeSlotRanges item must be Map<String, dynamic>',
        );
      }
      return TimePeriodRangeData.fromJson(item);
    }).toList(growable: false);
    settings_validation.validateTimeSlotRanges(ranges);
    return ranges;
  }

  static List<TimePeriodRangeData> _deriveRangesFromStarts(List<int> starts) {
    return settings_validation.buildTimeSlotRangesFromStartMinutes(starts);
  }

  static List<TimePeriodRangeData> _defaultTimeSlotRanges() {
    return kDefaultTimeSlotRanges;
  }
}
