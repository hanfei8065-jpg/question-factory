enum CameraMode { single, batch }

class CameraConfig {
  final double exposureOffset;
  final bool autoExposure;
  final double zoomLevel;
  final bool autoFocus;
  final int previewWidth;
  final int previewHeight;

  CameraConfig({
    this.exposureOffset = 0.0,
    this.autoExposure = true,
    this.zoomLevel = 1.0,
    this.autoFocus = true,
    this.previewWidth = 1280,
    this.previewHeight = 720,
  });

  CameraConfig copyWith({
    double? exposureOffset,
    bool? autoExposure,
    double? zoomLevel,
    bool? autoFocus,
    int? previewWidth,
    int? previewHeight,
  }) {
    return CameraConfig(
      exposureOffset: exposureOffset ?? this.exposureOffset,
      autoExposure: autoExposure ?? this.autoExposure,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      autoFocus: autoFocus ?? this.autoFocus,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
    );
  }
}
