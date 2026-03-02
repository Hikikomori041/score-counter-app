import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../../domain/entities/game_session.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedTypeFilter;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(sessionsProvider),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (sessions) {
          final filtered = _selectedTypeFilter == null
              ? sessions
              : sessions
                  .where((s) => s.gameType == _selectedTypeFilter)
                  .toList();

          return Column(
            children: [
              _buildFilterChips(sessions),
              if (filtered.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune partie pour le moment.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) =>
                        _SessionCard(session: filtered[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(List<GameSession> sessions) {
    final types = sessions.map((s) => s.gameType).toSet().toList();

    if (types.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            label: const Text('Tous'),
            selected: _selectedTypeFilter == null,
            onSelected: (_) => setState(() => _selectedTypeFilter = null),
          ),
          const SizedBox(width: 8),
          ...types.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_typeLabel(type)),
                  selected: _selectedTypeFilter == type,
                  onSelected: (selected) => setState(() =>
                      _selectedTypeFilter = selected ? type : null),
                ),
              )),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'mtg':
        return 'MTG';
      case 'grid':
        return 'Grille';
      default:
        return 'Standard';
    }
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final duration = session.endedAt?.difference(session.startedAt);

    final sortedScores = session.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _typeIcon(session.gameType),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(session.gameName,
            style:
                const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(session.startedAt)),
            if (duration != null)
              Text(
                '${_formatDuration(duration)} • ${session.scores.length} joueurs',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ...sortedScores.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final e = entry.value;
                  final isWinner = e.key == session.winnerId;
                  return ListTile(
                    dense: true,
                    leading: isWinner
                        ? const Icon(Icons.emoji_events, color: Colors.amber)
                        : CircleAvatar(
                            radius: 12,
                            child: Text(
                              '$rank',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                    title: Text(e.key),
                    trailing: Text(
                      '${e.value} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'mtg':
        return Icons.auto_awesome;
      case 'grid':
        return Icons.grid_on;
      default:
        return Icons.casino;
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}
