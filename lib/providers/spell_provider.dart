import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpellProvider with ChangeNotifier {
  List<Spell> _spells = [];
  List<Spell> _favoriteSpells = [];
  List<Spell> _filteredSpells = []; // Przechowywanie przefiltrowanych zaklęć
  int? _currentFilterLevel; // Przechowuje aktualny poziom filtra

  SpellProvider() {
    _loadFavoriteSpells();
  }

  List<Spell> get spells => _filteredSpells.isNotEmpty ? _filteredSpells : _spells;
  List<Spell> get favoriteSpells => _favoriteSpells;

  // Pobierz zaklęcia z API
  Future<void> searchSpells(String query) async {
    final response = await http.get(Uri.parse('https://www.dnd5eapi.co/api/spells/?name=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Spell> loadedSpells = [];
      for (var item in data['results']) {
        final spell = Spell.fromJson(item);
        spell.isFavorite = _favoriteSpells.any((s) => s.name == spell.name);
        loadedSpells.add(spell);
      }

      _spells = loadedSpells;

      // Po wyszukiwaniu zastosuj aktualny filtr (jeśli istnieje)
      if (_currentFilterLevel != null) {
        filterSpellsByLevel(_currentFilterLevel);
      } else {
        _filteredSpells = []; // Jeśli brak filtra, wyczyść przefiltrowaną listę
      }

      notifyListeners();
    } else {
      throw Exception('Failed to load spells');
    }
  }

  // Filtrowanie zaklęć na podstawie poziomu kręgu
  void filterSpellsByLevel(int? level) {
    _currentFilterLevel = level; // Zapisz aktualny poziom filtra

    if (level == null) {
      // Jeśli poziom jest pusty, pokaż wszystkie zaklęcia
      _filteredSpells = [];
      print('Filtr wyczyszczony, pokazuję wszystkie zaklęcia.');
    } else {
      // Filtrowanie zaklęć według poziomu
      _filteredSpells = _spells.where((spell) => spell.level == level).toList();
      print('Filtr zastosowany: pokazuję zaklęcia poziomu $level. Liczba zaklęć: ${_filteredSpells.length}');
    }

    notifyListeners();
  }

  // Dodaj/usuwaj zaklęcie do ulubionych
  Future<void> toggleFavorite(Spell spell) async {
    final existingIndex = _favoriteSpells.indexWhere((s) => s.name == spell.name);

    if (existingIndex >= 0) {
      _favoriteSpells.removeAt(existingIndex);
      spell.isFavorite = false;
    } else {
      if (spell.description == null) {
        await spell.fetchDescription();
      }
      _favoriteSpells.add(spell);
      spell.isFavorite = true;
    }

    await _saveFavoriteSpells();
    notifyListeners();
  }

  Future<void> _loadFavoriteSpells() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSpellsData = prefs.getStringList('favoriteSpells') ?? [];
    _favoriteSpells = favoriteSpellsData.map((spellData) {
      final spellJson = jsonDecode(spellData);
      return Spell.fromJson(spellJson)..isFavorite = true;
    }).toList();
    notifyListeners();
  }

  Future<void> _saveFavoriteSpells() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSpellsData = _favoriteSpells.map((spell) => jsonEncode(spell.toJson())).toList();
    await prefs.setStringList('favoriteSpells', favoriteSpellsData);
  }
}
