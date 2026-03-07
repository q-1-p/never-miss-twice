import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/habit_provider.dart';
import 'services/dock_badge_service.dart';
import 'services/storage_service.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HabitProvider(storage, DockBadgeService()),
      child: const NeverMissTwiceApp(),
    ),
  );
}

class NeverMissTwiceApp extends StatelessWidget {
  const NeverMissTwiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Never Miss Twice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
