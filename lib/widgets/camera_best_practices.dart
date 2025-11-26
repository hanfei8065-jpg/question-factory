import 'package:flutter/material.dart';

class CameraBestPractices extends StatelessWidget {
  final VoidCallback onClose;

  const CameraBestPractices({Key? key, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '拍摄技巧',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _PracticePair(
                    title: '拍摄距离',
                    goodDescription: '保持25-30厘米的适当距离',
                    badDescription: '距离太近或太远都会影响识别效果',
                    goodImageAsset: 'assets/images/distance_good.png',
                    badImageAsset: 'assets/images/distance_bad.png',
                  ),
                  SizedBox(height: 32),
                  _PracticePair(
                    title: '光线条件',
                    goodDescription: '光线充足均匀，避免阴影',
                    badDescription: '光线不足或过强会影响清晰度',
                    goodImageAsset: 'assets/images/lighting_good.png',
                    badImageAsset: 'assets/images/lighting_bad.png',
                  ),
                  SizedBox(height: 32),
                  _PracticePair(
                    title: '手机角度',
                    goodDescription: '保持水平，与题目平行',
                    badDescription: '倾斜会导致变形，影响识别',
                    goodImageAsset: 'assets/images/angle_good.png',
                    badImageAsset: 'assets/images/angle_bad.png',
                  ),
                  SizedBox(height: 32),
                  _PracticePair(
                    title: '取景范围',
                    goodDescription: '将题目完整放入边框内',
                    badDescription: '部分遮挡或超出边框会影响识别',
                    goodImageAsset: 'assets/images/framing_good.png',
                    badImageAsset: 'assets/images/framing_bad.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticePair extends StatelessWidget {
  final String title;
  final String goodDescription;
  final String badDescription;
  final String goodImageAsset;
  final String badImageAsset;

  const _PracticePair({
    Key? key,
    required this.title,
    required this.goodDescription,
    required this.badDescription,
    required this.goodImageAsset,
    required this.badImageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PracticeExample(
                label: '正确',
                description: goodDescription,
                imageAsset: goodImageAsset,
                isGood: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PracticeExample(
                label: '错误',
                description: badDescription,
                imageAsset: badImageAsset,
                isGood: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PracticeExample extends StatelessWidget {
  final String label;
  final String description;
  final String imageAsset;
  final bool isGood;

  const _PracticeExample({
    Key? key,
    required this.label,
    required this.description,
    required this.imageAsset,
    required this.isGood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: isGood ? Colors.green : Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGood ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
