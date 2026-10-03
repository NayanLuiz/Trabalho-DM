class SquadMemberDatabaseEntity {
  final int heroId;
  final String recruitedAt;

  const SquadMemberDatabaseEntity({
    required this.heroId,
    required this.recruitedAt,
  });

  Map<String, Object?> toJson() => {
    SquadDatabaseContract.heroId: heroId,
    SquadDatabaseContract.recruitedAt: recruitedAt,
  };

  factory SquadMemberDatabaseEntity.fromJson(Map<String, dynamic> json) =>
      SquadMemberDatabaseEntity(
        heroId: json[SquadDatabaseContract.heroId] as int,
        recruitedAt: json[SquadDatabaseContract.recruitedAt] as String,
      );
}

abstract class SquadDatabaseContract {
  static const table = 'squad_table';
  static const heroId = 'hero_id';
  static const recruitedAt = 'recruited_at';
}
