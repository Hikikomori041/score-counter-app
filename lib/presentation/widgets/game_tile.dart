import 'package:flutter/material.dart';
import '../../../domain/entities/game.dart';

class GameTile extends StatelessWidget {
  const GameTile({
    super.key,
    required this.game,
    required this.onTap,
    this.onFavoriteToggle,
    this.subtitle,
    this.leading,
  });

  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final String? subtitle;
  final Widget? leading;

  IconData get _gameIcon {
    switch (game.type) {
      case GameType.mtg:
        return Icons.auto_awesome;
      case GameType.grid:
        return Icons.grid_on;
      case GameType.standard:
        return Icons.casino;
    }
  }

  Color _chipColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (game.type) {
      case GameType.mtg:
        return cs.tertiary;
      case GameType.grid:
        return cs.secondary;
      case GameType.standard:
        return cs.primary;
    }
  }

  String get _typeLabel {
    switch (game.type) {
      case GameType.mtg:
        return 'MTG';
      case GameType.grid:
        return 'Grille';
      case GameType.standard:
        return 'Standard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              leading ??
                  CircleAvatar(
                    backgroundColor: _chipColor(context).withOpacity(0.2),
                    child: Icon(_gameIcon, color: _chipColor(context)),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _chipColor(context).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _typeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _chipColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onFavoriteToggle != null)
                IconButton(
                  icon: Icon(
                    game.isFavorite ? Icons.star : Icons.star_border,
                    color: game.isFavorite
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
