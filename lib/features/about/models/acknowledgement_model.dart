enum AcknowledgementDescriptionKey {
  flutter,
  tjpb,
}

class OrganizationAcknowledgement {
  const OrganizationAcknowledgement({
    required this.name,
    required this.logoAssetPath,
    this.descriptionKey,
    this.url,
  });

  final String name;
  final String logoAssetPath;
  final AcknowledgementDescriptionKey? descriptionKey;
  final String? url;
}

class AcknowledgementsModel {
  static const List<OrganizationAcknowledgement> organizations =
      <OrganizationAcknowledgement>[
    OrganizationAcknowledgement(
      name: 'Flutter',
      logoAssetPath: 'assets/media/flutter.png',
      descriptionKey: AcknowledgementDescriptionKey.flutter,
      url: 'https://flutter.dev',
    ),
    OrganizationAcknowledgement(
      name: '破壁工作室',
      logoAssetPath: 'assets/media/TJPB.png',
      descriptionKey: AcknowledgementDescriptionKey.tjpb,
    ),
  ];
}
