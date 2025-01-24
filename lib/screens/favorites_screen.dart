import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spellProvider = Provider.of<SpellProvider>(context);
    final favoriteSpells = spellProvider.favoriteSpells;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ulubione Zaklęcia'),
      ),
      body: favoriteSpells.isEmpty
          ? Center(child: Text('Brak ulubionych zaklęć.'))
          : ListView.builder(
        itemCount: favoriteSpells.length,
        itemBuilder: (ctx, index) {
          final spell = favoriteSpells[index];
          return ListTile(
            title: Text(spell.name),
            subtitle: Text(spell.level.toString() + " LVL"),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                spellProvider.toggleFavorite(spell);
              },
            ),
            onTap: () async {
              // Sprawdzamy, czy opis jest załadowany, jeśli nie, to go załadujemy
              if (spell.description == null) {
                await spell.fetchDescription();
              }

              // Pokazujemy pełny opis zaklęcia w oknie dialogowym
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(spell.name),
                  content: SingleChildScrollView(child: Text(spell.description ?? 'Brak opisu')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
