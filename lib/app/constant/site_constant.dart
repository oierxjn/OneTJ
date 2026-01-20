const List<String> oauthScope = [
  "dc_user_student_info",
  "rt_onetongji_cet_score",
  "rt_onetongji_school_calendar_current_term_calendar",
  "rt_onetongji_undergraduate_score",
  "rt_teaching_info_undergraduate_summarized_grades", // 暂未使用
  "rt_onetongji_student_timetable",
// TODO:     "rt_onetongji_student_exams",
  "rt_teaching_info_sports_test_data",
  "rt_teaching_info_sports_test_health",
  "rt_onetongji_manual_arrange",
  "rt_onetongji_school_calendar_all_term_calendar",
  "rt_onetongji_msg_list",
  "rt_onetongji_msg_detail",
];
const String tongjiApiBaseUrl = "api.tongji.edu.cn";

const String loginEndpointPath = "/keycloak/realms/OpenPlatform/protocol/openid-connect/auth";
const String code2tokenPath = "/v1/token";
const String studentInfoPath = "/v1/dc/user/student_info";
const String currentTermCalendarPath = "/v1/rt/onetongji/school_calendar_current_term_calendar";

const String tongjiClientID = "authorization-xxb-onedottongji-yuchen";
const String oneTJredirectUri = "https://fakeredir.jkljkluiouio.top";