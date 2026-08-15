// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '一统同济';

  @override
  String get authStateMismatch => '认证状态不匹配，可能遭受到网络攻击';

  @override
  String get tabDashboard => '仪表板';

  @override
  String get tabTimetable => '课程表';

  @override
  String get tabSettings => '设置';

  @override
  String get tabTools => '工具';

  @override
  String get weekdayMon => '星期一';

  @override
  String get weekdayTue => '星期二';

  @override
  String get weekdayWed => '星期三';

  @override
  String get weekdayThu => '星期四';

  @override
  String get weekdayFri => '星期五';

  @override
  String get weekdaySat => '星期六';

  @override
  String get weekdaySun => '星期日';

  @override
  String get timetableDayView => '日视图';

  @override
  String get timetableWeekView => '周视图';

  @override
  String timetableLoadFailed(Object error) {
    return '加载课程表失败: $error';
  }

  @override
  String get timetableNoData => '暂无课程表数据';

  @override
  String timetableLastFetch(Object time) {
    return '上次同步：$time';
  }

  @override
  String get timetableLastFetchUnknown => '--';

  @override
  String get emptyClassesToday => '今天没有课哦';

  @override
  String get dashboardUpcomingTitle => '即将到来的课程';

  @override
  String get dashboardUpcomingEmpty => '本周暂无课程';

  @override
  String get dashboardUpcomingEmptyThisWeek => '本周暂无课程';

  @override
  String get dashboardUpcomingEmptyToday => '今日暂无课程';

  @override
  String get dashboardUpcomingEmptyByCount => '暂无即将到来的课程';

  @override
  String get courseDetailUnknownCourse => '未知课程';

  @override
  String get courseDetailSectionBasic => '基础信息';

  @override
  String get courseDetailSectionExtra => '扩展字段';

  @override
  String get courseDetailFieldCourseCode => '课程代码';

  @override
  String get courseDetailFieldClassCode => '课程班代码';

  @override
  String get courseDetailFieldClassName => '班级名称';

  @override
  String get courseDetailFieldTeacher => '教师';

  @override
  String get courseDetailFieldDay => '星期';

  @override
  String get courseDetailFieldTime => '时间';

  @override
  String get courseDetailFieldPeriods => '节次';

  @override
  String get courseDetailFieldWeeks => '周次';

  @override
  String get courseDetailFieldWeekNum => '周次范围';

  @override
  String get courseDetailFieldRoom => '教室';

  @override
  String get courseDetailFieldCampus => '校区';

  @override
  String get courseDetailFieldTeachingClassId => '教学班ID';

  @override
  String weekLabel(int week) {
    return '第$week周';
  }

  @override
  String currentTeachingWeekText(int week) {
    return '当前教学周: 第$week周';
  }

  @override
  String get scoreInquiryTitle => '成绩查询';

  @override
  String get scoreInquirySubtitle => '查看你的成绩';

  @override
  String get toolsSubtitle => '常用工具与实验计算会集中在这里。';

  @override
  String get physicsLabTitle => '物理实验计算';

  @override
  String get physicsLabToolSubtitle => '解放你的双手';

  @override
  String get physicsLabSubtitle => '选择具体实验后进入对应的计算页面。';

  @override
  String get physicsLabMichelsonTitle => '迈克尔逊干涉仪';

  @override
  String get physicsLabMichelsonSubtitle => '眼睛看瞎了';

  @override
  String get physicsLabDiffractionGratingTitle => '光栅衍射测定光波波长';

  @override
  String get physicsLabDiffractionGratingSubtitle => '记得开汞光灯！';

  @override
  String get physicsLabFranckHertzTitle => '弗兰克-赫兹实验';

  @override
  String get physicsLabFranckHertzSubtitle => '160组实验数据！';

  @override
  String get physicsLabFranckHertzIntroTitle => '实验说明';

  @override
  String get physicsLabFranckHertzDescription =>
      '填写实验参数和原始数据后，页面会自动整理曲线特征，并给出峰值法、谷值法和综合后的第一激发电位结果。';

  @override
  String get physicsLabFranckHertzDataFlowHintLeading => '建议先记录本次实验的';

  @override
  String get physicsLabFranckHertzDataFlowHintSeparator => '、';

  @override
  String get physicsLabFranckHertzDataFlowHintMiddle => '，再按测量顺序逐行填写';

  @override
  String get physicsLabFranckHertzDataFlowHintBetween => '与对应的板极电流';

  @override
  String get physicsLabFranckHertzDataFlowHintTrailing => '。';

  @override
  String get physicsLabFranckHertzMetadataTitle => '基础参数';

  @override
  String get physicsLabFranckHertzMeasurementTitle => '原始数据';

  @override
  String get physicsLabFranckHertzRowLabel => '序号';

  @override
  String get physicsLabFranckHertzActionLabel => '操作';

  @override
  String get physicsLabFranckHertzPresetFillLabel => '填充预设值';

  @override
  String get physicsLabFranckHertzAddRowLabel => '新增一行';

  @override
  String get physicsLabFranckHertzDeleteRowLabel => '删除该行';

  @override
  String get physicsLabFranckHertzClearAllLabel => '清空';

  @override
  String get physicsLabFranckHertzResultTitle => '计算结果';

  @override
  String get physicsLabFranckHertzResultDescription =>
      '系统会根据已填写的原始数据自动识别曲线特征，并分别给出峰值法、谷值法和综合结果。';

  @override
  String get physicsLabFranckHertzValidPointCountLabel => '有效数据点';

  @override
  String get physicsLabFranckHertzSmoothedPointCountLabel => '平滑后数据点';

  @override
  String get physicsLabFranckHertzPeakMethodTitle => '峰值法';

  @override
  String get physicsLabFranckHertzValleyMethodTitle => '谷值法';

  @override
  String get physicsLabFranckHertzPeakCountLabel => '识别到的峰值数';

  @override
  String get physicsLabFranckHertzValleyCountLabel => '识别到的谷值数';

  @override
  String get physicsLabFranckHertzAverageIntervalLabel => '平均相邻间距';

  @override
  String get physicsLabFranckHertzPeakMethodIncompleteHint =>
      '当前还没有足够的峰值点，暂时无法得到峰值法结果。';

  @override
  String get physicsLabFranckHertzValleyMethodIncompleteHint =>
      '当前还没有足够的谷值点，暂时无法得到谷值法结果。';

  @override
  String get physicsLabFranckHertzFinalExcitationPotentialLabel => '综合第一激发电位';

  @override
  String get physicsLabFranckHertzReferenceVoltageLabel => '参考值';

  @override
  String get physicsLabFranckHertzFinalResultIncompleteHint =>
      '需要同时得到有效的峰值法和谷值法结果后，才能计算综合第一激发电位。';

  @override
  String get physicsLabFranckHertzVoltUnit => 'V';

  @override
  String get physicsLabFranckHertzCurrentUnit => 'μA';

  @override
  String get physicsLabDiffractionGratingDescription =>
      '第一组用于根据已知谱线求光栅常数 d，第二组和第三组分别使用该 d 计算待测谱线波长。每条记录均输入 4 个原始角度读数，系统会自动计算两组角差、γ、sinγ 以及最终结果。';

  @override
  String get physicsLabDiffractionGratingIntroTitle => '实验说明';

  @override
  String get physicsLabDiffractionGratingFormulaTitle => '计算规则';

  @override
  String get physicsLabDiffractionGratingFormulaBody =>
      '对每条记录，先由两组原始读数分别求角差，再将两组角差相加后除以 4 得到 γ，之后按首组 d = kλ₀/sinγ、后两组 λ = dsinγ/k 计算。第二组和第三组各自使用组内两条记录求平均波长，并和填写的参考值比较相对误差。';

  @override
  String get physicsLabDiffractionGratingCalibrationHint =>
      '已知汞黄线波长后，本组用 k = ±2 的读数计算光栅常数 d。';

  @override
  String get physicsLabDiffractionGratingCalibrationReferenceLabel => '校准参考波长';

  @override
  String get physicsLabDiffractionGratingAverageGratingConstantLabel =>
      '光栅常数 d';

  @override
  String get physicsLabDiffractionGratingCalibrationIncompleteHint =>
      '请先填写完整的首组原始读数和校准参考波长。';

  @override
  String physicsLabDiffractionGratingWavelengthSectionTitle(int group) {
    return '第 $group 组';
  }

  @override
  String get physicsLabDiffractionGratingWavelengthHint =>
      '本组固定使用 ±1 和 ±2 两条记录，并自动引用第一组求出的 d。';

  @override
  String get physicsLabDiffractionGratingInheritedGratingConstant => '继承的 d';

  @override
  String get physicsLabDiffractionGratingReferenceLabel => '参考波长';

  @override
  String physicsLabDiffractionGratingWavelengthRowTitle(int order) {
    return 'k = ±$order';
  }

  @override
  String get physicsLabDiffractionGratingAverageWavelengthLabel => '平均波长';

  @override
  String get physicsLabDiffractionGratingWavelengthIncompleteHint =>
      '请先填写完整的原始读数和本组参考波长。';

  @override
  String get physicsLabDiffractionGratingNeedCalibrationHint =>
      '请先完成第一组并得到有效的 d。';

  @override
  String get physicsLabDiffractionGratingDifferenceOneLabel => '|ψ₂ - ψ₁|';

  @override
  String get physicsLabDiffractionGratingDifferenceTwoLabel => '|ψ₂\' - ψ₁\'|';

  @override
  String get physicsLabDiffractionGratingGammaLabel => 'γ';

  @override
  String get physicsLabDiffractionGratingSinGammaLabel => 'sinγ';

  @override
  String get physicsLabDiffractionGratingDegreeHint => '度';

  @override
  String get physicsLabDiffractionGratingMinuteHint => '分';

  @override
  String get physicsLabDiffractionGratingClearAllLabel => '清空';

  @override
  String get physicsLabDiffractionGratingPresetFillLabel => '填充预设值';

  @override
  String get physicsLabMichelsonDescription =>
      '请输入 10 个“每 5 级条纹位置”测量值，单位为 mm。系统会先计算第 i+5 个与第 i 个的差值，对 5 个差值求平均，再将平均差值除以 75 换算为波长并转成 nm，最后与 623.8 nm 比较相对误差。';

  @override
  String get physicsLabMichelsonIntroTitle => '实验说明';

  @override
  String get physicsLabMichelsonFormulaTitle => '计算规则';

  @override
  String get physicsLabMichelsonFormulaBody =>
      '先计算 5 个差值：第 6 到第 10 个位置分别减去第 1 到第 5 个位置，单位为 mm；再对 5 个差值求平均，将平均差值除以 75 并换算为 nm，最后与 623.8 nm 比较相对误差。';

  @override
  String get physicsLabMichelsonInputSectionTitle => '测量数据';

  @override
  String get physicsLabMichelsonInputHint => '按测量顺序填写 10 个位置值，支持整数和小数。';

  @override
  String get physicsLabMichelsonClearAllLabel => '清空';

  @override
  String get physicsLabMichelsonPresetFillLabel => '填充预设值';

  @override
  String get physicsLabMichelsonMillimeterUnit => 'mm';

  @override
  String get physicsLabMichelsonNanometerUnit => 'nm';

  @override
  String physicsLabMichelsonPositionLabel(int index) {
    return '第 $index 个位置';
  }

  @override
  String get physicsLabMichelsonIncompleteHint => '请先填写完整且有效的 10 个位置值。';

  @override
  String get physicsLabMichelsonResultSectionTitle => '计算结果';

  @override
  String physicsLabMichelsonDifferenceLabel(int index, Object value) {
    return '差值 $index: $value';
  }

  @override
  String physicsLabMichelsonDifferenceDetail(
      int differenceIndex,
      Object laterValue,
      int laterIndex,
      Object earlierValue,
      int earlierIndex,
      Object differenceValue) {
    return '差值 $differenceIndex: 第 $laterIndex 个位置 $laterValue - 第 $earlierIndex 个位置 $earlierValue = $differenceValue';
  }

  @override
  String physicsLabMichelsonDifferenceMmDetail(
      int differenceIndex,
      int laterIndex,
      Object laterValue,
      int earlierIndex,
      Object earlierValue,
      Object differenceValue) {
    return '差值 $differenceIndex: 第 $laterIndex 个位置 $laterValue - 第 $earlierIndex 个位置 $earlierValue = $differenceValue mm';
  }

  @override
  String physicsLabMichelsonWavelengthNmDetail(int index,
      Object differenceValue, Object divider, Object wavelengthValue) {
    return '波长 $index: $differenceValue mm / $divider = $wavelengthValue nm';
  }

  @override
  String get physicsLabMichelsonAverageLabel => '平均差值';

  @override
  String get physicsLabMichelsonAverageWavelengthLabel => '最终波长';

  @override
  String get physicsLabMichelsonRelativeErrorLabel => '相对误差';

  @override
  String physicsLabMichelsonReferenceHint(Object reference) {
    return '基准值：$reference';
  }

  @override
  String get scoresOverviewTitle => '概览';

  @override
  String get scoresListTitle => '课程成绩';

  @override
  String get scoresSummaryGpa => '绩点';

  @override
  String get scoresSummaryCredits => '学分';

  @override
  String get scoresSummaryFailed => '挂科数';

  @override
  String get scoresEmpty => '暂无成绩数据';

  @override
  String scoresLoadFailed(Object error) {
    return '成绩加载失败：$error';
  }

  @override
  String get retryLabel => '重试';

  @override
  String get logOut => '退出登录';

  @override
  String get logOutConfirmLabel => '确定退出登录吗？';

  @override
  String get confirmLabel => '确认';

  @override
  String get cancelLabel => '取消';

  @override
  String get closeLabel => '关闭';

  @override
  String get saveLabel => '保存';

  @override
  String get settingsMaxWeekTitle => '最大周数';

  @override
  String get settingsMaxWeekSubtitle => '用于课程表显示可用周数';

  @override
  String get settingsMaxWeekInvalidFormat => '最大周数必须为数字';

  @override
  String get settingsMaxWeekInvalidRange => '最大周数必须在1到52之间';

  @override
  String get settingsTimeSlotsTitle => '课程表时间设置';

  @override
  String get settingsTimeSlotsEmpty => '未配置课程表时间';

  @override
  String settingsTimeSlotsSummary(int count, Object first, Object last) {
    return '$count 个节次 - $first 到 $last';
  }

  @override
  String get settingsTimeSlotsEditorTitle => '编辑课程表时间';

  @override
  String get settingsTimeSlotsEditorHint => '点击节次可分别设置开始和结束时间。';

  @override
  String get settingsTimeSlotsStartLabel => '开始';

  @override
  String get settingsTimeSlotsEndLabel => '结束';

  @override
  String get settingsTimeSlotsInvalidEmpty => '至少需要一个节次。';

  @override
  String get settingsTimeSlotsInvalidRange => '开始时间必须早于结束时间。';

  @override
  String get settingsTimeSlotsInvalidOverlap => '相邻节次不能重叠。';

  @override
  String get settingsTimeSlotsInvalidOrder => '节次时间必须严格递增。';

  @override
  String get settingsTimeSlotsResetToDefault => '重置为默认值';

  @override
  String get settingsDashboardUpcomingTitle => '即将到来的课程';

  @override
  String get settingsDashboardUpcomingModeThisWeek => '本周';

  @override
  String get settingsDashboardUpcomingModeToday => '本日';

  @override
  String get settingsDashboardUpcomingModeCount => '按节数';

  @override
  String settingsDashboardUpcomingModeCountSummary(int count) {
    return '最多显示 $count 节课';
  }

  @override
  String get settingsDashboardUpcomingCountLabel => '课程节数';

  @override
  String get settingsDashboardUpcomingCountHint => '可设置范围：1 到 20';

  @override
  String get settingsDashboardUpcomingCountInvalidFormat => '课程节数必须为数字';

  @override
  String get settingsDashboardUpcomingCountInvalidRange => '课程节数必须在1到20之间';

  @override
  String get settingsAdvancedSectionTitle => '高级';

  @override
  String get settingsCommonSectionTitle => '通用';

  @override
  String get settingsAppearanceSectionTitle => '外观';

  @override
  String get settingsAppearanceThemeColorTitle => '主题色';

  @override
  String get settingsAppearanceThemeColorSystem => '跟随系统';

  @override
  String get settingsAppearanceThemeColorLight => '浅色';

  @override
  String get settingsAppearanceThemeColorDark => '深色';

  @override
  String get settingsAppearanceCustomColorTitle => '自定义配色';

  @override
  String get settingsAppearanceHomeLayoutTitle => '主页布局';

  @override
  String get settingsAppearanceHomeLayoutBottomNavigation => '底部导航';

  @override
  String get settingsAppearanceHomeLayoutFunctionGrid => '功能网格主页';

  @override
  String get gridHomeBackToHome => '返回主页';

  @override
  String get colorPickerTitle => '配色方案';

  @override
  String get colorPickerUndo => '撤销';

  @override
  String get colorPickerShare => '分享';

  @override
  String get colorPickerImport => '导入';

  @override
  String get colorPickerImportTitle => '导入配色';

  @override
  String get colorPickerImportHint => '粘贴分享的配色文本';

  @override
  String get colorPickerImportConfirm => '导入';

  @override
  String get colorPickerImportSuccess => '已导入配色';

  @override
  String get colorPickerImportInvalidFormat => '格式不正确：需要 4 个 # 分隔的色号';

  @override
  String get colorPickerImportInvalidLightSeed => '亮色主色格式不正确';

  @override
  String get colorPickerPresetsTab => '预设';

  @override
  String get colorPickerCustomTab => '自定义';

  @override
  String get colorPickerLightSeed => '亮色主色';

  @override
  String get colorPickerLightSecondary => '亮色辅色';

  @override
  String get colorPickerDarkSeed => '暗色主色';

  @override
  String get colorPickerDarkSecondary => '暗色辅色';

  @override
  String get colorPickerPresetNameHint => '预设名称';

  @override
  String get colorPickerDeletePreset => '删除预设';

  @override
  String colorPickerPresetNameDefault(int n) {
    return '预设$n';
  }

  @override
  String get colorPickerResetToPrimary => '重置为主色';

  @override
  String get settingsAboutTitle => '关于';

  @override
  String get settingsAboutSubtitle => '应用信息与项目链接';

  @override
  String get settingsDeveloperTitle => '开发者选项';

  @override
  String get settingsDeveloperSubtitle => '诊断与日志';

  @override
  String get settingsDeveloperPageTitle => '开发者选项';

  @override
  String get settingsLogsTitle => '日志';

  @override
  String get settingsLogsSubtitle => '查看应用日志文件';

  @override
  String get settingsLogsEmpty => '暂无日志';

  @override
  String get settingsLogsFileEmpty => '当前日志文件为空';

  @override
  String get settingsLogsCurrentFileLabel => '当前文件';

  @override
  String get settingsLogsSwitchFileAction => '切换日志文件';

  @override
  String settingsLogsLoadFailed(Object error) {
    return '日志读取失败：$error';
  }

  @override
  String get settingsLogsExportAction => '导出日志';

  @override
  String settingsLogsExportSuccess(Object fileName) {
    return '日志已导出：$fileName';
  }

  @override
  String settingsLogsExportFailed(Object error) {
    return '日志导出失败：$error';
  }

  @override
  String get settingsLogsExportCanceled => '已取消导出日志';

  @override
  String get settingsLogsOpenFileAction => '打开文件';

  @override
  String settingsLogsOpenFileFailed(Object error) {
    return '打开导出文件失败：$error';
  }

  @override
  String get settingsDebugEndpointTitle => '调试上传地址';

  @override
  String settingsDebugEndpointSubtitle(Object endpoint) {
    return '当前地址：$endpoint';
  }

  @override
  String get settingsDebugEndpointDialogTitle => '设置调试上传地址';

  @override
  String get settingsDebugEndpointHint => '请输入完整 URL（http:// 或 https://）';

  @override
  String get settingsDebugEndpointInvalid => '地址格式无效';

  @override
  String get settingsDebugEndpointInvalidFormat => '地址格式无效，请输入完整 URL';

  @override
  String get settingsDebugEndpointInvalidScheme => '地址协议仅支持 http 或 https';

  @override
  String get settingsDebugUploadTitle => '发送到本地调试服务器';

  @override
  String settingsDebugUploadSubtitle(Object endpoint) {
    return '将用户采集信息发送到 $endpoint';
  }

  @override
  String get settingsDebugUploadSuccess => '已发送到本地调试服务器';

  @override
  String settingsDebugUploadFailed(Object error) {
    return '发送失败：$error';
  }

  @override
  String get settingsUserCollectionPolicyTitle => '用户信息收集策略';

  @override
  String settingsUserCollectionPolicySummary(int selected, int total) {
    return '已选择 $selected/$total 个字段';
  }

  @override
  String get settingsUserCollectionPolicySelectAll => '全选';

  @override
  String get settingsUserCollectionPolicyClearAll => '全不选';

  @override
  String get settingsLaunchWallpaperTitle => '启动页壁纸';

  @override
  String get settingsLaunchWallpaperDefaultSummary => '当前使用内置默认壁纸';

  @override
  String get settingsLaunchWallpaperCustomSummary => '当前使用自定义壁纸';

  @override
  String get settingsLaunchWallpaperEditorCurrentTitle => '当前选择';

  @override
  String get settingsLaunchWallpaperLibraryEmpty => '当前还没有本地壁纸';

  @override
  String get settingsLaunchWallpaperLoadingPreview => '正在加载预览...';

  @override
  String get settingsLaunchWallpaperPreviewLoadFailed => '预览加载失败';

  @override
  String get settingsLaunchWallpaperPreviewUnavailable => '壁纸文件不可用';

  @override
  String get settingsLaunchWallpaperRenameAction => '重命名';

  @override
  String get settingsLaunchWallpaperRenameTitle => '重命名壁纸';

  @override
  String get settingsLaunchWallpaperRenameHint => '壁纸名称';

  @override
  String get settingsLaunchWallpaperDeleteAction => '删除';

  @override
  String get settingsLaunchWallpaperDeleteTitle => '删除壁纸';

  @override
  String settingsLaunchWallpaperDeleteBody(String name) {
    return '确定将“$name”从本地壁纸库中删除吗？';
  }

  @override
  String get settingsLaunchWallpaperPickAction => '从相册选择';

  @override
  String get settingsLaunchWallpaperPickSubtitle => '从系统相册选择一张图片作为启动页壁纸';

  @override
  String get settingsLaunchWallpaperResetAction => '恢复默认壁纸';

  @override
  String get settingsLaunchWallpaperResetSubtitle => '切换回应用内置的默认启动页壁纸';

  @override
  String get settingsLaunchWallpaperPickSuccess => '已选择自定义启动页壁纸';

  @override
  String get settingsLaunchWallpaperResetDone => '启动页壁纸已恢复为默认';

  @override
  String get settingsUserCollectionFieldUserid => '学号';

  @override
  String get settingsUserCollectionFieldUsername => '姓名';

  @override
  String get settingsUserCollectionFieldClientVersion => '客户端版本';

  @override
  String get settingsUserCollectionFieldDeviceBrand => '设备品牌';

  @override
  String get settingsUserCollectionFieldDeviceModel => '设备型号';

  @override
  String get settingsUserCollectionFieldDeptName => '院系名称';

  @override
  String get settingsUserCollectionFieldSchoolName => '学校名称';

  @override
  String get settingsUserCollectionFieldGender => '性别';

  @override
  String get settingsUserCollectionFieldPlatform => '平台';

  @override
  String get settingsResetTitle => '重置设置';

  @override
  String get settingsResetSubtitle => '将所有设置恢复为默认值';

  @override
  String get settingsResetConfirmTitle => '确认重置所有设置？';

  @override
  String get settingsResetConfirmLabel => '这仅会重置应用设置，不会影响您的账户或缓存。';

  @override
  String get settingsDataMigrationTitle => '迁移本地数据';

  @override
  String get settingsDataMigrationSubtitle => '将旧版本的本地数据迁移到新目录';

  @override
  String get settingsDataMigrationLoading => '正在处理，请稍候';

  @override
  String get settingsDataMigrationConfirmTitle => '确认迁移本地数据？';

  @override
  String get settingsDataMigrationConfirmBody =>
      '迁移会复制旧目录中的 Hive 数据到新目录。迁移完成后请重启应用。';

  @override
  String get settingsDataMigrationSuccess => '数据迁移完成';

  @override
  String get settingsDataMigrationNoData => '未发现可迁移的旧数据';

  @override
  String get settingsDataMigrationFailed => '数据迁移失败，请稍后重试';

  @override
  String get settingsDataMigrationRestartHint => '请重启应用以生效';

  @override
  String get settingsDataCleanupAction => '清理旧版本数据缓存';

  @override
  String get settingsDataCleanupSuccess => '旧版本数据缓存清理完成';

  @override
  String get settingsDataCleanupNoData => '未发现可清理的旧版本数据缓存';

  @override
  String get settingsDataCleanupFailed => '清理旧版本数据缓存失败，请稍后重试';

  @override
  String get settingsResetDone => '设置已恢复为默认值';

  @override
  String get settingsSaved => '设置已保存';

  @override
  String get aboutDescription => '一款面向同济大学服务的第三方客户端。';

  @override
  String get aboutAppNameLabel => '应用名称';

  @override
  String get aboutVersionLabel => '版本号';

  @override
  String get aboutBuildLabel => '构建号';

  @override
  String get aboutRepoLabel => '项目仓库';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copyFailed => '复制失败';

  @override
  String get aboutCopied => '已复制仓库链接';

  @override
  String get aboutQqGroupTitle => 'QQ讨论群';

  @override
  String get aboutQqGroupSubtitle => '点击查看二维码';

  @override
  String get aboutQqGroupNumberLabel => '群号';

  @override
  String get aboutQqGroupCopyLabel => '复制群号';

  @override
  String get aboutQqGroupCopied => '已复制QQ群号';

  @override
  String get aboutContributorsTitle => '贡献者';

  @override
  String get aboutAcknowledgementsTitle => '鸣谢';

  @override
  String get aboutAckFlutterDescription => 'Google 推出的跨平台开源 UI 开发框架，作为项目的基础框架';

  @override
  String get aboutAckTjpbDescription => '由同济大学信息化办公室指导的互联网团队，为本项目提供技术支持';

  @override
  String get appUpdateCheckTitle => '检查更新';

  @override
  String get appUpdateCheckSubtitle => '检查最新版本并安装更新包';

  @override
  String get appUpdateAlreadyLatest => '当前已是最新版本';

  @override
  String appUpdateDialogTitle(Object version) {
    return '发现新版本：$version';
  }

  @override
  String get appUpdateNotesEmpty => '暂无更新说明';

  @override
  String get appUpdateNow => '立即更新';

  @override
  String get appUpdateLater => '稍后提醒';

  @override
  String get appUpdateSkipVersion => '跳过此版本';

  @override
  String get appUpdateDownloadingTitle => '正在下载更新';

  @override
  String get appUpdateDownloadingBody => '正在下载更新包并校验完整性...';

  @override
  String get appUpdateVerifyingBody => '正在校验更新包完整性...';

  @override
  String get appUpdateInstallingBody => '正在启动安装程序...';

  @override
  String appUpdateDownloadedBytesKnown(Object received, Object total) {
    return '$received / $total';
  }

  @override
  String appUpdateDownloadedBytesUnknown(Object received) {
    return '已下载 $received';
  }

  @override
  String get appUpdateInstallTriggered => '已拉起安装程序，请按系统提示完成安装';

  @override
  String get appUpdateInstallPermissionRequired =>
      '请先在系统设置中允许安装未知应用，返回应用后将自动继续安装';

  @override
  String appUpdateFailed(Object error) {
    return '更新失败：$error';
  }

  @override
  String appUpdateMigrationTitle(Object version) {
    return '需要迁移到新版本：$version';
  }

  @override
  String appUpdateMigrationSummary(Object currentVersion) {
    return '当前版本 $currentVersion 已不再受支持。新版需要作为独立应用安装，无法直接覆盖升级。';
  }

  @override
  String get appUpdateMigrationStepsTitle => '请按以下顺序操作（建议截图保存每一步操作）：';

  @override
  String get appUpdateMigrationStepDownload => '1. 点击“下载新版”，使用系统浏览器下载新版安装包。';

  @override
  String get appUpdateMigrationStepLocate => '2. 下载完成后，请在浏览器下载列表或通知栏中找到安装包。';

  @override
  String get appUpdateMigrationStepUninstall => '3. 先卸载当前旧版应用。';

  @override
  String get appUpdateMigrationStepInstall => '4. 再打开刚下载的安装包，安装新版应用。';

  @override
  String get appUpdateMigrationRisk => '卸载旧版后，本地缓存、登录状态和已下载文件可能会丢失，请提前确认。';

  @override
  String get appUpdateMigrationCopyLink => '复制下载链接';

  @override
  String get appUpdateMigrationDownloadNow => '从外部下载新版';

  @override
  String get appUpdateMigrationLinkCopied => '已复制下载链接';

  @override
  String appUpdateMigrationOpenDownloadFailed(Object url) {
    return '无法打开下载链接，请复制后自行在浏览器中打开：$url';
  }

  @override
  String get cetScoreTitle => '四六级查询';

  @override
  String get cetScoreSubtitle => '查看大学英语四、六级考试成绩。';

  @override
  String get cetScoreToolSubtitle => '查看英语四、六级成绩';

  @override
  String get cetScoreEmpty => '暂无四六级成绩数据';

  @override
  String get cetScoreTicketNumberLabel => '准考证号';

  @override
  String get cetScoreStudentLabel => '学生';

  @override
  String get cetScoreSubjectLabel => '笔试科目';

  @override
  String get cetScoreOralScoreLabel => '口试成绩';
}
