import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';

class HomeScreen extends StatelessWidget {
  final VerticeAppController controller;
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenFullPlayer;
  final ValueChanged<Track> onAddToPlaylist;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onNavigateTab,
    required this.onOpenFullPlayer,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final tracks = controller.allTracks;
    final featured = controller.featuredTracks;
    final moreTracks = controller.otherTracks;
    final artists = controller.popularArtists;
    final history = controller.history;
    final playlists = controller.playlists;

    return RefreshIndicator(
      color: VerticeColors.purpleNeon,
      backgroundColor: VerticeColors.surface,
      onRefresh: () => controller.refreshCatalog(includeRemote: true),
      child: ListView(
        padding: const EdgeInsets.only(top: 48, bottom: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${controller.preferences.guestName}',
                      style: const TextStyle(
                        color: VerticeColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sua música. Seu universo.',
                      style: TextStyle(
                        color: VerticeColors.purpleLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VerticeColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VerticeColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: VerticeColors.purpleNeon, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'GUEST',
                        style: TextStyle(
                          color: VerticeColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => onNavigateTab(1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: VerticeColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VerticeColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: VerticeColors.purpleLight),
                    SizedBox(width: 12),
                    Text(
                      'Buscar músicas, artistas, álbuns ou gêneros...',
                      style: TextStyle(color: VerticeColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Músicas em destaque',
            actionLabel: 'Explorar',
            onAction: () => onNavigateTab(1),
          ),
          SizedBox(
            height: 186,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final track = featured[index];
                final active = controller.currentTrack?.id == track.id;
                return GestureDetector(
                  onTap: () async {
                    await controller.playTrackFromList(track, tracks);
                    onOpenFullPlayer();
                  },
                  child: Container(
                    width: 148,
                    decoration: BoxDecoration(
                      color: VerticeColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active ? VerticeColors.purpleNeon : VerticeColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                          child: Image.network(
                            track.coverUrl,
                            height: 112,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 112,
                              color: VerticeColors.surfaceElevated,
                              child: const Icon(Icons.music_note_rounded, color: VerticeColors.purpleLight),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: VerticeColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: VerticeColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Playlists recomendadas',
            actionLabel: 'Biblioteca',
            onAction: () => onNavigateTab(2),
          ),
          SizedBox(
            height: 114,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pl = playlists[index];
                return GestureDetector(
                  onTap: () {
                    final plTracks = tracks.where((t) => pl.trackIds.contains(t.id)).toList();
                    if (plTracks.isNotEmpty) {
                      controller.playTrackFromList(plTracks.first, plTracks);
                      onOpenFullPlayer();
                    }
                  },
                  child: Container(
                    width: 235,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF231346), VerticeColors.surface],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: VerticeColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pl.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: VerticeColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pl.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: VerticeColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Artistas populares'),
          SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: artists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final artist = artists[index];
                return GestureDetector(
                  onTap: () {
                    controller.applyFilters(query: artist);
                    onNavigateTab(1);
                  },
                  child: Container(
                    width: 118,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: VerticeColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VerticeColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: VerticeColors.surfaceElevated,
                          child: Icon(Icons.person_rounded, color: VerticeColors.purpleLight),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: VerticeColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Mais faixas do acervo'),
          ...moreTracks.take(3).map(
                (t) => TrackTile(
                  track: t,
                  isCurrent: controller.currentTrack?.id == t.id,
                  isPlaying: controller.isPlaying,
                  isFavorite: controller.isFavorite(t.id),
                  onTap: () async {
                    await controller.playTrackFromList(t, tracks);
                    onOpenFullPlayer();
                  },
                  onFavoriteToggle: () => controller.toggleFavorite(t),
                  onAddToPlaylist: () => onAddToPlaylist(t),
                ),
              ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'Reprodução recente'),
            ...history.take(3).map(
                  (t) => TrackTile(
                    track: t,
                    isCurrent: controller.currentTrack?.id == t.id,
                    isPlaying: controller.isPlaying,
                    isFavorite: controller.isFavorite(t.id),
                    onTap: () async {
                      await controller.playTrackFromList(t, history);
                      onOpenFullPlayer();
                    },
                    onFavoriteToggle: () => controller.toggleFavorite(t),
                    onAddToPlaylist: () => onAddToPlaylist(t),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
