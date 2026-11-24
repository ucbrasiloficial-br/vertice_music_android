import 'package:flutter_test/flutter_test.dart';
import 'package:vertice_music/models/models.dart';

void main() {
  test('Track model serializes and formats duration properly', () {
    const track = Track(
      id: 'vm-test-1',
      title: 'Faixa de teste',
      artist: 'Artista de teste',
      album: 'Midnight Circuit',
      genre: 'Synthwave',
      category: 'Eletrônica',
      durationSeconds: 185,
      audioUrl: 'https://example.invalid/test-audio.mp3',
      coverUrl: '',
      license: 'CC0 1.0 — Domínio público',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
      sourceUrl: 'https://archive.org/details/example',
      sourceProvider: 'TestFixture',
      isFeatured: true,
    );

    expect(track.formattedDuration, '03:05');
    final decoded = Track.fromJson(track.toJson());
    expect(decoded.id, 'vm-test-1');
    expect(decoded.artist, 'Artista de teste');
    expect(decoded.licenseUrl, 'https://creativecommons.org/publicdomain/zero/1.0/');
    expect(decoded.sourceUrl, 'https://archive.org/details/example');
  });
}
