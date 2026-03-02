import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/database/database_factory_initializer_stub.dart'
    if (dart.library.ffi) 'core/database/database_factory_initializer_desktop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    runApp(const _WebNotSupportedApp());
    return;
  }

  await initializeDatabaseFactory();

  try {
    await DatabaseHelper.instance.database;
  } catch (error) {
    debugPrint('Database initialization failed: $error');
  }

  runApp(const ProviderScope(child: BoardGameScoreApp()));
}

class _WebNotSupportedApp extends StatelessWidget {
  const _WebNotSupportedApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Cette application n\'est pas encore compatible Web.\n'
              'Utilise Windows ou Android avec Flutter.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
