import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/about/views/about_view.dart';
import 'package:onetj/features/settings/views/developer_settings_view.dart';
import 'package:onetj/features/settings/views/launch_wallpaper_editor_view.dart';
import 'package:onetj/features/settings/views/log_viewer_view.dart';
import 'package:onetj/features/settings/views/settings_view.dart';
import 'package:onetj/features/settings/views/time_slot_editor_view.dart';
import 'package:onetj/features/settings/views/user_collection_policy_view.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/user_collection_field.dart';

final List<GoRoute> settingsRoutes = [
  GoRoute(
    path: RoutePaths.homeSettings,
    name: 'settings',
    builder: (context, state) => const SettingsView(),
    routes: [
      GoRoute(
        path: 'about',
        name: 'settings-about',
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: 'time-slots',
        name: 'settings-time-slots',
        builder: (context, state) {
          final Object? extra = state.extra;
          final List<TimePeriodRangeData> parsed = switch (extra) {
            List<dynamic> list => list
                .whereType<TimePeriodRangeData>()
                .map(
                  (item) => TimePeriodRangeData(
                    startMinutes: item.startMinutes,
                    endMinutes: item.endMinutes,
                  ),
                )
                .toList(growable: false),
            _ => <TimePeriodRangeData>[],
          };
          final List<TimePeriodRangeData> initialTimeSlots = parsed.isEmpty
              ? List<TimePeriodRangeData>.from(kDefaultTimeSlotRanges)
              : parsed;
          return TimeSlotEditorView(
            initialTimeSlotRanges: initialTimeSlots,
          );
        },
      ),
      GoRoute(
        path: 'launch-wallpaper',
        name: 'settings-launch-wallpaper',
        builder: (context, state) {
          final Object? extra = state.extra;
          final LaunchWallpaperRef initialWallpaperRef = switch (extra) {
            LaunchWallpaperRef value => value,
            _ => LaunchWallpaperRef.defaultValue,
          };
          return LaunchWallpaperEditorView(
            initialSelectedWallpaperRef: initialWallpaperRef,
          );
        },
      ),
      GoRoute(
        path: 'developer',
        name: 'settings-developer',
        builder: (context, state) => const DeveloperSettingsView(),
        routes: [
          GoRoute(
            path: 'logs',
            name: 'settings-developer-logs',
            builder: (context, state) => const LogViewerView(),
          ),
        ],
      ),
      GoRoute(
        path: 'user-collection-policy',
        name: 'settings-user-collection-policy',
        builder: (context, state) {
          final Object? extra = state.extra;
          final Set<UserCollectionField> initialSelectedFields =
              switch (extra) {
            Set<UserCollectionField> fields =>
              Set<UserCollectionField>.from(fields),
            _ => <UserCollectionField>{},
          };
          return UserCollectionPolicyView(
            initialSelectedFields: initialSelectedFields,
          );
        },
      ),
    ],
  ),
];
