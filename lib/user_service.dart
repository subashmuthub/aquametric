import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user data stream
  Stream<DocumentSnapshot> getUserData() {
    return _firestore.collection('users').doc(currentUserId).snapshots();
  }

  // Update water usage and cost
  Future<void> updateWaterUsage(double liters, double cost) async {
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'totalUsage': FieldValue.increment(liters),
      'totalCost': FieldValue.increment(cost),
    });

    // Award points for monitoring (1 point per session)
    await _addPoints(1);
  }

  // Add water usage event
  Future<void> addWaterEvent({
    required String eventType,
    required double flow,
    required double cost,
  }) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('events')
        .add({
      'type': eventType,
      'flow': flow,
      'cost': cost,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Award points based on event type
    if (eventType.contains('LEAK')) {
      await _addPoints(50); // Big reward for detecting leak!
    }
  }

  // Add points
  Future<void> _addPoints(int points) async {
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'points': FieldValue.increment(points),
    });
  }

  // Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'achievements': FieldValue.arrayUnion([achievementId]),
    });
    
    // Send achievement notification
    await _sendAchievementNotification(achievementId);
  }
  
  // Send achievement notification
  Future<void> _sendAchievementNotification(String achievementId) async {
    // Map achievement IDs to user-friendly names and descriptions
    Map<String, Map<String, dynamic>> achievementData = {
      'first_day': {
        'name': 'First Drop',
        'description': 'Started monitoring water usage',
        'points': 10,
      },
      'week_saver': {
        'name': 'Week Saver',
        'description': 'Used less than average for 7 days',
        'points': 100,
      },
      'leak_hunter': {
        'name': 'Leak Hunter',
        'description': 'Detected and fixed a leak',
        'points': 50,
      },
      'water_warrior': {
        'name': 'Water Warrior',
        'description': 'Saved 1000 liters this month',
        'points': 200,
      },
      'champion': {
        'name': 'Aqua Champion',
        'description': 'Top 10% water saver in your area',
        'points': 500,
      },
    };
    
    final achievement = achievementData[achievementId];
    if (achievement != null) {
      await _notificationService.sendAchievementNotification(
        achievementName: achievement['name'],
        description: achievement['description'],
        pointsEarned: achievement['points'],
      );
    }
  }

  // Calculate and award points based on savings
  Future<void> calculateDailySavings(double todayUsage) async {
    if (currentUserId == null) return;

    const double averageDailyUsage = 150.0; // Average person uses 150L/day
    
    if (todayUsage < averageDailyUsage) {
      double savedLiters = averageDailyUsage - todayUsage;
      int bonusPoints = (savedLiters / 10).round(); // 1 point per 10L saved
      
      await _addPoints(bonusPoints);
      
      // Check for achievements
      if (savedLiters > 50) {
        await unlockAchievement('week_saver');
      }
      if (savedLiters > 100) {
        await unlockAchievement('water_warrior');
      }
    }
  }

  // Get recent events
  Stream<QuerySnapshot> getRecentEvents({int limit = 20}) {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('events')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}