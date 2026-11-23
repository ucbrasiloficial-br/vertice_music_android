import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../models/models.dart';

class AudioPlayerService {
  final AudioPlayer _player;
  final Connectivity _connectivity;

  AudioPlayerService({AudioPlayer? player, Connectivity? connectivity})
      : _player = player ?? AudioPlayer(),
        _connectivity = connectivity ?? Connectivity();

  AudioPlayer get rawPlayer => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<bool> hasNetworkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> playTrack(Track track, {double? volume}) async {
    final online = await hasNetworkConnection();
    if (!online) {
      throw Exception('Sem conexão com a internet. O streaming requer rede ativa.');
    }
    if (track.audioUrl.isEmpty) {
      throw Exception('URL de streaming indisponível para esta faixa.');
    }
    if (volume != null) {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    }
    await _player.setUrl(track.audioUrl);
    await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  Future<void> dispose() => _player.dispose();
}
