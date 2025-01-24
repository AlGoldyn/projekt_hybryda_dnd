import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/spell_provider.dart';
import './screens/spell_search_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpellProvider(),
      child: MaterialApp(
        title: 'D&D Spells',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SpellSearchScreen(),
      ),
    );
  }
}
