import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';

class ExploreScreen extends StatefulWidget {
  final VerticeAppController controller;
  final VoidCallback onOpenFullPlayer;
  final ValueChanged<Track> onAddToPlaylist;

  const ExploreScreen({
    super.key,
    required this.controller,
    required this.onOpenFullPlayer,
    required this.onAddToPlaylist,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _searchController;

  static const List<String> _genres = [
    'Todos',
    'Classical',
    'Electronic',
    'Jazz',
    'Ambient',
    'Instrumental',
    'Folk',
  ];

  static const List<String> _categories = [
    'Todas',
    'Acervo aberto',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.controller.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return ListView(
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Explorar',
            style: TextStyle(
              color: VerticeColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => ctrl.applyFilters(query: value, searchRemote: false),
            onSubmitted: (value) => ctrl.applyFilters(query: value, searchRemote: true),
            decoration: InputDecoration(
              hintText: 'Pesquisar músicas, artistas, álbuns...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: VerticeColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        ctrl.applyFilters(query: '', searchRemote: false);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.cloud_sync_rounded, color: VerticeColors.purpleLight),
                    tooltip: 'Buscar também no acervo público online',
                    onPressed: () => ctrl.applyFilters(
                      query: _searchController.text,
                      searchRemote: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const SectionHeader(title: 'Gêneros'),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final g = _genres[index];
              final selected = ctrl.selectedGenre == g;
              return ChoiceChip(
                label: Text(g),
                selected: selected,
                selectedColor: VerticeColors.purpleNeon,
                backgroundColor: VerticeColors.surface,
                labelStyle: TextStyle(
                  color: selected ? VerticeColors.textPrimary : VerticeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: selected ? VerticeColors.purpleLight : VerticeColors.border,
                ),
                onSelected: (_) => ctrl.applyFilters(genre: g),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Categorias'),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final c = _categories[index];
              final selected = ctrl.selectedCategory == c;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                selectedColor: VerticeColors.purpleNeon,
                backgroundColor: VerticeColors.surface,
                labelStyle: TextStyle(
                  color: selected ? VerticeColors.textPrimary : VerticeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: selected ? VerticeColors.purpleLight : VerticeColors.border,
                ),
                onSelected: (_) => ctrl.applyFilters(category: c),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(
          title: 'Descoberta (${ctrl.filteredTracks.length})',
          actionLabel: 'Limpar',
          onAction: () {
            _searchController.clear();
            ctrl.applyFilters(query: '', genre: 'Todos', category: 'Todas');
          },
        ),
        if (ctrl.isLoadingCatalog)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: VerticeColors.purpleNeon),
            ),
          )
        else if (ctrl.filteredTracks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(
              child: Text(
                'Nenhuma faixa encontrada para os filtros selecionados.',
                style: TextStyle(color: VerticeColors.textSecondary),
              ),
            ),
          )
        else
          ...ctrl.filteredTracks.map(
            (track) => TrackTile(
              track: track,
              isCurrent: ctrl.currentTrack?.id == track.id,
              isPlaying: ctrl.isPlaying,
              isFavorite: ctrl.isFavorite(track.id),
              onTap: () async {
                await ctrl.playTrackFromList(track, ctrl.filteredTracks);
                widget.onOpenFullPlayer();
              },
              onFavoriteToggle: () => ctrl.toggleFavorite(track),
              onAddToPlaylist: () => widget.onAddToPlaylist(track),
            ),
          ),
      ],
    );
  }
}
