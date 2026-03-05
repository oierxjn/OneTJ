enum UserCollectionConsent {
  unknown('unknown'),
  accepted('accepted'),
  declined('declined');

  const UserCollectionConsent(this.jsonValue);

  final String jsonValue;

  static UserCollectionConsent fromJsonValue(
    Object? value, {
    UserCollectionConsent defaultValue = UserCollectionConsent.unknown,
  }) {
    if (value is! String) {
      return defaultValue;
    }
    for (final UserCollectionConsent item in UserCollectionConsent.values) {
      if (item.jsonValue == value) {
        return item;
      }
    }
    return defaultValue;
  }
}
