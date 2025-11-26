import 'package:flutter/material.dart';
import '../theme/theme.dart' as app_theme;

class CameraControls extends StatelessWidget {
  final bool isProcessing;
  final bool isInBurstMode;
  final bool isFlashOn;
  final bool showGrid;
  final int selectedImagesCount;
  final int burstImagesCount;
  final int maxBurstCount;
  final VoidCallback onTakePhoto;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onToggleFlash;
  final VoidCallback onToggleGrid;
  final VoidCallback onOpenGallery;
  final VoidCallback onShowGuide;

  const CameraControls({
    super.key,
    required this.isProcessing,
    required this.isInBurstMode,
    required this.isFlashOn,
    required this.showGrid,
    required this.selectedImagesCount,
    required this.burstImagesCount,
    required this.maxBurstCount,
    required this.onTakePhoto,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onToggleFlash,
    required this.onToggleGrid,
    required this.onOpenGallery,
    required this.onShowGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: app_theme.AppTheme.spacingL,
        vertical: app_theme.AppTheme.spacingXL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.6)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.photo_library,
            onTap: onOpenGallery,
            isEnabled: !isProcessing,
          ),
          _buildShutterButton(),
          _buildActionButton(
            icon: Icons.help_outline,
            onTap: onShowGuide,
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(
          app_theme.AppTheme.borderRadiusLarge,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(
              app_theme.AppTheme.borderRadiusLarge,
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.white38,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: isProcessing ? null : onTakePhoto,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isInBurstMode ? app_theme.AppTheme.accent : Colors.white,
            width: 4,
          ),
          boxShadow: isProcessing || isInBurstMode
              ? app_theme.AppTheme.shadowLarge
              : app_theme.AppTheme.shadowMedium,
        ),
        child: AnimatedContainer(
          duration: app_theme.AppTheme.animationNormal,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProcessing || isInBurstMode
                ? app_theme.AppTheme.primary.withOpacity(0.8)
                : Colors.white.withOpacity(0.2),
          ),
          child: isProcessing || isInBurstMode
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                      backgroundColor: Colors.white24,
                    ),
                    if (isInBurstMode)
                      Text(
                        '$burstImagesCount/$maxBurstCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera, color: Colors.white, size: 32),
                    if (selectedImagesCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: app_theme.AppTheme.primary,
                          borderRadius: BorderRadius.circular(
                            app_theme.AppTheme.borderRadiusSmall,
                          ),
                        ),
                        child: Text(
                          '$selectedImagesCount/3',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
