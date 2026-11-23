import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  final VerticeAppController controller;

  const MainShellScreen({super.key, required this.controller});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _openFullPlayer() {
    if (widget.controller.currentTrack == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(controller: widget.controller),
      ),
    );
  }

  void _showAddToPlaylistDialog(Track track) {
    final ctrl = widget.controller;
    if (ctrl.playlists.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VerticeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar "${track.title}" à playlist',
                style: const TextStyle(
                  color: VerticeColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...ctrl.playlists.map((pl) {
                final contains = pl.trackIds.contains(track.id);
                return ListTile(
                  leading: Icon(
                    contains ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    color: contains ? VerticeColors.purpleNeon : VerticeColors.purpleLight,
                  ),
                  title: Text(pl.name, style: const TextStyle(color: VerticeColors.textPrimary)),
                  subtitle: Text(
                    '${pl.trackIds.length} faixa(s)',
                    style: const TextStyle(color: VerticeColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () async {
                    await ctrl.toggleTrackInPlaylist(pl.id, track.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final pages = [
          HomeScreen(
            controller: ctrl,
            onNavigateTab: (index) => setState(() => _currentIndex = index),
            onOpenFullPlayer: _openFullPlayer,
            onAddToPlaylist: _showAddToPlaylistDialog,
          ),
          ExploreScreen(
            controller: ctrl,
            onOpenFullPlayer: _openFullPlayer,
            onAddToPlaylist: _showAddToPlaylistDialog,
          ),
          LibraryScreen(
            controller: ctrl,
            onOpenFullPlayer: _openFullPlayer,
            onAddToPlaylist: _showAddToPlaylistDialog,
          ),
          ProfileScreen(controller: ctrl),
        ];

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: VerticeColors.screenGlowGradient),
            child: Column(
              children: [
                if (ctrl.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(12, 44, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: VerticeColors.error.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VerticeColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: VerticeColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ctrl.errorMessage!,
                            style: const TextStyle(color: VerticeColors.textPrimary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: pages[_currentIndex]),
                if (ctrl.currentTrack != null)
                  MiniPlayerBar(
                    track: ctrl.currentTrack!,
                    isPlaying: ctrl.isPlaying,
                    isBuffering: ctrl.isBuffering,
                    onOpenFullPlayer: _openFullPlayer,
                    onPlayPause: ctrl.togglePlayPause,
                    onNext: ctrl.playNext,
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: VerticeColors.surface,
              border: Border(top: BorderSide(color: VerticeColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: VerticeColors.purpleNeon,
              unselectedItemColor: VerticeColors.textMuted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_rounded),
                  label: 'Explorar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_rounded),
                  label: 'Biblioteca',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
