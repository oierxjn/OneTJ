import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/settings/views/settings_view.dart';
import 'package:onetj/features/settings/views/time_slot_editor_view.dart';
import 'package:onetj/models/time_slot.dart';

final List<GoRoute> settingsRoutes = [
  GoRoute(
    path: RoutePaths.homeSettings,
    name: 'settings',
    builder: (context, state) => const SettingsView(),
    routes: [
      GoRoute(
        path: 'time-slots',
        name: 'settings-time-slots',
        builder: (context, state) {
          final Object? extra = state.extra;
          final List<int> initialTimeSlots = switch (extra) {
            List<dynamic> list => list.whereType<int>().toList(growable: false),
            _ => List<int>.from(TimeSlot.defaultStartMinutes),
          };
          return TimeSlotEditorView(
            initialTimeSlotStartMinutes: initialTimeSlots,
          );
        },
      ),
    ],
  ),
];
