import 'dart:convert';
import 'package:http/http.dart' as http;

class Spell {
  final String name;
  final String url;
  final int level;
  bool isFavorite;
  String? description;
  List<String> classes; // Dodajemy listę klas

  Spell({
    required this.name,
    required this.url,
    required this.level,
    this.isFavorite = false,
    this.description,
    this.classes = const [], // Domyślnie pusta lista
  });

  // Metoda do pobierania pełnych informacji o zaklęciu, w tym opisu i klas
  Future<void> fetchDescription() async {
  final response = await http.get(Uri.parse('https://www.dnd5eapi.co$url'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    description = data['desc']?.join('\n') ?? 'Brak opisu';

    // Pobierz klasy postaci
    classes = (data['classes'] as List<dynamic>)
        .map((cls) => cls['name'] as String)
        .toList();
  } else {
    description = 'Brak opisu';
    classes = [];
  }
}

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'level': level,
      'isFavorite': isFavorite,
      'description': description,
      'classes': classes,
    };
  }

  // Tworzenie obiektu Spell z mapy JSON
  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'],
      url: json['url'],
      level: json['level'],
    );
  }
}
