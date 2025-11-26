import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EdgeDetector {
  static Future<List<Offset>> detectEdges(CameraImage image) async {
    try {
      // 将相机图像转换为灰度图像
      final inputImage = await _convertYUV420toGrayscale(image);

      // 使用 Canny 边缘检测
      final edges = await compute(_detectEdgesIsolate, inputImage);

      // 查找轮廓
      final corners = await compute(_findCorners, edges);

      return corners;
    } catch (e) {
      print('Edge detection error: $e');
      return [];
    }
  }

  static Future<List<int>> _convertYUV420toGrayscale(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;
    final List<int> grayscale = List<int>.filled(width * height, 0);

    // YUV420 格式中，Y 平面包含亮度信息，可直接用作灰度图像
    final yPlane = image.planes[0].bytes;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        grayscale[yIndex] = yPlane[yIndex];
      }
    }

    return grayscale;
  }

  static List<List<int>> _detectEdgesIsolate(List<int> grayscale) {
    // 使用 Sobel 算子计算梯度
    final int width = grayscale.length ~/ grayscale[0];
    final int height = grayscale[0];

    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];

    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];

    final List<List<int>> edges = List.generate(
      height,
      (i) => List.filled(width, 0),
      growable: false,
    );

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0;
        double gy = 0;

        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            final pixel = grayscale[(y + i) * width + (x + j)];
            gx += pixel * sobelX[i + 1][j + 1];
            gy += pixel * sobelY[i + 1][j + 1];
          }
        }

        final magnitude = math.sqrt(gx * gx + gy * gy).round();
        edges[y][x] = magnitude > 128 ? 255 : 0; // 阈值处理
      }
    }

    return edges;
  }

  static List<Offset> _findCorners(List<List<int>> edges) {
    final int height = edges.length;
    final int width = edges[0].length;
    final List<Offset> corners = [];

    // 使用 Harris 角点检测
    // 简化版本：查找边缘图像中的极值点
    for (int y = 10; y < height - 10; y += 10) {
      for (int x = 10; x < width - 10; x += 10) {
        if (edges[y][x] == 255) {
          bool isCorner = true;

          // 检查 8 邻域
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (i == 0 && j == 0) continue;
              if (edges[y + i][x + j] > edges[y][x]) {
                isCorner = false;
                break;
              }
            }
            if (!isCorner) break;
          }

          if (isCorner) {
            corners.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }
    }

    // 如果检测到太多角点，只保留最显著的 4 个
    if (corners.length > 4) {
      corners.sort((a, b) {
        final distanceA = (a.dx - width / 2).abs() + (a.dy - height / 2).abs();
        final distanceB = (b.dx - width / 2).abs() + (b.dy - height / 2).abs();
        return distanceA.compareTo(distanceB);
      });
      return corners.take(4).toList();
    }

    return corners;
  }
}
