import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:board_game_score/app.dart';

void main() {
  testWidgets('App initializes and shows home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BoardGameScoreApp()),
    );
    await tester.pump();

    // The app should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home screen has correct title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BoardGameScoreApp()),
    );
    await tester.pump();

    expect(find.text('BoardGameScore'), findsOneWidget);
  });

  testWidgets('Home screen shows history button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BoardGameScoreApp()),
    );
    await tester.pump();

    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}
