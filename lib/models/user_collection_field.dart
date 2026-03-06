enum UserCollectionField {
  userid('userid'),
  username('username'),
  clientVersion('client_version'),
  deviceBrand('device_brand'),
  deviceModel('device_model'),
  deptName('dept_name'),
  schoolName('school_name'),
  gender('gender'),
  platform('platform');

  const UserCollectionField(this.jsonKey);

  final String jsonKey;

  static UserCollectionField? fromJsonKey(Object? value) {
    if (value is! String) {
      return null;
    }
    for (final UserCollectionField field in UserCollectionField.values) {
      if (field.jsonKey == value) {
        return field;
      }
    }
    return null;
  }
}
