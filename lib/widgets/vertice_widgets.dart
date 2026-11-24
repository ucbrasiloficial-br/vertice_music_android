import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';

class VerticeLogoMark extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSlogan;

  const VerticeLogoMark({
    super.key,
    this.size = 72,
    this.showText = true,
    this.showSlogan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D1336), Color(0xFF0E0A1D)],
            ),
            border: Border.all(color: VerticeColors.purpleNeon.withOpacity( 0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: VerticeColors.purpleNeon.withOpacity( 0.35),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.28),
            child: Image.asset(
              'assets/images/vertice_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.graphic_eq_rounded,
                color: VerticeColors.purpleLight,
                size: 36,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          const Text(
            'VÉRTICE MUSIC',
            style: TextStyle(
              color: VerticeColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
        ],
        if (showSlogan) ...[
          const SizedBox(height: 6),
          const Text(
            'Sua música. Seu universo.',
            style: TextStyle(
              color: VerticeColors.purpleLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: VerticeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: VerticeColors.purpleLight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class TrackTile extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onAddToPlaylist;

  const TrackTile({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isCurrent ? VerticeColors.surfaceElevated : VerticeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? VerticeColors.purpleNeon : VerticeColors.border,
          width: isCurrent ? 1.3 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  track.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: VerticeColors.surfaceElevated,
                    child: const Icon(Icons.music_note_rounded, color: VerticeColors.purpleLight),
                  ),
                ),
                if (isCurrent)
                  Container(
                    color: Colors.black.withOpacity( 0.45),
                    child: Icon(
                      isPlaying ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                      color: VerticeColors.purpleLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCurrent ? VerticeColors.purpleLight : VerticeColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${track.artist} • ${track.genre} • ${track.formattedDuration}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VerticeColors.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? VerticeColors.purpleNeon : VerticeColors.textSecondary,
                size: 21,
              ),
              onPressed: onFavoriteToggle,
              tooltip: 'Favoritar',
            ),
            if (onAddToPlaylist != null)
              IconButton(
                icon: const Icon(Icons.playlist_add_rounded, color: VerticeColors.textSecondary, size: 22),
                onPressed: onAddToPlaylist,
                tooltip: 'Adicionar à playlist',
              ),
          ],
        ),
      ),
    );
  }
}

class MiniPlayerBar extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onOpenFullPlayer;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const MiniPlayerBar({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.isBuffering,
    required this.onOpenFullPlayer,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenFullPlayer,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF21143E), Color(0xFF151226)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: VerticeColors.purpleNeon.withOpacity( 0.65)),
          boxShadow: [
            BoxShadow(
              color: VerticeColors.purpleNeon.withOpacity( 0.22),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                track.coverUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: VerticeColors.surfaceElevated,
                  child: const Icon(Icons.music_note_rounded, color: VerticeColors.purpleLight),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VerticeColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VerticeColors.purpleLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isBuffering)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: VerticeColors.purpleLight,
                ),
              )
            else
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: VerticeColors.textPrimary,
                  size: 34,
                ),
                onPressed: onPlayPause,
              ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: VerticeColors.purpleLight),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
