import 'package:onetj/repo/undergraduate_score_repository.dart';

class GradesViewData {
  const GradesViewData({
    required this.summary,
    required this.terms,
  });

  final GradesSummary summary;
  final List<GradesTerm> terms;

  factory GradesViewData.fromScoreData(UndergraduateScoreData data) {
    final List<GradesTerm> terms = data.term
            ?.map(GradesTerm.fromScoreTerm)
            .toList() ??
        const [];
    return GradesViewData(
      summary: GradesSummary.fromScoreData(data),
      terms: terms,
    );
  }
}

class GradesSummary {
  const GradesSummary({
    required this.totalGradePoint,
    required this.actualCredit,
    required this.failingCredits,
    required this.failingCourseCount,
  });

  final String totalGradePoint;
  final String actualCredit;
  final String failingCredits;
  final String failingCourseCount;

  factory GradesSummary.fromScoreData(UndergraduateScoreData data) {
    return GradesSummary(
      totalGradePoint: data.totalGradePoint ?? '--',
      actualCredit: data.actualCredit ?? '--',
      failingCredits: data.failingCredits ?? '--',
      failingCourseCount: data.failingCourseCount ?? '--',
    );
  }
}

class GradesTerm {
  const GradesTerm({
    required this.termName,
    required this.averagePoint,
    required this.courses,
  });

  final String termName;
  final String averagePoint;
  final List<GradesCourse> courses;

  factory GradesTerm.fromScoreTerm(UndergraduateScoreTermData data) {
    final List<GradesCourse> courses = data.creditInfo
            ?.map(GradesCourse.fromScoreCourse)
            .toList() ??
        const [];
    return GradesTerm(
      termName: data.termName ?? '--',
      averagePoint: data.averagePoint ?? '--',
      courses: courses,
    );
  }
}

class GradesCourse {
  const GradesCourse({
    required this.courseName,
    required this.score,
    required this.gradePoint,
    required this.credit,
    required this.courseType,
    required this.isPassLabel,
  });

  final String courseName;
  final String score;
  final String gradePoint;
  final String credit;
  final String courseType;
  final String isPassLabel;

  factory GradesCourse.fromScoreCourse(UndergraduateScoreCreditInfoData data) {
    return GradesCourse(
      courseName: data.courseName ?? '--',
      score: data.scoreName ?? data.score ?? '--',
      gradePoint: data.gradePoint?.toString() ?? '--',
      credit: data.credit?.toString() ?? '--',
      courseType: data.publicCoursesName ?? '--',
      isPassLabel: data.isPassName ?? '--',
    );
  }
}
