import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'data/hive_boxes.dart';
import 'data/models/friend.dart';
import 'data/models/game_match.dart';
import 'data/models/game_settings.dart';
import 'providers/games_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/main_nav_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const PointMateApp());
}

class PointMateApp extends StatelessWidget {
  const PointMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Box<GameSettings>>.value(
          value: Hive.box<GameSettings>(HiveBoxes.gameSettings),
        ),
        Provider<Box<GameMatch>>.value(
          value: Hive.box<GameMatch>(HiveBoxes.gameMatches),
        ),
        Provider<Box<Friend>>.value(
          value: Hive.box<Friend>(HiveBoxes.friends),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GamesProvider(
            matchBox: ctx.read<Box<GameMatch>>(),
            settingsBox: ctx.read<Box<GameSettings>>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PointMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainNavScaffold(),
      ),
    );
  }
}
