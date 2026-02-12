import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show Notification, window;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Notification channels
  static const String _leakChannelId = 'leak_detection';
  static const String _budgetChannelId = 'budget_alerts';
  static const String _achievementChannelId = 'achievements';
  static const String _qualityChannelId = 'water_quality';
  static const String _generalChannelId = 'general';

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize timezone data only on non-web platforms
    if (!kIsWeb) {
      tz.initializeTimeZones();
    }
    
    // Request notification permissions
    await _requestPermissions();
    
    // Initialize local notifications (skip on web)
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
    
    // Get and save FCM token
    await _saveTokenToDatabase();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      // Request browser notification permission
      await _requestBrowserNotificationPermission();
    } else {
      // Request permission for iOS/Android
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );
      print('🔔 Notification permission status: ${settings.authorizationStatus}');
    }
  }

  // Request browser notification permission for web
  Future<void> _requestBrowserNotificationPermission() async {
    if (kIsWeb) {
      try {
        if (html.Notification.permission == 'default') {
          String permission = await html.Notification.requestPermission();
          print('🔔 Browser notification permission: $permission');
        } else {
          print('🔔 Browser notification permission already: ${html.Notification.permission}');
        }
      } catch (e) {
        print('❌ Error requesting browser notification permission: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tapped (app was terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTapped);
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final List<AndroidNotificationChannel> channels = [
      const AndroidNotificationChannel(
        _leakChannelId,
        'Leak Detection',
        description: 'Critical water leak alerts',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('leak_alert'),
      ),
      const AndroidNotificationChannel(
        _budgetChannelId,
        'Budget Alerts',
        description: 'Water budget and spending notifications',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        _achievementChannelId,
        'Achievements',
        description: 'Water conservation achievements and rewards',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        _qualityChannelId,
        'Water Quality',
        description: 'Water quality monitoring alerts',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        _generalChannelId,
        'General',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveTokenToDatabase() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (token != null && userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('🔔 FCM Token saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Received foreground message: ${message.notification?.title}');
    
    // Show local notification for foreground messages
    _showLocalNotification(
      title: message.notification?.title ?? 'Aqua-Metric',
      body: message.notification?.body ?? 'New notification',
      data: message.data,
    );
  }

  // Handle notification tapped
  void _handleNotificationTapped(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Handle navigation based on notification data
    _handleNotificationAction(message.data);
  }

  // Handle local notification tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      Map<String, dynamic> data = jsonDecode(response.payload!);
      _handleNotificationAction(data);
    }
  }

  // Handle notification actions (navigation, etc.)
  void _handleNotificationAction(Map<String, dynamic> data) {
    String? action = data['action'];
    String? screen = data['screen'];
    
    // You can implement navigation logic here
    // For example: Navigator.pushNamed(context, screen);
    print('🔔 Handling notification action: $action, screen: $screen');
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
  }) async {
    if (kIsWeb) {
      // Show browser notification for web
      await _showBrowserNotification(title: title, body: body, data: data);
    } else {
      // Show local notification for mobile
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default',
        importance: Importance.max,
        showWhen: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: data != null ? jsonEncode(data) : null,
      );
    }
  }

  // Show browser notification for web
  Future<void> _showBrowserNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      try {
        print('🔔 Attempting to show browser notification...');
        print('🔔 Current permission: ${html.Notification.permission}');
        
        // Request permission if not granted
        if (html.Notification.permission == 'default') {
          final permission = await html.Notification.requestPermission();
          print('🔔 Permission requested, result: $permission');
        }
        
        if (html.Notification.permission == 'granted') {
          print('🔔 Creating notification: $title - $body');
          
          html.Notification notification = html.Notification(title, 
            body: body,
            icon: 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSIjMDA4OEZGIi8+Cjwvc3ZnPgo=',
            tag: 'aquametric_${DateTime.now().millisecondsSinceEpoch}',
          );
          
          // Add click handler
          notification.onClick.listen((event) {
            print('🔔 Notification clicked!');
            try {
              html.window.location.href = html.window.location.href;
            } catch (e) {
              print('Could not focus window: $e');
            }
          });
          
          // Auto close after 8 seconds
          Future.delayed(const Duration(seconds: 8), () {
            notification.close();
          });
          
          print('🔔 Browser notification created successfully: $title');
        } else {
          print('❌ Browser notification permission not granted: ${html.Notification.permission}');
          print('❌ User needs to manually enable notifications in browser settings');
        }
      } catch (e) {
        print('❌ Error showing browser notification: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
  }

  // 🚨 Send leak detection alert
  Future<void> sendLeakAlert({
    required double flowRate,
    required String location,
    required double estimatedCost,
  }) async {
    await _showLocalNotification(
      title: '🚨 WATER LEAK DETECTED!',
      body: 'High flow detected at $location (${flowRate.toStringAsFixed(1)} L/min). Potential cost: ₹${estimatedCost.toStringAsFixed(2)}/hour',
      channelId: _leakChannelId,
      data: {
        'action': 'leak_detected',
        'screen': '/dashboard',
        'location': location,
        'flowRate': flowRate,
      },
    );
  }

  // 💰 Send budget alert
  Future<void> sendBudgetAlert({
    required double percentageUsed,
    required double currentSpend,
    required double budgetLimit,
  }) async {
    String title;
    String body;
    
    if (percentageUsed >= 100) {
      title = '🚨 BUDGET EXCEEDED!';
      body = 'You\'ve spent ₹${currentSpend.toStringAsFixed(2)} (${percentageUsed.toStringAsFixed(1)}% of budget)';
    } else if (percentageUsed >= 80) {
      title = '⚠️ Budget Warning';
      body = 'You\'ve used ${percentageUsed.toStringAsFixed(1)}% of your monthly budget (₹${currentSpend.toStringAsFixed(2)}/₹${budgetLimit.toStringAsFixed(2)})';
    } else {
      title = '💡 Budget Reminder';
      body = 'Current spend: ₹${currentSpend.toStringAsFixed(2)} (${percentageUsed.toStringAsFixed(1)}% of budget)';
    }

    await _showLocalNotification(
      title: title,
      body: body,
      channelId: _budgetChannelId,
      data: {
        'action': 'budget_alert',
        'screen': '/budget',
        'percentage': percentageUsed,
      },
    );
  }

  // 🏆 Send achievement notification
  Future<void> sendAchievementNotification({
    required String achievementName,
    required String description,
    required int pointsEarned,
  }) async {
    await _showLocalNotification(
      title: '🏆 Achievement Unlocked!',
      body: '$achievementName: $description (+$pointsEarned points)',
      channelId: _achievementChannelId,
      data: {
        'action': 'achievement_unlocked',
        'screen': '/achievements',
        'achievementName': achievementName,
      },
    );
  }

  // 💧 Send water quality alert
  Future<void> sendWaterQualityAlert({
    required String qualityLevel,
    required String issue,
    required String recommendation,
  }) async {
    await _showLocalNotification(
      title: '💧 Water Quality Alert',
      body: 'Water quality: $qualityLevel. $issue',
      channelId: _qualityChannelId,
      data: {
        'action': 'water_quality_alert',
        'screen': '/water-quality',
        'qualityLevel': qualityLevel,
      },
    );
  }

  // 📅 Send daily usage summary
  Future<void> sendDailySummary({
    required double todayUsage,
    required double yesterdayUsage,
    required double todayCost,
    required int pointsEarned,
  }) async {
    double change = todayUsage - yesterdayUsage;
    String changeText = change > 0 
        ? '+${change.toStringAsFixed(1)}L vs yesterday'
        : '${change.toStringAsFixed(1)}L vs yesterday';

    await _showLocalNotification(
      title: '📊 Daily Water Summary',
      body: 'Today: ${todayUsage.toStringAsFixed(1)}L (₹${todayCost.toStringAsFixed(2)}) $changeText. Points earned: $pointsEarned',
      channelId: _generalChannelId,
      data: {
        'action': 'daily_summary',
        'screen': '/dashboard',
      },
    );
  }

  // 🧪 Send simple test notification (for debugging)
  Future<void> sendTestNotification() async {
    print('🧪 Sending test notification...');
    await _showLocalNotification(
      title: '🧪 Test Notification',
      body: 'This is a test notification from Aqua-Metric app!',
      data: {
        'action': 'test',
        'screen': '/dashboard',
      },
    );
  }

  // 💡 Send conservation tip notification
  Future<void> sendConservationTip({
    required String tip,
    required int potentialSavings,
  }) async {
    await _showLocalNotification(
      title: '💡 Water Saving Tip',
      body: '$tip (Save up to $potentialSavings L/year)',
      channelId: _generalChannelId,
      data: {
        'action': 'conservation_tip',
        'screen': '/tips',
      },
    );
  }

  // Schedule daily notifications
  Future<void> scheduleDailyNotifications() async {
    // Skip scheduled notifications on web
    if (kIsWeb) {
      print('🔔 Scheduled notifications not supported on web platform');
      return;
    }
    
    // Schedule daily summary at 8 PM
    await _localNotifications.zonedSchedule(
      1,
      '📊 Daily Water Summary',
      'Check your water usage for today',
      _nextInstanceOfTime(20, 0), // 8:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Helper to get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    if (kIsWeb) {
      // Return dummy value for web
      return tz.TZDateTime.now(tz.local);
    }
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool leakAlerts,
    required bool budgetAlerts,
    required bool achievements,
    required bool qualityAlerts,
    required bool dailySummary,
    required bool tips,
  }) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'notificationPreferences': {
          'leakAlerts': leakAlerts,
          'budgetAlerts': budgetAlerts,
          'achievements': achievements,
          'qualityAlerts': qualityAlerts,
          'dailySummary': dailySummary,
          'tips': tips,
        },
        'preferencesUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message: ${message.notification?.title}');
}