enum CameraState {
  /// 关闭（黑屏）状态
  closed,

  /// 初始化中
  initializing,

  /// 准备拍照
  preview,

  /// 确认照片
  confirm,

  /// 处理图片中
  processing,
}
