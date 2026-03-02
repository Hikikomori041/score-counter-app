import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../widgets/game_tile.dart';
import '../../../domain/entities/game.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(sortModeProvider);
    final gamesAsync = ref.watch(sortedGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BoardGameScore'),
        actions: [
          IconButton(
            icon: Icon(
              sortMode == SortMode.lastUsed
                  ? Icons.access_time
                  : Icons.sort_by_alpha,
            ),
            tooltip: sortMode == SortMode.lastUsed
                ? 'Trier par ordre alphabétique'
                : 'Trier par utilisation récente',
            onPressed: () {
              ref.read(sortModeProvider.notifier).state =
                  sortMode == SortMode.lastUsed
                      ? SortMode.alphabetical
                      : SortMode.lastUsed;
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (games) {
          final standardGames =
              games.where((g) => g.type == GameType.standard).toList();
          final gridGames =
              games.where((g) => g.type == GameType.grid).toList();
          final mtgGames =
              games.where((g) => g.type == GameType.mtg).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(gamesProvider);
              ref.invalidate(sortedGamesProvider);
            },
            child: ListView(
              children: [
                const _SectionHeader(title: 'Jeux spéciaux'),
                if (mtgGames.isNotEmpty)
                  ...mtgGames.map(
                    (game) => GameTile(
                      game: game,
                      subtitle: 'Points de vie • Duel ou multijoueur',
                      onTap: () => _navigateToSetup(context, game),
                      onFavoriteToggle: () =>
                          _toggleFavorite(ref, game),
                    ),
                  ),
                if (gridGames.isNotEmpty) ...[
                  GameTile(
                    game: Game(
                      id: '__grid_header__',
                      name: 'Jeux avec grille de score',
                      type: GameType.grid,
                      isFavorite: false,
                      lastUsed: DateTime.fromMillisecondsSinceEpoch(0),
                    ),
                    subtitle: 'Skyjo, Scrabble...',
                    onTap: () {},
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      child: Icon(
                        Icons.grid_on,
                        color:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  ...gridGames.map(
                    (game) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: GameTile(
                        game: game,
                        onTap: () => _navigateToSetup(context, game),
                        onFavoriteToggle: () =>
                            _toggleFavorite(ref, game),
                      ),
                    ),
                  ),
                ],
                const _SectionHeader(title: 'Jeux standard'),
                ...standardGames.map(
                  (game) => GameTile(
                    game: game,
                    onTap: () => _navigateToSetup(context, game),
                    onFavoriteToggle: () => _toggleFavorite(ref, game),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGameDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau jeu'),
      ),
    );
  }

  void _navigateToSetup(BuildContext context, Game game) {
    context.push('/setup', extra: {
      'gameId': game.id,
      'gameName': game.name,
      'gameType': game.type.name,
    });
  }

  Future<void> _toggleFavorite(WidgetRef ref, Game game) async {
    await ref
        .read(gameRepositoryProvider)
        .toggleFavorite(game.id, !game.isFavorite);
    ref.invalidate(gamesProvider);
    ref.invalidate(sortedGamesProvider);
  }

  Future<void> _showAddGameDialog(
      BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    GameType selectedType = GameType.standard;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nouveau jeu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du jeu',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Type de jeu'),
              ...GameType.values.map(
                (t) => RadioListTile<GameType>(
                  title: Text(_gameTypeLabel(t)),
                  value: t,
                  groupValue: selectedType,
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final repo = ref.read(gameRepositoryProvider);
                await repo.insertGame(Game(
                  id: nameController.text
                      .trim()
                      .toLowerCase()
                      .replaceAll(' ', '-'),
                  name: nameController.text.trim(),
                  type: selectedType,
                  isFavorite: false,
                  lastUsed: DateTime.fromMillisecondsSinceEpoch(0),
                ));
                ref.invalidate(gamesProvider);
                ref.invalidate(sortedGamesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  String _gameTypeLabel(GameType type) {
    switch (type) {
      case GameType.standard:
        return 'Standard (scores par joueur)';
      case GameType.mtg:
        return 'Magic: The Gathering (points de vie)';
      case GameType.grid:
        return 'Grille (tableau de scores)';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
