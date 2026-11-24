import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'music_source_provider.dart';

/// Discovers real audio items in Internet Archive and only exposes files whose
/// item metadata declares a reusable public-domain / Creative Commons license.
///
/// Non-commercial licenses are intentionally excluded so the catalog can be
/// used in a future commercial product without silently violating NC terms.
class ArchiveApiProvider implements MusicSourceProvider {
  final http.Client _client;

  ArchiveApiProvider({http.Client? client}) : _client = client ?? http.Client();

  static const int _maxItemsToInspect = 10;
  static const Set<String> _acceptedLicenseFragments = {
    'creativecommons.org/publicdomain/zero/1.0',
    'creativecommons.org/publicdomain/mark/1.0',
    'creativecommons.org/licenses/by/4.0',
    'creativecommons.org/licenses/by/3.0',
    'creativecommons.org/licenses/by/2.0',
    'creativecommons.org/licenses/by-sa/4.0',
    'creativecommons.org/licenses/by-sa/3.0',
    'creativecommons.org/licenses/by-sa/2.0',
    'creativecommons.org/licenses/by-nd/4.0',
    'creativecommons.org/licenses/by-nd/3.0',
    'creativecommons.org/licenses/by-nd/2.0',
  };

  @override
  String get providerId => 'internet_archive_audio';

  @override
  String get displayName => 'Internet Archive — Open Audio';

  @override
  String get licenseSummary =>
      'Faixas reais verificadas individualmente: domínio público, CC0, CC BY, CC BY-SA e CC BY-ND. Licenças NC são excluídas.';

