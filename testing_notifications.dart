// TEMPORARY TESTING CODE - Add this to dashboard_screen.dart for testing
import 'lib/notification_service.dart';

// Add this method to _DashboardScreenState class:
void _triggerTestNotifications() {
  final NotificationService _notificationService = NotificationService();
  
  // Test leak notification
  _notificationService.sendLeakAlert(
    flowRate: 15.5,
    location: 'Kitchen Tap',
    estimatedCost: 25.75,
  );
  
  // Test budget notification
  _notificationService.sendBudgetAlert(
    percentageUsed: 85.0,
    currentSpend: 425.50,
    budgetLimit: 500.0,
  );
  
  // Test achievement notification
  _notificationService.sendAchievementNotification(
    achievementName: 'Water Warrior',
    description: 'Saved 1000 liters this month',
    pointsEarned: 200,
  );
  
  // Test water quality alert
  _notificationService.sendWaterQualityAlert(
    qualityLevel: 'Poor',
    issue: 'High turbidity detected',
    recommendation: 'Check your filter system immediately',
  );
  
  // Test daily summary
  _notificationService.sendDailySummary(
    todayUsage: 125.5,
    yesterdayUsage: 140.0,
    todayCost: 6.28,
    pointsEarned: 15,
  );
  
  // Test conservation tip
  _notificationService.sendConservationTip(
    tip: 'Turn off tap while brushing teeth',
    potentialSavings: 4380,
  );
}