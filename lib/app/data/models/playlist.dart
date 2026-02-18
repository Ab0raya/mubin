import 'favorite_track.dart';

class Playlist {
  final String id;
  String name;
  final List<FavoriteTrack> tracks;
  final bool isDefault;

  Playlist({
    required this.id,
    required this.name,
    List<FavoriteTrack>? tracks,
    this.isDefault = false,
  }) : tracks = tracks ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'isDefault': isDefault,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      tracks: (json['tracks'] as List)
          .map((t) => FavoriteTrack.fromJson(t))
          .toList(),
      isDefault: json['isDefault'] ?? false,
    );
  }
}