  @override
  Future<List<Track>> fetchTracks({
    String? query,
    String? genre,
    String? category,
  }) async {
    final searchText = (query != null && query.trim().isNotEmpty)
        ? query.trim()
        : (genre != null && genre != 'Todos' ? genre.trim() : 'music');

    final clauses = <String>[
      'mediatype:audio',
      'format:MP3',
      '(licenseurl:* OR rights:"public domain")',
    ];
    if (searchText.isNotEmpty) {
      final safeTerm = searchText
          .replaceAll(r'\', r'\\')
          .replaceAll('"', r'\"');
      clauses.add('(title:"$safeTerm" OR creator:"$safeTerm" OR subject:"$safeTerm")');
    }

    final searchUri = Uri.parse(
      'https://archive.org/advancedsearch.php'
      '?q=${Uri.encodeQueryComponent(clauses.join(' AND '))}'
      '&fl%5B%5D=identifier'
      '&fl%5B%5D=title'
      '&fl%5B%5D=creator'
      '&fl%5B%5D=subject'
      '&fl%5B%5D=licenseurl'
      '&rows=40&page=1&output=json&sort%5B%5D=downloads%20desc',
    );

    final searchResponse = await _client
        .get(searchUri, headers: const {'User-Agent': 'VerticeMusic/1.0 (open-audio-catalog)'})
        .timeout(const Duration(seconds: 18));

    if (searchResponse.statusCode != 200) {
      throw Exception('O acervo público respondeu com HTTP ${searchResponse.statusCode}.');
    }

    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final docs = (searchJson['response']?['docs'] as List<dynamic>? ?? const []);
    final candidates = docs
        .whereType<Map<String, dynamic>>()
        .take(_maxItemsToInspect)
        .toList();

    // Metadata lookups are concurrent but bounded to avoid flooding the archive.
    final results = await Future.wait(
      candidates.map(_loadVerifiedTrack),
    );

    final tracks = results.whereType<Track>().toList();
    for (var index = 0; index < tracks.length && index < 5; index++) {
      tracks[index] = tracks[index].copyWith(isFeatured: true);
    }
    if (tracks.isEmpty) {
      throw Exception(
        'Não encontramos faixas com licença aberta verificável nesta busca. '
        'Tente outro artista, música ou gênero.',
      );
    }

    return tracks;
  }

  Future<Track?> _loadVerifiedTrack(Map<String, dynamic> searchItem) async {
    final identifier = _asString(searchItem['identifier']);
    if (identifier.isEmpty) return null;

    try {
      final metadataUri = Uri.https('archive.org', '/metadata/$identifier');
      final response = await _client
          .get(metadataUri, headers: const {'User-Agent': 'VerticeMusic/1.0'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final metadata = (decoded['metadata'] as Map<String, dynamic>?) ?? const {};
      final licenseUrl = _asString(metadata['licenseurl']);
      final rights = _asString(metadata['rights']);
      final license = _verifiedLicense(licenseUrl, rights);
      if (license == null) return null;

      final files = (decoded['files'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>();
      final audioFile = _chooseMp3(files);
      if (audioFile == null) return null;

      final fileName = _asString(audioFile['name']);
      if (fileName.isEmpty) return null;

      final title = _asString(metadata['title']).isNotEmpty
          ? _asString(metadata['title'])
          : _asString(searchItem['title']).isNotEmpty
              ? _asString(searchItem['title'])
              : 'Faixa do domínio público';

      final creator = _firstText(metadata['creator']).isNotEmpty
          ? _firstText(metadata['creator'])
          : _firstText(searchItem['creator']).isNotEmpty
              ? _firstText(searchItem['creator'])
              : 'Artista não informado pelo acervo';

      final subjects = _toTextList(metadata['subject']);
      final genre = subjects.isNotEmpty ? subjects.first : 'Música aberta';
      final duration = _durationSeconds(audioFile['length']) ??
          _durationSeconds(metadata['runtime']) ??
          0;

      final audioUrl = Uri.parse(
        'https://archive.org/download/'
        '${Uri.encodeComponent(identifier)}/${Uri.encodeComponent(fileName)}',
      ).toString();

      return Track(
        id: 'ia-$identifier-${Uri.encodeComponent(fileName)}',
        title: title,
        artist: creator,
        album: _asString(metadata['collection']).isNotEmpty
            ? _firstText(metadata['collection'])
            : 'Internet Archive',
        genre: genre,
        category: 'Acervo aberto',
        durationSeconds: duration,
        audioUrl: audioUrl,
        coverUrl: 'https://archive.org/services/img/${Uri.encodeComponent(identifier)}',
        license: license,
        licenseUrl: licenseUrl,
        sourceUrl: 'https://archive.org/details/${Uri.encodeComponent(identifier)}',
        sourceProvider: providerId,
        isFeatured: false,
        isNewRelease: false,
      );
    } on TimeoutException {
      return null;
    } catch (_) {
      // An individual malformed/private item must not break the whole catalog.
      return null;
    }
  }

  Map<String, dynamic>? _chooseMp3(Iterable<Map<String, dynamic>> files) {
    final candidates = files.where((file) {
      final name = _asString(file['name']).toLowerCase();
      final format = _asString(file['format']).toLowerCase();
      final isPrivate = file['private'] == true || file['private'] == 'true';
      return !isPrivate &&
          name.endsWith('.mp3') &&
          format.contains('mp3') &&
          !name.contains('_thumb');
    }).toList();

    if (candidates.isEmpty) return null;

    // Prefer a normal MP3 over a VBR derivative when both are present.
    candidates.sort((a, b) {
      final aFormat = _asString(a['format']).toLowerCase();
      final bFormat = _asString(b['format']).toLowerCase();
      final aScore = aFormat == 'mp3' ? 0 : 1;
      final bScore = bFormat == 'mp3' ? 0 : 1;
      return aScore.compareTo(bScore);
    });
    return candidates.first;
  }

  String? _verifiedLicense(String licenseUrl, String rights) {
    final normalized = licenseUrl.toLowerCase().trim();
    for (final accepted in _acceptedLicenseFragments) {
      if (normalized.contains(accepted)) {
        if (accepted.contains('/publicdomain/zero/')) return 'CC0 1.0 — Domínio público';
        if (accepted.contains('/publicdomain/mark/')) return 'Marca de domínio público';
        if (accepted.contains('/by-sa/')) return 'CC BY-SA';
        if (accepted.contains('/by-nd/')) return 'CC BY-ND';
        return 'CC BY';
      }
    }

    // Internet Archive also contains older public-domain items without a CC URL.
    // Only accept an explicit public-domain rights statement, never a blank one.
    final normalizedRights = rights.toLowerCase();
    if (normalizedRights.contains('public domain') ||
        normalizedRights.contains('domínio público')) {
      return 'Domínio público (declaração do acervo)';
    }
    return null;
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.map(_asString).where((v) => v.isNotEmpty).join(', ');
    return value.toString().trim();
  }

  String _firstText(dynamic value) {
    if (value is List) {
      for (final item in value) {
        final text = _asString(item);
        if (text.isNotEmpty) return text;
      }
      return '';
    }
    return _asString(value);
  }

  List<String> _toTextList(dynamic value) {
    if (value is List) {
      return value.map(_asString).where((v) => v.isNotEmpty).toList();
    }
    final text = _asString(value);
    return text.isEmpty ? const [] : [text];
  }

  int? _durationSeconds(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    final numeric = double.tryParse(text);
    if (numeric != null && numeric > 0) return numeric.round();

    final parts = text.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes != null && seconds != null) return minutes * 60 + seconds;
    }
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      final seconds = int.tryParse(parts[2]);
      if (hours != null && minutes != null && seconds != null) {
        return hours * 3600 + minutes * 60 + seconds;
      }
    }
    return null;
  }
}
