import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/app_update/app_update_flow_coordinator.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/features/dashboard/views/widgets/function_grid.dart';
import 'package:onetj/features/dashboard/models/dashboard_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/widgets/course_detail_bottom_sheet.dart';

const double _kUpcomingTimeBadgeWidth = 95;
const double _kUpcomingTimeBadgeGap = 12;
const double _kUpcomingContentLeftInset =
    _kUpcomingTimeBadgeWidth + _kUpcomingTimeBadgeGap;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  late final DashboardViewModel _viewModel;
  late final ThemeChangeNotifier _themeChangeNotifier;
  late final AppUpdateService _appUpdateService;
  late final AppUpdateFlowCoordinator _appUpdateCoordinator;
  StreamSubscription<UiEvent>? _eventSub;
  bool _updateDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeChangeNotifier = appLocator<ThemeChangeNotifier>();
    _appUpdateService = appLocator<AppUpdateService>();
    _appUpdateCoordinator = AppUpdateFlowCoordinator(
      appUpdateService: _appUpdateService,
    );
    _viewModel = DashboardViewModel(appUpdateService: _appUpdateService);
    _eventSub = _viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
      if (event is AppUpdateFailedEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).appUpdateFailed(
                event.error.toString(),
              ),
            ),
          ),
        );
        return;
      }
      if (event is AppUpdateAvailableEvent) {
        unawaited(_showAppUpdateDialog(event.updateInfo));
      }
    });
    _viewModel.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_viewModel.onAppResumed());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  /// 显示更新弹窗
  ///
  /// [updateInfo] 更新信息
  Future<void> _showAppUpdateDialog(AppUpdateInfo updateInfo) async {
    if (!mounted || _updateDialogVisible) {
      return;
    }
    _updateDialogVisible = true;
    try {
      await _appUpdateCoordinator.run(
        context,
        updateInfo: updateInfo,
        allowSkipVersion: true,
      );
    } finally {
      _updateDialogVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tabDashboard),
      ),
      body: AnimatedBuilder(
        animation:
            Listenable.merge(<Listenable>[_viewModel, _themeChangeNotifier]),
        builder: (context, _) => _buildBody(context, l10n),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(context),
                const SizedBox(height: 24),
                if (_themeChangeNotifier.preferences.homeLayout ==
                    HomeLayout.functionGrid) ...[
                  _buildFunctionGrid(context, l10n),
                  const SizedBox(height: 24),
                ],
                Text(
                  l10n.dashboardUpcomingTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_viewModel.timetableLoading || _viewModel.calendarLoading)
                  const LinearProgressIndicator()
                else
                  _buildUpcomingSection(
                    context,
                    entries: _viewModel.buildUpcomingEntries(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionGrid(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return FunctionGrid(
      timetableLabel: l10n.tabTimetable,
      physicsLabLabel: l10n.physicsLabTitle,
      settingsLabel: l10n.tabSettings,
      gradesLabel: l10n.scoreInquiryTitle,
      toolsLabel: l10n.tabTools,
      aboutLabel: l10n.settingsAboutTitle,
      onTimetableTap: () => context.go(RoutePaths.homeTimetable),
      // 二级详情路由位于主页 Shell 外，使用 push 保留返回一级主页的栈。
      onPhysicsLabTap: () => context.push(RoutePaths.homePhysicsLab),
      onSettingsTap: () => context.go(RoutePaths.homeSettings),
      onGradesTap: () => context.push(RoutePaths.homeGrades),
      onToolsTap: () => context.go(RoutePaths.homeTools),
      onAboutTap: () => context.push(RoutePaths.homeSettingsAbout),
    );
  }

  Future<void> _showCourseDetails(TimetableEntry entry) async {
    final TimetableIndex? index = _viewModel.timetableIndex;
    if (index == null) {
      return;
    }
    await showCourseDetailBottomSheet(
      context: context,
      entry: entry,
      index: index,
      timeSlotRanges: _viewModel.timeSlotRanges,
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
  ) {
    final SchoolCalendarData? calendar = _viewModel.calendar;
    final l10n = AppLocalizations.of(context);

    final String department = _viewModel.departmentName ?? '';
    final bool isLoading =
        _viewModel.studentLoading || _viewModel.calendarLoading;
    final String termTitle =
        (calendar?.simpleName ?? '').isNotEmpty ? calendar!.simpleName : '';
    final int weekNumber = calendar?.week != null ? calendar!.week : 0;
    final String departmentLabel = department.isNotEmpty ? department : '';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                termTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                departmentLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoPill(text: l10n.currentTeachingWeekText(weekNumber)),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final Animation<double> fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  );
                  final Animation<double> scale = Tween<double>(
                    begin: 0.98,
                    end: 1,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: isLoading
                    ? const _HeroLoadingBlock(key: ValueKey('hero-loading'))
                    : const SizedBox(
                        key: ValueKey('hero-idle'),
                        height: 16,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context, {
    required List<DashboardUpcomingEntryData> entries,
  }) {
    final l10n = AppLocalizations.of(context);
    if (entries.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available,
        title: _dashboardUpcomingEmptyText(l10n, _viewModel.upcomingMode),
      );
    }
    return Column(
      children: entries
          .map(
            (item) => _UpcomingCard(
              title: item.entry.courseName.isNotEmpty
                  ? item.entry.courseName
                  : 'Unknown course',
              timeLabel:
                  '${_weekdayLabel(l10n, item.entry.dayOfWeek)}\n${_formatTimeRange(item.entry, _viewModel.timeSlotRanges)}',
              roomLabel: item.entry.roomIdI18n.isNotEmpty
                  ? item.entry.roomIdI18n
                  : item.entry.roomLabel,
              teacherLabel: item.entry.teacherName.isNotEmpty
                  ? item.entry.teacherName
                  : '-',
              isOngoing: item.isOngoing,
              onTap: () {
                _showCourseDetails(item.entry);
              },
            ),
          )
          .toList(),
    );
  }

  String _dashboardUpcomingEmptyText(
    AppLocalizations l10n,
    DashboardUpcomingMode mode,
  ) {
    switch (mode) {
      case DashboardUpcomingMode.thisWeek:
        return l10n.dashboardUpcomingEmptyThisWeek;
      case DashboardUpcomingMode.today:
        return l10n.dashboardUpcomingEmptyToday;
      case DashboardUpcomingMode.count:
        return l10n.dashboardUpcomingEmptyByCount;
    }
  }

  String _weekdayLabel(AppLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
      default:
        return l10n.weekdayMon;
    }
  }

  String _formatTimeRange(
    TimetableEntry entry,
    List<TimePeriodRangeData> ranges,
  ) {
    final String start = _slotStartLabel(entry.timeStart, ranges);
    final String end = _slotEndLabel(entry.timeEnd, ranges);
    if (start.isEmpty && end.isEmpty) {
      return '${entry.timeStart}-${entry.timeEnd}';
    }
    if (start.isEmpty) {
      return '${entry.timeStart}-$end';
    }
    if (end.isEmpty) {
      return '$start-${entry.timeEnd}';
    }
    return '$start-$end';
  }
}

String _slotStartLabel(int slot, List<TimePeriodRangeData> ranges) {
  final int index = slot - 1;
  if (index < 0 || index >= ranges.length) {
    return '';
  }
  return TimeSlot.formatMinutes(ranges[index].startMinutes);
}

String _slotEndLabel(int slot, List<TimePeriodRangeData> ranges) {
  final int index = slot - 1;
  if (index < 0 || index >= ranges.length) {
    return '';
  }
  return TimeSlot.formatMinutes(ranges[index].endMinutes);
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _HeroLoadingBlock extends StatelessWidget {
  const _HeroLoadingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 12),
        LinearProgressIndicator(),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.title,
    required this.timeLabel,
    required this.roomLabel,
    required this.teacherLabel,
    required this.isOngoing,
    this.onTap,
  });

  final String title;
  final String timeLabel;
  final String roomLabel;
  final String teacherLabel;
  final bool isOngoing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color backgroundColor =
        isOngoing ? colors.primaryContainer : colors.surfaceContainerHigh;
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: _TimeBadge(label: timeLabel),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: _kUpcomingContentLeftInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _MetaRow(
                      icon: Icons.room_outlined,
                      label: roomLabel,
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(
                      icon: Icons.person_outline,
                      label: teacherLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: _kUpcomingTimeBadgeGap),
      child: SizedBox(
        width: _kUpcomingTimeBadgeWidth,
        child: Card(
          margin: EdgeInsets.zero,
          color: colors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
