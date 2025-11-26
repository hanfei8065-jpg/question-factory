import 'dart:convert';
import 'question.dart';

class Level {
  final String id;
  final String title;
  final List<String> questionIds; // 关联的题目ID列表
  final String unlockRule; // 解锁规则
  final Map<String, dynamic> reward; // 奖励（金币、经验等）
  final String worldId; // 所属世界ID
  final int order; // 关卡顺序

  Level({
    required this.id,
    required this.title,
    required this.questionIds,
    required this.unlockRule,
    required this.reward,
    required this.worldId,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questionIds': questionIds,
      'unlockRule': unlockRule,
      'reward': reward,
      'worldId': worldId,
      'order': order,
    };
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      title: json['title'],
      questionIds: List<String>.from(json['questionIds']),
      unlockRule: json['unlockRule'],
      reward: json['reward'],
      worldId: json['worldId'],
      order: json['order'],
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
