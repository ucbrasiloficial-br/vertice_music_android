import 'dart:convert';

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String category;
  final int durationSeconds;
  final String audioUrl;
  final String coverUrl;
  final String license;
  final String licenseUrl;
  final String sourceUrl;
  final String sourceProvider;
  final bool isFeatured;
  final bool isNewRelease;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.category,
    required this.durationSeconds,
    required this.audioUrl,
    required this.coverUrl,
    required this.license,
    this.licenseUrl = '',
    this.sourceUrl = '',
    required this.sourceProvider,
    this.isFeatured = false,
    this.isNewRelease = false,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Track copyWith({bool? isFeatured, bool? isNewRelease}) => Track(
        id: id,
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        category: category,
        durationSeconds: durationSeconds,
        audioUrl: audioUrl,
        coverUrl: coverUrl,
        license: license,
        licenseUrl: licenseUrl,
        sourceUrl: sourceUrl,
        sourceProvider: sourceProvider,
        isFeatured: isFeatured ?? this.isFeatured,
        isNewRelease: isNewRelease ?? this.isNewRelease,
      );

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Faixa Sem Título',
      artist: json['artist'] as String? ?? 'Artista Independente',
      album: json['album'] as String? ?? 'Single',
      genre: json['genre'] as String? ?? 'Eletrônica',
      category: json['category'] as String? ?? 'Descoberta',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 180,
      audioUrl: json['audioUrl'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      license: json['license'] as String? ?? 'Open / Licensed',
      licenseUrl: json['licenseUrl'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      sourceProvider: json['sourceProvider'] as String? ?? 'Unknown',
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNewRelease: json['isNewRelease'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'genre': genre,
        'category': category,
        'durationSeconds': durationSeconds,
        'audioUrl': audioUrl,
        'coverUrl': coverUrl,
        'license': license,
        'licenseUrl': licenseUrl,
        'sourceUrl': sourceUrl,
        'sourceProvider': sourceProvider,
        'isFeatured': isFeatured,
        'isNewRelease': isNewRelease,
      };

  static String encodeList(List<Track> tracks) =>
      jsonEncode(tracks.map((e) => e.toJson()).toList());

  static List<Track> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class UserPlaylist {
  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final bool isRecommended;
  final String? coverUrl;

  const UserPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    this.isRecommended = false,
    this.coverUrl,
  });

  UserPlaylist copyWith({
    String? name,
    String? description,
    List<String>? trackIds,
    bool? isRecommended,
    String? coverUrl,
  }) {
    return UserPlaylist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      trackIds: trackIds ?? this.trackIds,
      isRecommended: isRecommended ?? this.isRecommended,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  factory UserPlaylist.fromJson(Map<String, dynamic> json) {
    return UserPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      trackIds: (json['trackIds'] as List<dynamic>? ?? []).cast<String>(),
      isRecommended: json['isRecommended'] as bool? ?? false,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'trackIds': trackIds,
        'isRecommended': isRecommended,
        'coverUrl': coverUrl,
      };

  static String encodeList(List<UserPlaylist> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<UserPlaylist> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => UserPlaylist.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class GuestPreferences {
  final String guestName;
  final double defaultVolume;
  final bool highQualityStreamNotice;
  final String preferredGenre;

  const GuestPreferences({
    this.guestName = 'Visitante Vértice',
    this.defaultVolume = 0.85,
    this.highQualityStreamNotice = true,
    this.preferredGenre = 'Todos',
  });

  GuestPreferences copyWith({
    String? guestName,
    double? defaultVolume,
    bool? highQualityStreamNotice,
    String? preferredGenre,
  }) {
    return GuestPreferences(
      guestName: guestName ?? this.guestName,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      highQualityStreamNotice:
          highQualityStreamNotice ?? this.highQualityStreamNotice,
      preferredGenre: preferredGenre ?? this.preferredGenre,
    );
  }

  factory GuestPreferences.fromJson(Map<String, dynamic> json) {
    return GuestPreferences(
      guestName: json['guestName'] as String? ?? 'Visitante Vértice',
      defaultVolume: (json['defaultVolume'] as num?)?.toDouble() ?? 0.85,
      highQualityStreamNotice: json['highQualityStreamNotice'] as bool? ?? true,
      preferredGenre: json['preferredGenre'] as String? ?? 'Todos',
    );
  }

  Map<String, dynamic> toJson() => {
        'guestName': guestName,
        'defaultVolume': defaultVolume,
        'highQualityStreamNotice': highQualityStreamNotice,
        'preferredGenre': preferredGenre,
      };
}

enum RepeatModeType { off, all, one }
