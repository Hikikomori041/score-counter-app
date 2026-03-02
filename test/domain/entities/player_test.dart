import 'package:flutter_test/flutter_test.dart';
import 'package:board_game_score/domain/entities/player.dart';

void main() {
  group('Player entity', () {
    const player = Player(
      id: 'player-1',
      name: 'Alice',
      colorHex: '#FF5733',
      iconName: 'person',
    );

    test('has correct properties', () {
      expect(player.id, equals('player-1'));
      expect(player.name, equals('Alice'));
      expect(player.colorHex, equals('#FF5733'));
      expect(player.iconName, equals('person'));
    });

    test('copyWith returns updated player', () {
      final updated = player.copyWith(name: 'Bob', colorHex: '#336699');
      expect(updated.id, equals('player-1'));
      expect(updated.name, equals('Bob'));
      expect(updated.colorHex, equals('#336699'));
      expect(updated.iconName, equals('person'));
    });

    test('equality is based on all fields', () {
      const same = Player(
        id: 'player-1',
        name: 'Alice',
        colorHex: '#FF5733',
        iconName: 'person',
      );
      const different = Player(
        id: 'player-2',
        name: 'Alice',
        colorHex: '#FF5733',
        iconName: 'person',
      );
      expect(player, equals(same));
      expect(player, isNot(equals(different)));
    });

    test('hashCode is consistent', () {
      const same = Player(
        id: 'player-1',
        name: 'Alice',
        colorHex: '#FF5733',
        iconName: 'person',
      );
      expect(player.hashCode, equals(same.hashCode));
    });

    test('toString includes key info', () {
      expect(player.toString(), contains('player-1'));
      expect(player.toString(), contains('Alice'));
    });
  });
}
