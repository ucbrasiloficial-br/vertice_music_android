import '../models/models.dart';

abstract class MusicSourceProvider {
  String get providerId;
  String get displayName;
  String get licenseSummary;

  Future<List<Track>> fetchTracks({String? query, String? genre, String? category});
}
