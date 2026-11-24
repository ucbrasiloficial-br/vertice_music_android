import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LibraryRepository {
  static const _kFavoritesKey = 'vertice_favorites_v1';
  static const _kHistoryKey = 'vertice_history_v1';
  static const _kPlaylistsKey = 'vertice_playlists_v1';
  static const _kPrefsKey = 'vertice_guest_prefs_v1';

  Future<List<Track>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return Track.decodeList(prefs.getString(_kFavoritesKey) ?? '');
  }

  Future<void> saveFavorites(List<Track> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavoritesKey, Track.encodeList(tracks));
  }

  Future<List<Track>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return Track.decodeList(prefs.getString(_kHistoryKey) ?? '');
  }

  Future<void> saveHistory(List<Track> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHistoryKey, Track.encodeList(tracks));
  }

  Future<List<UserPlaylist>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPlaylistsKey) ?? '';
    if (raw.isEmpty) return const [];
    return UserPlaylist.decodeList(raw);
  }

  Future<void> savePlaylists(List<UserPlaylist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlaylistsKey, UserPlaylist.encodeList(playlists));
  }

  Future<GuestPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null || raw.isEmpty) return const GuestPreferences();
    try {
      return GuestPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const GuestPreferences();
    }
  }

  Future<void> savePreferences(GuestPreferences prefsModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, jsonEncode(prefsModel.toJson()));
  }
}
