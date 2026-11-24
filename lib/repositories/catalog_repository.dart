import 'package:flutter/foundation.dart';

import '../catalog/archive_api_provider.dart';
import '../catalog/music_source_provider.dart';
import '../models/models.dart';

class CatalogRepository {
  final List<MusicSourceProvider> _providers;

  CatalogRepository({List<MusicSourceProvider>? providers})
      : _providers = providers ?? [ArchiveApiProvider()];

  List<MusicSourceProvider> get providers => List.unmodifiable(_providers);

  void registerProvider(MusicSourceProvider provider) {
    _providers.add(provider);
  }

  Future<List<Track>> loadCatalog({
    String? query,
    String? genre,
    String? category,
    bool includeRemote = true,
  }) async {
    if (!includeRemote) return const [];

    final aggregated = <Track>[];
    Object? lastError;
    var sourceResponded = false;
    for (final provider in _providers) {
      try {
        final remoteTracks = await provider.fetchTracks(
          query: query,
          genre: genre,
          category: category,
        );
        sourceResponded = true;
        for (final track in remoteTracks) {
          if (!aggregated.any((existing) => existing.id == track.id)) {
            aggregated.add(track);
          }
        }
      } catch (error) {
        lastError = error;
        debugPrint('Fonte ${provider.providerId} indisponível: $error');
      }
    }
    if (!sourceResponded && lastError != null) {
      throw Exception('Não foi possível consultar o catálogo aberto: $lastError');
    }
    return aggregated;
  }
}
