class Player {
  const Player({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  final String id;
  final String name;
  final String colorHex;
  final String iconName;

  Player copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? iconName,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorHex == other.colorHex &&
          iconName == other.iconName;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ colorHex.hashCode ^ iconName.hashCode;

  @override
  String toString() =>
      'Player(id: $id, name: $name, colorHex: $colorHex, iconName: $iconName)';
}
