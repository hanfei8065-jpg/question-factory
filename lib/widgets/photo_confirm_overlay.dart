import 'package:flutter/material.dart';

class PhotoConfirmOverlay extends StatefulWidget {
  final VoidCallback onRetake;
  final VoidCallback onConfirm;
  final VoidCallback onAdjust;
  final Image capturedImage;
  final Animation<double> frameAnimation;

  const PhotoConfirmOverlay({
    super.key,
    required this.onRetake,
    required this.onConfirm,
    required this.onAdjust,
    required this.capturedImage,
    required this.frameAnimation,
  });

  @override
  State<PhotoConfirmOverlay> createState() => _PhotoConfirmOverlayState();
}

class _PhotoConfirmOverlayState extends State<PhotoConfirmOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 全屏显示拍摄的图片
        Positioned.fill(child: widget.capturedImage),

        // 动画边框
        AnimatedBuilder(
          animation: widget.frameAnimation,
          builder: (context, child) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(32 * (1 - widget.frameAnimation.value)),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00A86B), width: 3),
                ),
              ),
            );
          },
        ),

        // 底部控制栏
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: '重拍',
                    onTap: widget.onRetake,
                  ),
                  _buildConfirmButton(onTap: widget.onConfirm),
                  _buildActionButton(
                    icon: Icons.crop_rotate,
                    label: '调整',
                    onTap: widget.onAdjust,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1F2937), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A86B), Color(0xFF00C897)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00A86B).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '确认',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
