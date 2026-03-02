import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    required this.colorHex,
    this.radius = 24,
    this.showName = false,
  });

  final String name;
  final String colorHex;
  final double radius;
  final bool showName;

  Color get _color {
    try {
      final hex = colorHex.replaceFirst('#', '');
      final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
      return Color(value);
    } catch (_) {
      return Colors.purple;
    }
  }

  bool _isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final bg = _color;
    final fg = _isLight(bg) ? Colors.black87 : Colors.white;

    if (showName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: bg,
            child: Text(
              _initials,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.7,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        _initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
