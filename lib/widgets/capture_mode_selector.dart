import 'package:flutter/material.dart';
import '../models/recognition_mode.dart';
import '../theme/theme.dart';

class CaptureModeSelector extends StatefulWidget {
  final RecognitionMode currentMode;
  final ValueChanged<RecognitionMode> onModeChanged;

  const CaptureModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<CaptureModeSelector> createState() => _CaptureModeSelectorState();
}

class _CaptureModeSelectorState extends State<CaptureModeSelector> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<ModeItem> _modes = [
    ModeItem(mode: RecognitionMode.single, label: '单张'),
    ModeItem(mode: RecognitionMode.batch, label: '批量'),
    ModeItem(mode: RecognitionMode.exam, label: '试卷'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _modes.indexWhere((m) => m.mode == widget.currentMode);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.3, // 每个标签占屏幕30%宽度
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onModeSelected(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: AppTheme.durationNormal,
        curve: Curves.easeInOut,
      );
    }
    
    widget.onModeChanged(_modes[index].mode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_modes.length, (index) {
          final mode = _modes[index];
          final isSelected = index == _currentIndex;
          
          return GestureDetector(
            onTap: () => _onModeSelected(index),
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.brandPrimary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Text(
                mode.label,
                style: TextStyle(
                  fontSize: isSelected ? AppTheme.fontSizeL : AppTheme.fontSizeM,
                  fontWeight: isSelected
                      ? AppTheme.fontWeightBold
                      : AppTheme.fontWeightRegular,
                  color: isSelected ? AppTheme.brandPrimary : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ModeItem {
  final RecognitionMode mode;
  final String label;

  ModeItem({required this.mode, required this.label});
}
