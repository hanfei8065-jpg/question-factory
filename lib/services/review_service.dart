import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/review_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';

class ReviewService extends ChangeNotifier {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal() {
    tz.initializeTimeZones();
  }

  final String _reviewItemsKey = 'review_items';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  List<ReviewItem> _reviewItems = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化通知插件
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);

    // 加载保存的复习项
    await _loadReviewItems();

    // 检查并设置复习提醒
    _scheduleReviewNotifications();

    _isInitialized = true;
  }

  Future<void> _loadReviewItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_reviewItemsKey);
    if (itemsJson != null) {
      final List<dynamic> items = jsonDecode(itemsJson);
      _reviewItems = items.map((item) => ReviewItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReviewItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsJson = jsonEncode(
      _reviewItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_reviewItemsKey, itemsJson);
  }

  Future<void> addReviewItem(ReviewItem item) async {
    _reviewItems.add(item);
    await _saveReviewItems();
    await _scheduleReviewNotification(item);
    notifyListeners();
  }

  Future<void> updateReviewItem(ReviewItem item) async {
    final index = _reviewItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _reviewItems[index] = item;
      await _saveReviewItems();
      await _scheduleReviewNotification(item);
      notifyListeners();
    }
  }

  Future<void> removeReviewItem(String id) async {
    _reviewItems.removeWhere((item) => item.id == id);
    await _saveReviewItems();
    await _cancelReviewNotification(id);
    notifyListeners();
  }

  List<ReviewItem> getDueReviewItems() {
    final now = DateTime.now();
    return _reviewItems
        .where((item) => item.nextReviewDate.isBefore(now))
        .toList();
  }

  List<ReviewItem> getUpcomingReviewItems() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _reviewItems
        .where(
          (item) =>
              item.nextReviewDate.isAfter(now) &&
              item.nextReviewDate.isBefore(nextWeek),
        )
        .toList();
  }

  Future<void> _scheduleReviewNotifications() async {
    for (var item in _reviewItems) {
      await _scheduleReviewNotification(item);
    }
  }

  Future<void> _scheduleReviewNotification(ReviewItem item) async {
    final androidDetails = AndroidNotificationDetails(
      'review_reminder',
      '复习提醒',
      channelDescription: '提醒你复习已收藏的题目',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      item.id.hashCode,
      '复习提醒',
      '有题目需要复习了,点击查看详情',
      tz.TZDateTime.from(item.nextReviewDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _cancelReviewNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> completeReview(String id, double masteryLevel) async {
    final index = _reviewItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _reviewItems[index];
      final updatedItem = item.copyWith(
        reviewCount: item.reviewCount + 1,
        masteryLevel: masteryLevel,
        nextReviewDate: ReviewItem.calculateNextReviewDate(
          item.reviewCount + 1,
        ),
      );
      await updateReviewItem(updatedItem);
    }
  }

  List<ReviewItem> getItemsByTag(String tag) {
    return _reviewItems.where((item) => item.tags.contains(tag)).toList();
  }

  double getAverageMasteryLevel() {
    if (_reviewItems.isEmpty) return 0.0;
    final sum = _reviewItems.fold<double>(
      0.0,
      (sum, item) => sum + item.masteryLevel,
    );
    return sum / _reviewItems.length;
  }
}
