import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';
import './favorites_screen.dart';

class SpellSearchScreen extends StatefulWidget {
  @override
  _SpellSearchScreenState createState() => _SpellSearchScreenState();
}

class _SpellSearchScreenState extends State<SpellSearchScreen> {
  final _controller = TextEditingController();
  int? _selectedLevel; // Wybrany poziom kręgu zaklęć

  @override
  Widget build(BuildContext context) {
    final spellProvider = Provider.of<SpellProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('D&D Spell Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Otwórz okno dialogowe z filtrem
              _showFilterDialog(context, spellProvider);
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // Nawigacja do ekranu ulubionych zaklęć
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onChanged: (text) {
                spellProvider.searchSpells(text);
              },
              decoration: InputDecoration(
                labelText: 'Search for a spell',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    spellProvider.searchSpells(_controller.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: spellProvider.spells.length,
              itemBuilder: (ctx, index) {
                final spell = spellProvider.spells[index];
                return ListTile(
                  title: Text(spell.name),
                  subtitle: Text('Level: ${spell.level}'),
                  trailing: IconButton(
                    icon: Icon(
                      spell.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: spell.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      spellProvider.toggleFavorite(spell);
                    },
                  ),
                  onTap: () async {
                    await spell.fetchDescription();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(spell.name),
                        content: SingleChildScrollView(
                          child: Text(spell.description ?? 'Brak opisu'),
                        ),
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
          ),
        ],
      ),
    );
  }

  // Wyświetl okno dialogowe z filtrem
  void _showFilterDialog(BuildContext context, SpellProvider spellProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Filter Spells by Level'),
          content: DropdownButtonFormField<int>(
            value: _selectedLevel,
            hint: Text('Select Level'),
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level == 0 ? 'Cantrip' : 'Level $level'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                spellProvider.filterSpellsByLevel(_selectedLevel); // Zastosuj filtr
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedLevel = null;
                });
                spellProvider.filterSpellsByLevel(null); // Wyczyść filtr
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
