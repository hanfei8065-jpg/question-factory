import 'dart:convert';

class World {
  final String id;
  final String title;
  final String subject;
  final int grade;
  final String description;
  final int order;
  final String imageUrl;
  final Map<String, dynamic> unlockRequirement;

  World({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.description,
    required this.order,
    required this.imageUrl,
    required this.unlockRequirement,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'grade': grade,
      'description': description,
      'order': order,
      'imageUrl': imageUrl,
      'unlockRequirement': unlockRequirement,
    };
  }

  factory World.fromJson(Map<String, dynamic> json) {
    return World(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      grade: json['grade'],
      description: json['description'],
      order: json['order'],
      imageUrl: json['imageUrl'],
      unlockRequirement: json['unlockRequirement'],
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
