import 'package:flutter/material.dart';
import '../theme/theme.dart' as app_theme;
import '../models/recognition_mode.dart';

class CameraTopBar extends StatelessWidget {
  final bool isFlashOn;
  final bool showGrid;
  final Function(bool) onFlashChanged;
  final Function(bool) onGridChanged;
  final RecognitionMode mode;
  final Function(RecognitionMode) onModeChanged;

  const CameraTopBar({
    super.key,
    required this.isFlashOn,
    required this.showGrid,
    required this.onFlashChanged,
    required this.onGridChanged,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        app_theme.AppTheme.spacingM,
        MediaQuery.of(context).padding.top + app_theme.AppTheme.spacingM,
        app_theme.AppTheme.spacingM,
        app_theme.AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Row(
            children: [
              _buildIconButton(
                icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                onPressed: () => onFlashChanged(!isFlashOn),
              ),
              SizedBox(width: app_theme.AppTheme.spacingS),
              _buildIconButton(
                icon: showGrid ? Icons.grid_on : Icons.grid_off,
                onPressed: () => onGridChanged(!showGrid),
              ),
            ],
          ),
          _buildModeSelector(),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(
          app_theme.AppTheme.borderRadiusLarge,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        padding: EdgeInsets.all(app_theme.AppTheme.spacingS),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(app_theme.AppTheme.spacingXS),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(
          app_theme.AppTheme.borderRadiusLarge,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            title: '单张',
            isSelected: mode == RecognitionMode.single,
            onTap: () => onModeChanged(RecognitionMode.single),
          ),
          _buildModeButton(
            title: '批量',
            isSelected: mode == RecognitionMode.batch,
            onTap: () => onModeChanged(RecognitionMode.batch),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: app_theme.AppTheme.spacingM,
          vertical: app_theme.AppTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? app_theme.AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(app_theme.AppTheme.borderRadius),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
