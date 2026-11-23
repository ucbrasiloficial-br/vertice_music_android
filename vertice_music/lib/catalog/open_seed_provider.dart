import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'music_source_provider.dart';

class OpenSeedProvider implements MusicSourceProvider {
  @override
  String get providerId => 'open_licensed_seed';

  @override
  String get displayName => 'Vértice Open Catalog (CC / Public Domain)';

  @override
  String get licenseSummary => 'Faixas com licenças abertas (CC0, CC-BY, CC-BY-SA) autorizadas para streaming.';

  @override
  Future<List<Track>> fetchTracks({String? query, String? genre, String? category}) async {
    final raw = await rootBundle.loadString('assets/data/open_catalog.json');
    final list = jsonDecode(raw) as List<dynamic>;
    var tracks = list.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();

    if (genre != null && genre.isNotEmpty && genre != 'Todos') {
      tracks = tracks
          .where((t) => t.genre.toLowerCase() == genre.toLowerCase())
          .toList();
    }

    if (category != null && category.isNotEmpty && category != 'Todas') {
      tracks = tracks
          .where((t) => t.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      tracks = tracks
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.artist.toLowerCase().contains(q) ||
              t.album.toLowerCase().contains(q) ||
              t.genre.toLowerCase().contains(q))
          .toList();
    }

    return tracks;
  }
}
