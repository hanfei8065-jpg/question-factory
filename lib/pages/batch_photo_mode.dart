import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/batch_results_page.dart';
import '../services/openai_service.dart';
import 'dart:io';

class BatchPhotoMode extends StatefulWidget {
  const BatchPhotoMode({super.key});

  @override
  State<BatchPhotoMode> createState() => _BatchPhotoModeState();
}

class _BatchPhotoModeState extends State<BatchPhotoMode> {
  final List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedPhotos.add(File(photo.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> photos = await _picker.pickMultiImage();
    if (photos.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(photos.map((p) => File(p.path)));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _processPhotos() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先添加题目照片')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final results = <Map<String, dynamic>>[];
      final openAiService = OpenAIService();

      for (final photo in _selectedPhotos) {
        final result = await openAiService.processImage(photo.path);
        results.add(result);
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BatchResultsPage(results: results),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('处理失败：$e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('批量识题')),
      body: Column(
        children: [
          // 照片网格
          Expanded(
            child: _selectedPhotos.isEmpty
                ? const Center(child: Text('点击下方按钮添加题目照片'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              _selectedPhotos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              color: Colors.red,
                              onPressed: () => _removePhoto(index),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // 底部按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('相册'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isProcessing ? null : _processPhotos,
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : const Text('开始识别'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
