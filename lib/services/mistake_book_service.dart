import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/mistake.dart';

import 'package:uuid/uuid.dart';

class MistakeBookService {
  static final MistakeBookService _instance = MistakeBookService._internal();
  factory MistakeBookService() => _instance;
  MistakeBookService._internal();

  static const _fileName = 'mistakes.json';
  final _uuid = const Uuid();
  List<Mistake>? _cachedMistakes;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<Mistake>> getAllMistakes() async {
    if (_cachedMistakes != null) {
      return _cachedMistakes!;
    }

    try {
      final file = await _localFile;
      if (!await file.exists()) {
        _cachedMistakes = [];
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      _cachedMistakes = jsonList.map((json) => Mistake.fromJson(json)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return _cachedMistakes!;
    } catch (e) {
      print('Error reading mistakes: $e');
      return [];
    }
  }

  Future<Mistake> addMistake({
    required String id,
    required String content,
    required String answer,
    required String explanation,
    required String subject,
    required String difficulty,
  }) async {
    final mistakes = await getAllMistakes();

    final mistake = Mistake(
      id: _uuid.v4(),
      question: content,
      answer: answer,
      explanation: explanation,
      subject: subject,
      difficulty: difficulty,
    );

    mistakes.insert(0, mistake);
    await _saveMistakes(mistakes);

    return mistake;
  }

  Future<void> removeMistake(String id) async {
    final mistakes = await getAllMistakes();
    mistakes.removeWhere((m) => m.id == id);
    await _saveMistakes(mistakes);
  }

  Future<void> updateMistake(Mistake mistake) async {
    final mistakes = await getAllMistakes();
    final index = mistakes.indexWhere((m) => m.id == mistake.id);
    if (index != -1) {
      mistakes[index] = mistake;
      await _saveMistakes(mistakes);
    }
  }

  Future<void> markAsReviewed(String id, {bool mastered = false}) async {
    final mistakes = await getAllMistakes();
    final index = mistakes.indexWhere((m) => m.id == id);
    if (index != -1) {
      mistakes[index] = mistakes[index].copyWith(
        reviewedAt: DateTime.now(),
        mastered: mastered,
      );
      await _saveMistakes(mistakes);
    }
  }

  Future<void> _saveMistakes(List<Mistake> mistakes) async {
    try {
      final file = await _localFile;
      final data = mistakes.map((m) => m.toJson()).toList();
      await file.writeAsString(json.encode(data));
      _cachedMistakes = mistakes;
    } catch (e) {
      print('Error saving mistakes: $e');
      throw Exception('保存失败：$e');
    }
  }

  Future<void> clearCache() async {
    _cachedMistakes = null;
  }
}
