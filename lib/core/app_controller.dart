import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../catalog/music_source_provider.dart';
import '../models/models.dart';
import '../player/audio_player_service.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/library_repository.dart';

class VerticeAppController extends ChangeNotifier {
  final CatalogRepository _catalogRepository;
  final LibraryRepository _libraryRepository;
  final AudioPlayerService _playerService;
  final Uuid _uuid = const Uuid();

  VerticeAppController({
    CatalogRepository? catalogRepository,
    LibraryRepository? libraryRepository,
    AudioPlayerService? playerService,
  })  : _catalogRepository = catalogRepository ?? CatalogRepository(),
        _libraryRepository = libraryRepository ?? LibraryRepository(),
        _playerService = playerService ?? AudioPlayerService();

  bool isInitialized = false;
  bool isLoadingCatalog = false;
  bool isPlaying = false;
  bool isBuffering = false;
  bool shuffleEnabled = false;
  RepeatModeType repeatMode = RepeatModeType.off;
  double currentVolume = 0.85;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  String? errorMessage;
  String selectedGenre = 'Todos';
  String selectedCategory = 'Todas';
  String searchQuery = '';

  List<Track> allTracks = [];
  List<Track> filteredTracks = [];
  List<Track> queue = [];
  int currentIndex = -1;
  List<Track> favorites = [];
  List<Track> history = [];
  List<UserPlaylist> playlists = [];
  GuestPreferences preferences = const GuestPreferences();

  AudioPlayerService get playerService => _playerService;

  List<MusicSourceProvider> get providers => _catalogRepository.providers;

  Track? get currentTrack =>
      (currentIndex >= 0 && currentIndex < queue.length) ? queue[currentIndex] : null;

  List<Track> get featuredTracks =>
      allTracks.where((t) => t.isFeatured).toList();

  List<Track> get otherTracks =>
      allTracks.where((t) => !t.isFeatured).toList();

  List<String> get popularArtists {
    final set = <String>{};
    for (final t in allTracks) {
      set.add(t.artist);
    }
    return set.toList();
  }

  List<String> get albums {
    final set = <String>{};
    for (final t in allTracks) {
      set.add(t.album);
    }
    return set.toList();
  }

