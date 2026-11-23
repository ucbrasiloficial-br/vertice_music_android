import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';

class LibraryScreen extends StatefulWidget {
  final VerticeAppController controller;
  final VoidCallback onOpenFullPlayer;
  final ValueChanged<Track> onAddToPlaylist;

  const LibraryScreen({
    super.key,
    required this.controller,
    required this.onOpenFullPlayer,
    required this.onAddToPlaylist,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VerticeColors.surface,
        title: const Text('Nova Playlist', style: TextStyle(color: VerticeColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'Nome da playlist'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(hintText: 'Descrição (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: VerticeColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VerticeColors.purpleNeon),
            onPressed: () async {
              await widget.controller.createPlaylist(nameCtrl.text, descCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Criar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Column(
      children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biblioteca',
                style: TextStyle(
                  color: VerticeColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_box_rounded, color: VerticeColors.purpleNeon),
                tooltip: 'Criar playlist',
                onPressed: _showCreatePlaylistDialog,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: VerticeColors.purpleNeon,
          labelColor: VerticeColors.purpleLight,
          unselectedLabelColor: VerticeColors.textMuted,
          tabs: const [
            Tab(text: 'Favoritas'),
            Tab(text: 'Playlists'),
            Tab(text: 'Álbuns & Artistas'),
            Tab(text: 'Histórico'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ctrl.favorites.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma música favoritada ainda.',
                        style: TextStyle(color: VerticeColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      itemCount: ctrl.favorites.length,
                      itemBuilder: (_, i) {
                        final t = ctrl.favorites[i];
                        return TrackTile(
                          track: t,
                          isCurrent: ctrl.currentTrack?.id == t.id,
                          isPlaying: ctrl.isPlaying,
                          isFavorite: true,
                          onTap: () async {
                            await ctrl.playTrackFromList(t, ctrl.favorites);
                            widget.onOpenFullPlayer();
                          },
                          onFavoriteToggle: () => ctrl.toggleFavorite(t),
                          onAddToPlaylist: () => widget.onAddToPlaylist(t),
                        );
                      },
                    ),
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.playlists.length,
                itemBuilder: (_, i) {
                  final pl = ctrl.playlists[i];
                  final plTracks = ctrl.allTracks.where((t) => pl.trackIds.contains(t.id)).toList();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VerticeColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VerticeColors.border),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: VerticeColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.queue_music_rounded, color: Colors.white),
                      ),
                      title: Text(
                        pl.name,
                        style: const TextStyle(color: VerticeColors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${plTracks.length} faixa(s) • ${pl.description}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: VerticeColors.textSecondary, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.play_arrow_rounded, color: VerticeColors.purpleLight),
                      onTap: () async {
                        if (plTracks.isNotEmpty) {
                          await ctrl.playTrackFromList(plTracks.first, plTracks);
                          widget.onOpenFullPlayer();
                        }
                      },
                    ),
                  );
                },
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Álbuns do Catálogo',
                    style: TextStyle(color: VerticeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...ctrl.albums.map(
                    (album) => ListTile(
                      leading: const Icon(Icons.album_rounded, color: VerticeColors.purpleLight),
                      title: Text(album, style: const TextStyle(color: VerticeColors.textPrimary)),
                      onTap: () {
                        final matches = ctrl.allTracks.where((t) => t.album == album).toList();
                        if (matches.isNotEmpty) {
                          ctrl.playTrackFromList(matches.first, matches);
                          widget.onOpenFullPlayer();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Artistas Licenciados',
                    style: TextStyle(color: VerticeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...ctrl.popularArtists.map(
                    (artist) => ListTile(
                      leading: const Icon(Icons.mic_external_on_rounded, color: VerticeColors.purpleNeon),
                      title: Text(artist, style: const TextStyle(color: VerticeColors.textPrimary)),
                      onTap: () {
                        final matches = ctrl.allTracks.where((t) => t.artist == artist).toList();
                        if (matches.isNotEmpty) {
                          ctrl.playTrackFromList(matches.first, matches);
                          widget.onOpenFullPlayer();
                        }
                      },
                    ),
                  ),
                ],
              ),
              ctrl.history.isEmpty
                  ? const Center(
                      child: Text(
                        'Seu histórico de reprodução aparecerá aqui.',
                        style: TextStyle(color: VerticeColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      itemCount: ctrl.history.length,
                      itemBuilder: (_, i) {
                        final t = ctrl.history[i];
                        return TrackTile(
                          track: t,
                          isCurrent: ctrl.currentTrack?.id == t.id,
                          isPlaying: ctrl.isPlaying,
                          isFavorite: ctrl.isFavorite(t.id),
                          onTap: () async {
                            await ctrl.playTrackFromList(t, ctrl.history);
                            widget.onOpenFullPlayer();
                          },
                          onFavoriteToggle: () => ctrl.toggleFavorite(t),
                          onAddToPlaylist: () => widget.onAddToPlaylist(t),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
