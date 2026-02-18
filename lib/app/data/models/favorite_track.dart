class FavoriteTrack {
  final String reciterName;
  final String reciterUrl;
  final int surahIndex;

  FavoriteTrack({
    required this.reciterName,
    required this.reciterUrl,
    required this.surahIndex,
  });

  Map<String, dynamic> toJson() => {
    'reciterName': reciterName,
    'reciterUrl': reciterUrl,
    'surahIndex': surahIndex,
  };

  factory FavoriteTrack.fromJson(Map<String, dynamic> json) {
    return FavoriteTrack(
      reciterName: json['reciterName'],
      reciterUrl: json['reciterUrl'],
      surahIndex: json['surahIndex'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteTrack &&
        other.reciterName == reciterName &&
        other.surahIndex == surahIndex;
  }

  @override
  int get hashCode => reciterName.hashCode ^ surahIndex.hashCode;
}