  Future<void> initialize() async {
    try {
      favorites = await _libraryRepository.getFavorites();
      history = await _libraryRepository.getHistory();
      playlists = await _libraryRepository.getPlaylists();
      preferences = await _libraryRepository.getPreferences();
      currentVolume = preferences.defaultVolume;
      await _playerService.setVolume(currentVolume);

      _playerService.playerStateStream.listen((state) {
        isPlaying = state.playing;
        isBuffering = state.processingState.name == 'buffering' ||
            state.processingState.name == 'loading';
        if (state.processingState.name == 'completed') {
          _handleTrackCompleted();
        }
        notifyListeners();
      });

      _playerService.positionStream.listen((pos) {
        position = pos;
        notifyListeners();
      });

      _playerService.durationStream.listen((dur) {
        if (dur != null) {
          duration = dur;
          notifyListeners();
        }
      });

      await refreshCatalog(includeRemote: true);
    } catch (e) {
      errorMessage = 'A inicialização encontrou um problema: $e';
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshCatalog({bool includeRemote = true}) async {
    isLoadingCatalog = true;
    errorMessage = null;
    notifyListeners();

    try {
      allTracks = await _catalogRepository.loadCatalog(includeRemote: includeRemote);
      _filterLoadedTracks();
    } catch (e) {
      errorMessage = 'Não foi possível carregar o catálogo: $e';
    } finally {
      isLoadingCatalog = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    String? query,
    String? genre,
    String? category,
    bool searchRemote = false,
  }) async {
    if (query != null) searchQuery = query;
    if (genre != null) selectedGenre = genre;
    if (category != null) selectedCategory = category;

    if (searchRemote) {
      isLoadingCatalog = true;
      errorMessage = null;
      notifyListeners();
      try {
        final remoteResults = await _catalogRepository.loadCatalog(
          query: searchQuery,
          genre: selectedGenre,
          category: selectedCategory,
          includeRemote: true,
        );
        if (remoteResults.isNotEmpty) {
          allTracks = remoteResults;
        }
        _filterLoadedTracks();
      } catch (e) {
        errorMessage = 'Erro ao pesquisar no acervo aberto: $e';
      } finally {
        isLoadingCatalog = false;
        notifyListeners();
      }
      return;
    }

    _filterLoadedTracks();
    notifyListeners();
  }

  void _filterLoadedTracks() {
    final query = searchQuery.trim().toLowerCase();
    filteredTracks = allTracks.where((track) {
      final matchesQuery = query.isEmpty ||
          track.title.toLowerCase().contains(query) ||
          track.artist.toLowerCase().contains(query) ||
          track.album.toLowerCase().contains(query) ||
          track.genre.toLowerCase().contains(query);
      final matchesGenre = selectedGenre == 'Todos' ||
          track.genre.toLowerCase().contains(selectedGenre.toLowerCase());
      final matchesCategory = selectedCategory == 'Todas' ||
          track.category.toLowerCase().contains(selectedCategory.toLowerCase());
      return matchesQuery && matchesGenre && matchesCategory;
    }).toList();
  }

  Future<void> playTrackFromList(Track track, List<Track> sourceQueue) async {
    errorMessage = null;
    queue = List<Track>.from(sourceQueue);
    currentIndex = queue.indexWhere((t) => t.id == track.id);
    if (currentIndex == -1) {
      queue.insert(0, track);
      currentIndex = 0;
    }
    await _startCurrentTrack();
  }

  Future<void> _startCurrentTrack() async {
    final track = currentTrack;
    if (track == null) return;

    duration = Duration(seconds: track.durationSeconds);
    position = Duration.zero;
    notifyListeners();

    try {
      await _playerService.playTrack(track, volume: currentVolume);
      await _recordHistory(track);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    errorMessage = null;
    if (currentTrack == null) {
      if (allTracks.isNotEmpty) {
        await playTrackFromList(allTracks.first, allTracks);
      }
      return;
    }

    if (isPlaying) {
      await _playerService.pause();
    } else {
      final online = await _playerService.hasNetworkConnection();
      if (!online) {
        errorMessage = 'Sem conexão com a internet para reproduzir áudio.';
        notifyListeners();
        return;
      }
      await _playerService.resume();
    }
  }

  Future<void> playNext() async {
    if (queue.isEmpty) return;
    if (shuffleEnabled && queue.length > 1) {
      final nextIdx = (currentIndex + 3) % queue.length;
      currentIndex = nextIdx == currentIndex ? (currentIndex + 1) % queue.length : nextIdx;
    } else {
      currentIndex = (currentIndex + 1) % queue.length;
    }
    await _startCurrentTrack();
  }

  Future<void> playPrevious() async {
    if (queue.isEmpty) return;
    if (position.inSeconds > 4) {
      await seekTo(Duration.zero);
      return;
    }
    currentIndex = (currentIndex - 1 + queue.length) % queue.length;
    await _startCurrentTrack();
  }

  Future<void> _handleTrackCompleted() async {
    if (repeatMode == RepeatModeType.one) {
      await seekTo(Duration.zero);
      await _playerService.resume();
    } else if (repeatMode == RepeatModeType.all || currentIndex < queue.length - 1) {
      await playNext();
    }
  }

  Future<void> seekTo(Duration target) async {
    position = target;
    await _playerService.seek(target);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    currentVolume = value.clamp(0.0, 1.0);
    await _playerService.setVolume(currentVolume);
    notifyListeners();
  }

  void toggleShuffle() {
    shuffleEnabled = !shuffleEnabled;
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (repeatMode) {
      case RepeatModeType.off:
        repeatMode = RepeatModeType.all;
        break;
      case RepeatModeType.all:
        repeatMode = RepeatModeType.one;
        break;
      case RepeatModeType.one:
        repeatMode = RepeatModeType.off;
        break;
    }
    notifyListeners();
  }

  bool isFavorite(String trackId) => favorites.any((t) => t.id == trackId);

  Future<void> toggleFavorite(Track track) async {
    final idx = favorites.indexWhere((t) => t.id == track.id);
    if (idx >= 0) {
      favorites.removeAt(idx);
    } else {
      favorites.insert(0, track);
    }
    await _libraryRepository.saveFavorites(favorites);
    notifyListeners();
  }

  Future<void> _recordHistory(Track track) async {
    history.removeWhere((t) => t.id == track.id);
    history.insert(0, track);
    if (history.length > 30) {
      history = history.sublist(0, 30);
    }
    await _libraryRepository.saveHistory(history);
  }

  Future<void> createPlaylist(String name, String description) async {
    if (name.trim().isEmpty) return;
    final newPlaylist = UserPlaylist(
      id: 'pl-${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      description: description.trim().isEmpty
          ? 'Playlist personalizada no modo visitante.'
          : description.trim(),
      trackIds: [],
      isRecommended: false,
      coverUrl: allTracks.isNotEmpty ? allTracks.first.coverUrl : null,
    );
    playlists.insert(0, newPlaylist);
    await _libraryRepository.savePlaylists(playlists);
    notifyListeners();
  }

  Future<void> toggleTrackInPlaylist(String playlistId, String trackId) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    final current = List<String>.from(playlists[idx].trackIds);
    if (current.contains(trackId)) {
      current.remove(trackId);
    } else {
      current.add(trackId);
    }
    playlists[idx] = playlists[idx].copyWith(trackIds: current);
    await _libraryRepository.savePlaylists(playlists);
    notifyListeners();
  }

  Future<void> updatePreferences(GuestPreferences updated) async {
    preferences = updated;
    currentVolume = updated.defaultVolume;
    await _playerService.setVolume(currentVolume);
    await _libraryRepository.savePreferences(preferences);
    notifyListeners();
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }
}
