import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'music_source_provider.dart';

class ArchiveApiProvider implements MusicSourceProvider {
  final http.Client _client;

  ArchiveApiProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  String get providerId => 'internet_archive_audio';

  @override
  String get displayName => 'Internet Archive Audio';

  @override
  String get licenseSummary => 'Acervo aberto do Internet Archive (domínio público / Creative Commons).';

  @override
  Future<List<Track>> fetchTracks({String? query, String? genre, String? category}) async {
    final searchTerm = (query != null && query.trim().isNotEmpty)
        ? query.trim()
        : (genre != null && genre != 'Todos' ? genre : 'electronic');

    final encodedQuery = Uri.encodeComponent(
      '($searchTerm) AND mediatype:(audio) AND format:(MP3)',
    );
    final url = Uri.parse(
      'https://archive.org/advancedsearch.php?q=$encodedQuery&fl[]=identifier,title,creator,subject&rows=10&page=1&output=json',
    );

    final response = await _client.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Falha ao consultar fonte aberta (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = (decoded['response']?['docs'] as List<dynamic>? ?? []);

    final List<Track> results = [];
    for (final item in docs) {
      final map = item as Map<String, dynamic>;
      final id = map['identifier'] as String?;
      if (id == null || id.isEmpty) continue;

      final title = (map['title'] is List
              ? (map['title'] as List).first
              : map['title'])
          ?.toString() ??
          'Faixa Aberta';
      final creator = (map['creator'] is List
              ? (map['creator'] as List).first
              : map['creator'])
          ?.toString() ??
          'Artista do Acervo';

      results.add(
        Track(
          id: 'ia-$id',
          title: title,
          artist: creator,
          album: 'Internet Archive Collection',
          genre: genre ?? 'Eletrônica',
          category: category ?? 'Descoberta',
          durationSeconds: 185,
          audioUrl: 'https://archive.org/download/$id/$id.mp3',
          coverUrl: 'https://archive.org/services/img/$id',
          license: 'Open Archive / CC',
          sourceProvider: providerId,
          isFeatured: false,
          isNewRelease: true,
        ),
      );
    }
    return results;
  }
}
