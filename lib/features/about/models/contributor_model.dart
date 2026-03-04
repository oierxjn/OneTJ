class ContributorProfile {
  const ContributorProfile({
    required this.displayName,
    required this.avatarAssetPath,
    this.userName,
  });

  final String displayName;
  final String avatarAssetPath;
  final String? userName;
}

class ContributorsModel {
  static const List<ContributorProfile> contributors = <ContributorProfile>[
    ContributorProfile(
      displayName: 'oierxjn',
      userName: 'jkljkluiouio',
      avatarAssetPath: 'assets/media/oierxjn.jpg',
    ),
    ContributorProfile(
      displayName: 'GuanTouYu',
      userName: 'FlowerBlackG',
      avatarAssetPath: 'assets/media/GuanTouYu.jpg',
    ),
    ContributorProfile(
      displayName: 'streetartist',
      avatarAssetPath: 'assets/media/streetartist.png',
    ),
    ContributorProfile(
      displayName: 'Chaoynag Xie',
      userName: 'HalfAnElephant',
      avatarAssetPath: 'assets/media/HalfAnElephant.jpg',
    ),
  ];
}
