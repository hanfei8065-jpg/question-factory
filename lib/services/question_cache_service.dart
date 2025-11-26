import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class QuestionCacheService {
  static final QuestionCacheService _instance =
      QuestionCacheService._internal();
  factory QuestionCacheService() => _instance;
  QuestionCacheService._internal();

  late Box _cache;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/question_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      Hive.init(cacheDir.path);
      _cache = await Hive.openBox('questions');
      _isInitialized = true;
    }
  }

  /// 计算图片的哈希值作为缓存key
  Future<String> _computeImageHash(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return _computeBytesHash(bytes);
  }

  String _computeBytesHash(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 检查缓存中是否有结果
  Future<Map<String, dynamic>?> getCachedResult(File imageFile) async {
    await init();
    final hash = await _computeImageHash(imageFile);
    final cachedData = _cache.get(hash);
    if (cachedData != null) {
      return jsonDecode(cachedData as String) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasOfflineQuestions() async {
    await init();
    return _cache.isNotEmpty;
  }

  /// 保存识别结果到缓存
  Future<void> cacheResult(File imageFile, Map<String, dynamic> result) async {
    await init();
    final hash = await _computeImageHash(imageFile);
    await _cache.put(hash, jsonEncode(result));
  }

  /// 清理过期缓存（超过7天的缓存）
  Future<void> cleanExpiredCache() async {
    await init();
    final now = DateTime.now();
    final keys = _cache.keys.toList();
    for (final key in keys) {
      final data =
          jsonDecode(_cache.get(key) as String) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      if (now.difference(timestamp).inDays > 7) {
        await _cache.delete(key);
      }
    }
  }

  /// 获取所有缓存的问题
  Future<List<Map<String, dynamic>>> getAllCachedQuestions() async {
    await init();
    final questions = <Map<String, dynamic>>[];
    for (final key in _cache.keys) {
      final data =
          jsonDecode(_cache.get(key) as String) as Map<String, dynamic>;
      questions.add(data);
    }
    return questions;
  }
}
