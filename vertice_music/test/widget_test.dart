import 'package:flutter_test/flutter_test.dart';
import 'package:vertice_music/models/models.dart';

void main() {
  test('Track model serializes and formats duration properly', () {
    const track = Track(
      id: 'vm-test-1',
      title: 'Neon Horizon',
      artist: 'Pulse & Grid',
      album: 'Midnight Circuit',
      genre: 'Synthwave',
      category: 'Eletrônica',
      durationSeconds: 185,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      coverUrl: 'https://picsum.photos/seed/vertice01/600/600',
      license: 'CC0',
      sourceProvider: 'OpenLicensedSeed',
      isFeatured: true,
    );

    expect(track.formattedDuration, '03:05');
    final decoded = Track.fromJson(track.toJson());
    expect(decoded.id, 'vm-test-1');
    expect(decoded.artist, 'Pulse & Grid');
  });
}
