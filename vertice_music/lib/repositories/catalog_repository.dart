import 'package:flutter/foundation.dart';
import '../catalog/archive_api_provider.dart';
import '../catalog/music_source_provider.dart';
import '../catalog/open_seed_provider.dart';
import '../models/models.dart';

class CatalogRepository {
  final List<MusicSourceProvider> _providers;

  CatalogRepository({List<MusicSourceProvider>? providers})
      : _providers = providers ??
            [
              OpenSeedProvider(),
              ArchiveApiProvider(),
            ];

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
    final List<Track> aggregated = [];

    final localTracks = await _providers.first.fetchTracks(
      query: query,
      genre: genre,
      category: category,
    );
    aggregated.addAll(localTracks);

    if (includeRemote && _providers.length > 1) {
      for (final provider in _providers.skip(1)) {
        try {
          final remoteTracks = await provider.fetchTracks(
            query: query,
            genre: genre,
            category: category,
          );
          for (final rt in remoteTracks) {
            if (!aggregated.any((existing) => existing.id == rt.id)) {
              aggregated.add(rt);
            }
          }
        } catch (e) {
          debugPrint('Fonte remota ${provider.providerId} indisponível: $e');
        }
      }
    }

    return aggregated;
  }
}
