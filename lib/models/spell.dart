import 'dart:convert';
import 'package:http/http.dart' as http;

class Spell {
  final String name;
  final String url;
  final int level;
  bool isFavorite;
  String? description;
  List<String> classes; // List of classes

  Spell({
    required this.name,
    required this.url,
    required this.level,
    this.isFavorite = false,
    this.description,
    this.classes = const [], // Default empty list
  });

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

  // Method to fetch full information about the spell, including description and classes
  Future<void> fetchDescription() async {
    final response = await http.get(Uri.parse('https://www.dnd5eapi.co$url'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      description = data['desc']?.join('\n') ?? 'No description available';

      // Fetch character classes
      classes = (data['classes'] as List<dynamic>)
          .map((cls) => cls['name'] as String)
          .toList();
    } else {
      description = 'No description available';
      classes = [];
    }
  }

  // Create a Spell object from a JSON map
  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'],
      url: json['url'],
      level: json['level'],
    );
  }
}
