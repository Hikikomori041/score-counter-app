import 'package:flutter_test/flutter_test.dart';
import 'package:board_game_score/domain/entities/game.dart';

void main() {
  group('Game entity', () {
    final lastUsed = DateTime(2024, 1, 15);
    final game = Game(
      id: 'catan',
      name: 'Catan',
      type: GameType.standard,
      isFavorite: false,
      lastUsed: lastUsed,
    );

    test('has correct properties', () {
      expect(game.id, equals('catan'));
      expect(game.name, equals('Catan'));
      expect(game.type, equals(GameType.standard));
      expect(game.isFavorite, isFalse);
      expect(game.lastUsed, equals(lastUsed));
    });

    test('copyWith updates only specified fields', () {
      final updated = game.copyWith(isFavorite: true, name: 'Catan Updated');
      expect(updated.id, equals('catan'));
      expect(updated.name, equals('Catan Updated'));
      expect(updated.type, equals(GameType.standard));
      expect(updated.isFavorite, isTrue);
      expect(updated.lastUsed, equals(lastUsed));
    });

    test('GameType enum has expected values', () {
      expect(GameType.values, containsAll([
        GameType.standard,
        GameType.mtg,
        GameType.grid,
      ]));
    });

    test('equality compares all fields', () {
      final same = Game(
        id: 'catan',
        name: 'Catan',
        type: GameType.standard,
        isFavorite: false,
        lastUsed: lastUsed,
      );
      final different = Game(
        id: 'catan',
        name: 'Catan',
        type: GameType.mtg,
        isFavorite: false,
        lastUsed: lastUsed,
      );
      expect(game, equals(same));
      expect(game, isNot(equals(different)));
    });

    test('MTG game type name is correct', () {
      final mtgGame = game.copyWith(type: GameType.mtg);
      expect(mtgGame.type.name, equals('mtg'));
    });

    test('toString includes key info', () {
      expect(game.toString(), contains('catan'));
      expect(game.toString(), contains('Catan'));
    });
  });
}
