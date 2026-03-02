import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/providers.dart';
import '../../widgets/player_avatar.dart';
import '../../../domain/entities/game_session.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.gameType,
    required this.players,
  });

  final String gameId;
  final String gameName;
  final String gameType;
  final List<Map<String, dynamic>> players;

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  late Map<String, int> _scores;
  final _uuid = const Uuid();
  late DateTime _startedAt;
  final List<List<int>> _gridRounds = [];

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    final initialScore = widget.gameType == 'mtg' ? 20 : 0;
    _scores = {
      for (final p in widget.players) p['id'] as String: initialScore,
    };
    if (widget.gameType == 'grid') {
      _gridRounds.add(List.filled(widget.players.length, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName),
        actions: [
          if (widget.gameType == 'mtg')
            PopupMenuButton<int>(
              icon: const Icon(Icons.settings),
              onSelected: (startLife) {
                setState(() {
                  for (final id in _scores.keys) {
                    _scores[id] = startLife;
                  }
                });
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 20, child: Text('Commencer à 20')),
                const PopupMenuItem(value: 40, child: Text('Commencer à 40')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildScoringContent()),
          _buildEndGameButton(),
        ],
      ),
    );
  }

  Widget _buildScoringContent() {
    switch (widget.gameType) {
      case 'mtg':
        return _buildMtgScoring();
      case 'grid':
        return _buildGridScoring();
      default:
        return _buildStandardScoring();
    }
  }

  Widget _buildStandardScoring() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.players.length,
      itemBuilder: (ctx, index) {
        final player = widget.players[index];
        final id = player['id'] as String;
        final name = player['name'] as String;
        final colorHex = player['colorHex'] as String;
        final score = _scores[id] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    PlayerAvatar(name: name, colorHex: colorHex),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '$score',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreButton(
                      label: '-5',
                      onTap: () =>
                          setState(() => _scores[id] = score - 5),
                    ),
                    _ScoreButton(
                      label: '-1',
                      onTap: () =>
                          setState(() => _scores[id] = score - 1),
                    ),
                    _ScoreButton(
                      label: '+1',
                      onTap: () =>
                          setState(() => _scores[id] = score + 1),
                      filled: true,
                    ),
                    _ScoreButton(
                      label: '+5',
                      onTap: () =>
                          setState(() => _scores[id] = score + 5),
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMtgScoring() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.players.length,
      itemBuilder: (ctx, index) {
        final player = widget.players[index];
        final id = player['id'] as String;
        final name = player['name'] as String;
        final colorHex = player['colorHex'] as String;
        final life = _scores[id] ?? 20;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                PlayerAvatar(name: name, colorHex: colorHex, radius: 32),
                const SizedBox(height: 8),
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text(
                  '$life',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: life <= 5
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 56,
                      child: FilledButton.tonal(
                        onPressed: () =>
                            setState(() => _scores[id] = life - 1),
                        child: const Text('-1',
                            style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      height: 56,
                      child: FilledButton(
                        onPressed: () =>
                            setState(() => _scores[id] = life + 1),
                        child: const Text('+1',
                            style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridScoring() {
    final playerNames =
        widget.players.map((p) => p['name'] as String).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer,
                ),
                columns: [
                  const DataColumn(label: Text('Round')),
                  ...playerNames.map(
                    (name) => DataColumn(label: Text(name)),
                  ),
                ],
                rows: [
                  ..._gridRounds.asMap().entries.map((entry) {
                    final roundIdx = entry.key;
                    final roundScores = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('${roundIdx + 1}')),
                        ...List.generate(
                          widget.players.length,
                          (pIdx) => DataCell(
                            GestureDetector(
                              onTap: () =>
                                  _editRoundScore(roundIdx, pIdx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${roundScores[pIdx]}'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  DataRow(
                    color: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    cells: [
                      const DataCell(Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                      ...List.generate(
                        widget.players.length,
                        (pIdx) {
                          final total = _gridRounds.fold(
                              0, (sum, round) => sum + round[pIdx]);
                          return DataCell(Text('$total',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.tonal(
            onPressed: _addGridRound,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text('Ajouter un round'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addGridRound() {
    setState(() {
      _gridRounds.add(List.filled(widget.players.length, 0));
    });
  }

  Future<void> _editRoundScore(int roundIdx, int playerIdx) async {
    final controller = TextEditingController(
        text: '${_gridRounds[roundIdx][playerIdx]}');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            'Score de ${widget.players[playerIdx]['name']} - Round ${roundIdx + 1}'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            labelText: 'Score',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text) ?? 0),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _gridRounds[roundIdx][playerIdx] = result);
    }
  }

  Map<String, int> _computeFinalScores() {
    if (widget.gameType == 'grid') {
      final totals = <String, int>{};
      for (var i = 0; i < widget.players.length; i++) {
        final id = widget.players[i]['id'] as String;
        totals[id] = _gridRounds.fold(0, (sum, round) => sum + round[i]);
      }
      return totals;
    }
    return Map.from(_scores);
  }

  String? _computeWinnerId(Map<String, int> finalScores) {
    if (finalScores.isEmpty) return null;
    // For MTG, the player with the most remaining life wins.
    // For standard and grid, highest score wins.
    return finalScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Widget _buildEndGameButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _endGame,
          icon: const Icon(Icons.flag),
          label: const Text('Terminer la partie'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ),
    );
  }

  Future<void> _endGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer la partie'),
        content: const Text('Voulez-vous sauvegarder et terminer la partie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final finalScores = _computeFinalScores();
    final winnerId = _computeWinnerId(finalScores);

    final session = GameSession(
      id: _uuid.v4(),
      gameId: widget.gameId,
      gameName: widget.gameName,
      gameType: widget.gameType,
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      scores: finalScores,
      winnerId: winnerId,
    );

    await ref.read(sessionRepositoryProvider).insertSession(session);
    await ref.read(gameRepositoryProvider).updateLastUsed(
          widget.gameId,
          DateTime.now(),
        );

    ref.invalidate(sessionsProvider);
    ref.invalidate(gamesProvider);
    ref.invalidate(sortedGamesProvider);

    if (mounted) {
      _showResultsDialog(finalScores, winnerId);
    }
  }

  void _showResultsDialog(Map<String, int> finalScores, String? winnerId) {
    final winnerName = winnerId != null
        ? widget.players
            .firstWhere(
              (p) => p['id'] == winnerId,
              orElse: () => {'name': 'Inconnu'},
            )['name'] as String
        : null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Fin de partie!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (winnerName != null) ...[
              const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
              const SizedBox(height: 8),
              Text(
                '🏆 $winnerName gagne!',
                style: Theme.of(ctx).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 24),
            ],
            ...finalScores.entries.map((e) {
              final playerName = widget.players.firstWhere(
                  (p) => p['id'] == e.key,
                  orElse: () => {'name': e.key})['name'] as String;
              return ListTile(
                dense: true,
                leading: e.key == winnerId
                    ? const Icon(Icons.star, color: Colors.amber)
                    : const Icon(Icons.person_outline),
                title: Text(playerName),
                trailing: Text('${e.value} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        width: 64,
        height: 48,
        child: FilledButton(
          onPressed: onTap,
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      );
    }
    return SizedBox(
      width: 64,
      height: 48,
      child: FilledButton.tonal(
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
