import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/providers.dart';
import '../../widgets/player_avatar.dart';
import '../../../domain/entities/player.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.gameType,
  });

  final String gameId;
  final String gameName;
  final String gameType;

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  final Set<String> _selectedPlayerIds = {};
  final _uuid = const Uuid();

  int get _minPlayers => widget.gameType == 'mtg' ? 1 : 2;

  bool get _canStart => _selectedPlayerIds.length >= _minPlayers;

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle partie\n${widget.gameName}',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 16)),
      ),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (players) => Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Joueurs',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedPlayerIds.length} sélectionné(s)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (players.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Aucun joueur.\nAppuyez sur + pour en ajouter.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...players.map((player) => _PlayerListTile(
                          player: player,
                          isSelected:
                              _selectedPlayerIds.contains(player.id),
                          onToggle: () => setState(() {
                            if (_selectedPlayerIds.contains(player.id)) {
                              _selectedPlayerIds.remove(player.id);
                            } else {
                              _selectedPlayerIds.add(player.id);
                            }
                          }),
                          onDelete: () => _deletePlayer(player),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_canStart)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sélectionnez au moins $_minPlayers joueur(s)',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: _canStart ? () => _startGame(players) : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Commencer la partie'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerDialog(context),
        tooltip: 'Ajouter un joueur',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _startGame(List<Player> allPlayers) {
    final selectedPlayers = allPlayers
        .where((p) => _selectedPlayerIds.contains(p.id))
        .map((p) => {'id': p.id, 'name': p.name, 'colorHex': p.colorHex})
        .toList();

    context.push('/scoring', extra: {
      'gameId': widget.gameId,
      'gameName': widget.gameName,
      'gameType': widget.gameType,
      'players': selectedPlayers,
    });
  }

  Future<void> _deletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le joueur'),
        content: Text(
            'Voulez-vous supprimer ${player.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(playerRepositoryProvider).deletePlayer(player.id);
      setState(() => _selectedPlayerIds.remove(player.id));
      ref.invalidate(playersProvider);
    }
  }

  Future<void> _showAddPlayerDialog(BuildContext context) async {
    final nameController = TextEditingController();
    Color pickedColor = Colors.blue;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Ajouter un joueur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du joueur',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Couleur'),
              const SizedBox(height: 8),
              BlockPicker(
                pickerColor: pickedColor,
                onColorChanged: (c) => setState(() => pickedColor = c),
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
                final colorHex =
                    '#${pickedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                final newPlayer = Player(
                  id: _uuid.v4(),
                  name: nameController.text.trim(),
                  colorHex: colorHex,
                  iconName: 'person',
                );
                await ref
                    .read(playerRepositoryProvider)
                    .insertPlayer(newPlayer);
                ref.invalidate(playersProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerListTile extends StatelessWidget {
  const _PlayerListTile({
    required this.player,
    required this.isSelected,
    required this.onToggle,
    required this.onDelete,
  });

  final Player player;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PlayerAvatar(
        name: player.name,
        colorHex: player.colorHex,
      ),
      title: Text(player.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            color: Theme.of(context).colorScheme.error,
          ),
          Checkbox(
            value: isSelected,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
      onTap: onToggle,
      selected: isSelected,
    );
  }
}
