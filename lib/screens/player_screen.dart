import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';

class PlayerScreen extends StatelessWidget {
  final VerticeAppController controller;

  const PlayerScreen({super.key, required this.controller});

  String _format(Duration d) {
    final totalSec = d.inSeconds.clamp(0, 86400);
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VerticeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.queue.length,
          itemBuilder: (ctx, i) {
            final item = controller.queue[i];
            final active = i == controller.currentIndex;
            return ListTile(
              leading: Icon(
                active ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                color: active ? VerticeColors.purpleNeon : VerticeColors.textSecondary,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  color: active ? VerticeColors.purpleLight : VerticeColors.textPrimary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(item.artist, style: const TextStyle(color: VerticeColors.textSecondary)),
              onTap: () {
                controller.playTrackFromList(item, controller.queue);
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final track = controller.currentTrack;
        if (track == null) {
          return const Scaffold(
            body: Center(child: Text('Nenhuma faixa selecionada.')),
          );
        }

        final maxSec = controller.duration.inSeconds > 0
            ? controller.duration.inSeconds.toDouble()
            : track.durationSeconds.toDouble();
        final posSec = controller.position.inSeconds.clamp(0, maxSec.toInt()).toDouble();

        final repeatIcon = switch (controller.repeatMode) {
          RepeatModeType.off => Icons.repeat_rounded,
          RepeatModeType.all => Icons.repeat_rounded,
          RepeatModeType.one => Icons.repeat_one_rounded,
        };

        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: VerticeColors.screenGlowGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          children: [
                            const Text(
                              'REPRODUZINDO AGORA',
                              style: TextStyle(
                                color: VerticeColors.purpleLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                            Text(
                              track.license,
                              style: const TextStyle(color: VerticeColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.queue_music_rounded, color: VerticeColors.purpleLight),
                          tooltip: 'Fila de reprodução',
                          onPressed: () => _showQueueSheet(context),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: VerticeColors.purpleNeon.withOpacity( 0.7), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: VerticeColors.purpleNeon.withOpacity( 0.35),
                            blurRadius: 34,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.network(
                          track.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: VerticeColors.surfaceElevated,
                            child: const Icon(Icons.music_note_rounded, size: 72, color: VerticeColors.purpleLight),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: VerticeColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${track.artist} • ${track.album}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: VerticeColors.purpleLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Fonte: Internet Archive • ${track.license}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: VerticeColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              if (track.sourceUrl.isNotEmpty)
                                Text(
                                  track.sourceUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: VerticeColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                              if (track.licenseUrl.isNotEmpty)
                                Text(
                                  'Licença: ${track.licenseUrl}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: VerticeColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.isFavorite(track.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: controller.isFavorite(track.id)
                                ? VerticeColors.purpleNeon
                                : VerticeColors.textSecondary,
                            size: 28,
                          ),
                          onPressed: () => controller.toggleFavorite(track),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: VerticeColors.purpleNeon,
                        inactiveTrackColor: VerticeColors.border,
                        thumbColor: VerticeColors.purpleLight,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        min: 0,
                        max: maxSec > 0 ? maxSec : 1,
                        value: posSec,
                        onChanged: (val) => controller.seekTo(Duration(seconds: val.toInt())),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(controller.position),
                          style: const TextStyle(color: VerticeColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          _format(Duration(seconds: maxSec.toInt())),
                          style: const TextStyle(color: VerticeColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: controller.shuffleEnabled
                                ? VerticeColors.purpleNeon
                                : VerticeColors.textMuted,
                          ),
                          onPressed: controller.toggleShuffle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 36),
                          color: VerticeColors.textPrimary,
                          onPressed: controller.playPrevious,
                        ),
                        Container(
                          width: 66,
                          height: 66,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: VerticeColors.primaryGradient,
                          ),
                          child: controller.isBuffering
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : IconButton(
                                  icon: Icon(
                                    controller.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: controller.togglePlayPause,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 36),
                          color: VerticeColors.textPrimary,
                          onPressed: controller.playNext,
                        ),
                        IconButton(
                          icon: Icon(
                            repeatIcon,
                            color: controller.repeatMode != RepeatModeType.off
                                ? VerticeColors.purpleNeon
                                : VerticeColors.textMuted,
                          ),
                          onPressed: controller.cycleRepeatMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded, color: VerticeColors.textSecondary, size: 20),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: VerticeColors.purpleLight,
                              inactiveTrackColor: VerticeColors.border,
                              thumbColor: VerticeColors.textPrimary,
                              trackHeight: 3,
                            ),
                            child: Slider(
                              min: 0,
                              max: 1,
                              value: controller.currentVolume,
                              onChanged: (val) => controller.setVolume(val),
                            ),
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, color: VerticeColors.purpleLight, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
