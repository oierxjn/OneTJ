class UserCollectionPayload {
  const UserCollectionPayload({
    required this.userid,
    required this.username,
    required this.clientVersion,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deptName,
    required this.schoolName,
    required this.gender,
    required this.platform,
  });

  final String userid;
  final String username;
  final String clientVersion;
  final String deviceBrand;
  final String deviceModel;
  final String deptName;
  final String schoolName;
  final String gender;
  final String platform;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'userid': userid,
      'username': username,
      'client_version': clientVersion,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
      'dept_name': deptName,
      'school_name': schoolName,
      'gender': gender,
      'platform': platform,
    };
  }

  Map<String, Object?> toSafeDebugMap() {
    return <String, Object?>{
      'platform': platform,
      'clientVersion': clientVersion,
      'hasUserid': userid.isNotEmpty,
      'hasUsername': username.isNotEmpty,
      'hasDeptName': deptName.isNotEmpty,
      'hasSchoolName': schoolName.isNotEmpty,
      'hasGender': gender.isNotEmpty,
    };
  }
}
