const List<String> oauthScope = [
  "dc_user_student_info",
  "rt_onetongji_cet_score",
  "rt_onetongji_school_calendar_current_term_calendar",
  "rt_onetongji_undergraduate_score",
  "rt_teaching_info_undergraduate_summarized_grades", // 暂未使用
  "rt_onetongji_student_timetable",
// TODO: 等待学校开放平台为该 client 开通后再启用，
// 否则授权请求会被 Keycloak 以 invalid_scope 拒绝，导致无法登录。
//     "rt_onetongji_student_exams",
  "rt_teaching_info_sports_test_data",
  "rt_teaching_info_sports_test_health",
  "rt_onetongji_manual_arrange",
  "rt_onetongji_school_calendar_all_term_calendar",
  "rt_onetongji_msg_list",
  "rt_onetongji_msg_detail",
];
const String tongjiApiBaseUrl = "api.tongji.edu.cn";

const String loginEndpointPath =
    "/keycloak/realms/OpenPlatform/protocol/openid-connect/auth";
const String code2tokenPath = "/v1/token";
const String studentInfoPath = "/v1/dc/user/student_info";
const String currentTermCalendarPath =
    "/v1/rt/onetongji/school_calendar_current_term_calendar";
const String studentTimetablePath = "/v1/rt/onetongji/student_timetable";
const String undergraduateScorePath = "/v1/rt/onetongji/undergraduate_score";
const String cetScorePath = "/v1/rt/onetongji/cet_score";
const String studentExamsPath = "/v1/rt/onetongji/student_exams";
const String defaultDebugCollectionEndpoint =
    "http://127.0.0.1:8000/collector/v1/events";
const String appUpdateServiceBaseUrl = "onetjapi.jkljkluiouio.top";
const String appUpdateCheckPath = "/updater/v1/check";

const String tongjiClientID = "authorization-xxb-onedottongji-yuchen";
const String oneTJredirectUri = "https://fakeredir.jkljkluiouio.top";
