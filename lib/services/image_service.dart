import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImage(
    ImageSource source, {
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;

      return await image.readAsBytes();
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> saveImage(Uint8List imageBytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$filename');

      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<Uint8List?> cropImage(Uint8List imageBytes, Rect cropRect) async {
    try {
      // TODO: 实现图片裁剪
      return imageBytes;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  Future<List<String>> getRecentImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .map((file) => file.path)
          .toList();

      // 按时间倒序排序
      files.sort((a, b) => b.compareTo(a));
      return files;
    } catch (e) {
      print('Error getting recent images: $e');
      return [];
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
