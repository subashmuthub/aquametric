import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';
import 'constants.dart';
import 'tips_screen.dart';
import 'achievements_screen.dart';
import 'user_service.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'water_quality_screen.dart';
import 'analytics_screen.dart';
import 'reports_screen.dart';
import 'budget_screen.dart';
import 'notification_service.dart';
import 'notification_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  String userName = 'User';
  List<double> waterFlowData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  double currentFlow = 0;
  double totalUsageToday = 0;
  double totalCostToday = 0;
  int userPoints = 150;
  String currentActivity = "No Activity";
  List<Map<String, dynamic>> recentEvents = [];
  bool leakDetected = false;
  Timer? _timer;

    @override
  void initState() {
    super.initState();
    _loadUserData();
    _startWaterSimulation();
  }

  // Load user data from Firebase
  void _loadUserData() {
    _userService.getUserData().listen((snapshot) {
      if (!mounted) return; // Check if widget is still mounted
      
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          userName = data['name'] ?? 'User';
          userPoints = data['points'] ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🚰 SMART WATER SIMULATION - This simulates real water meter data
  void _startWaterSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return; // Check if widget is still mounted
      
      setState(() {
        // Randomly choose what happens
        Random random = Random();
        int activity = random.nextInt(100);

              if (activity < 5) {
        // 5% chance - Toilet Flush
        _simulateToiletFlush();
      } else if (activity < 12) {
        // 7% chance - Shower
        _simulateShower();
      } else if (activity < 16) {
        // 4% chance - Multiple Taps Running (NEW!)
        _simulateMultipleTaps();
      } else if (activity < 22) {
        // 6% chance - Smart Tap Detection (NEW!)
        _simulateTapWithContext();
      } else if (activity < 25) {
        // 3% chance - Washing Machine
        _simulateWashingMachine();
      } else if (activity < 28) {
        // 3% chance - Leak!
        _simulateLeak();
      }

        // Update chart data
        waterFlowData.removeAt(0);
        waterFlowData.add(currentFlow);

                // Update total usage
        double usageIncrement = currentFlow / 30; // Convert to liters
        totalUsageToday += usageIncrement;
        totalCostToday = totalUsageToday * WaterCosts.costPerLiter;
        
        // Save to Firebase every 10 data points
        if (waterFlowData.last > 0) {
          _userService.updateWaterUsage(usageIncrement, totalCostToday / 100);
        }
      });
    });
  }

  // 🚽 Toilet Flush Pattern
  void _simulateToiletFlush() {
    currentFlow = 6.0 + Random().nextDouble() * 2; // 6-8 liters/min
    currentActivity = "Toilet Flush Detected";
    _addEvent("🚽 Toilet Flush", currentFlow, Colors.blue);
  }

  // 🚿 Shower Pattern
  void _simulateShower() {
    currentFlow = 8.0 + Random().nextDouble() * 4; // 8-12 liters/min
    currentActivity = "Shower Running";
    _addEvent("🚿 Shower", currentFlow, Colors.green);
  }

  // 🧺 Washing Machine Pattern
  void _simulateWashingMachine() {
    currentFlow = 4.0 + Random().nextDouble() * 3; // 4-7 liters/min
    currentActivity = "Washing Machine";
    _addEvent("🧺 Washing Machine", currentFlow, Colors.orange);
  }

  // 💧 Leak Pattern
  void _simulateLeak() {
    currentFlow = 0.3 + Random().nextDouble() * 0.5; // Small constant flow
    currentActivity = "⚠️ LEAK DETECTED!";
    leakDetected = true;
    _addEvent("⚠️ LEAK DETECTED", currentFlow, Colors.red);
    
    // Send leak notification
    double estimatedHourlyCost = currentFlow * 60 * WaterCosts.costPerLiter;
    _notificationService.sendLeakAlert(
      flowRate: currentFlow,
      location: 'Unknown Location',
      estimatedCost: estimatedHourlyCost,
    );
  }

    // 🚰 Simultaneous Tap Detection (NEW FEATURE!)
  void _simulateMultipleTaps() {
    Random random = Random();
    
    // Kitchen tap (lower flow)
    double kitchenFlow = 5.5 + random.nextDouble() * 1.5; // 5.5-7 L/min
    
    // Bathroom tap (higher flow)
    double bathroomFlow = 7.5 + random.nextDouble() * 1.5; // 7.5-9 L/min
    
    // Determine which is dominant (higher flow = currently active)
    if (bathroomFlow > kitchenFlow) {
      currentFlow = bathroomFlow;
      currentActivity = "🚿 Bathroom Tap - Active (${bathroomFlow.toStringAsFixed(1)} L/min)\n🍽️ Kitchen Tap - Background (${kitchenFlow.toStringAsFixed(1)} L/min)";
      _addEvent("🚿 Bathroom Tap (Dominant)", bathroomFlow, Colors.blue);
    } else {
      currentFlow = kitchenFlow;
      currentActivity = "🍽️ Kitchen Tap - Active (${kitchenFlow.toStringAsFixed(1)} L/min)\n🚿 Bathroom Tap - Background (${bathroomFlow.toStringAsFixed(1)} L/min)";
      _addEvent("🍽️ Kitchen Tap (Dominant)", kitchenFlow, Colors.green);
    }
  }

  // 🔍 Smart Tap Detection with Time Context
  void _simulateTapWithContext() {
    Random random = Random();
    double flow = 5.0 + random.nextDouble() * 4.0; // 5-9 L/min
    int currentHour = DateTime.now().hour;
    
    String detectedLocation = SmartDetection.detectSpecificTap(flow, currentHour);
    currentActivity = detectedLocation;
    currentFlow = flow;
    
    Color eventColor;
    if (detectedLocation.contains('Bathroom')) {
      eventColor = Colors.blue;
    } else if (detectedLocation.contains('Kitchen')) {
      eventColor = Colors.green;
    } else {
      eventColor = Colors.grey;
    }
    
    _addEvent(detectedLocation, flow, eventColor);
  }

    // Add event to history
  void _addEvent(String name, double flow, Color color) {
    recentEvents.insert(0, {
      'name': name,
      'flow': flow,
      'time': DateTime.now(),
      'color': color,
    });
    if (recentEvents.length > 10) {
      recentEvents.removeLast();
    }

    // Save to Firebase
    double cost = flow * WaterCosts.costPerLiter / 60; // Per second cost
    _userService.addWaterEvent(
      eventType: name,
      flow: flow,
      cost: cost,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
                  appBar: AppBar(
        title: Text('Welcome, $userName!'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            tooltip: 'Water Saving Tips',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Achievements',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementsScreen()),
              );
            },
          ),
                    PopupMenuButton(
            icon: const Icon(Icons.menu),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.water_drop, color: Colors.teal),
                  title: const Text('Water Quality'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WaterQualityScreen()),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.deepPurple),
                  title: const Text('Advanced Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.file_download, color: Colors.indigo),
                  title: const Text('Reports & Export'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportsScreen()),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.teal),
                  title: const Text('Budget Manager'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BudgetScreen()),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.indigo),
                  title: const Text('Notification Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!mounted) return; // Check if widget is still mounted
          
          setState(() {
            waterFlowData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            totalUsageToday = 0;
            recentEvents.clear();
            leakDetected = false;
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚨 LEAK ALERT
              if (leakDetected)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ LEAK DETECTED!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Continuous small flow detected. Check your pipes!',
                              style: TextStyle(color: Colors.red[900]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 📊 CURRENT FLOW
              _buildStatCard(
                'Current Water Flow',
                '${currentFlow.toStringAsFixed(1)} L/min',
                Icons.water_drop,
                Colors.blue,
              ),
              const SizedBox(height: 16),

                            // 💧 TOTAL USAGE TODAY
              _buildStatCard(
                'Total Usage Today',
                '${totalUsageToday.toStringAsFixed(1)} Liters',
                Icons.water,
                Colors.green,
              ),
              const SizedBox(height: 16),

              // 💰 COST TODAY
              _buildStatCard(
                'Cost Today',
                '₹${totalCostToday.toStringAsFixed(2)}',
                Icons.currency_rupee,
                Colors.purple,
              ),
              const SizedBox(height: 16),

              // 🏆 POINTS
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                  );
                },
                child: _buildStatCard(
                  'Your Points (Tap to view achievements)',
                  '$userPoints Points',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              const SizedBox(height: 16),

              // 🔍 CURRENT ACTIVITY
              _buildStatCard(
                'Current Activity',
                currentActivity,
                Icons.analytics,
                currentActivity.contains('LEAK') ? Colors.red : Colors.orange,
              ),
              const SizedBox(height: 24),

              // 📈 LIVE FLOW CHART
              const Text(
                '📈 Live Water Flow',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}',
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: waterFlowData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 📜 RECENT ACTIVITY
              const Text(
                '📜 Recent Activity (AI Detection)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...recentEvents.map((event) => _buildEventCard(event)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerTestNotifications,
        backgroundColor: Colors.orange,
        tooltip: 'Test Notifications',
        child: const Icon(Icons.science, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event['name'].split(' ')[0],
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${event['flow'].toStringAsFixed(1)} L/min • ${_formatTime(event['time'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // TESTING METHODS - Remove in production
  void _triggerTestNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🧪 Test Notifications'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendLeakAlert(
                      flowRate: 15.5,
                      location: 'Kitchen Tap',
                      estimatedCost: 25.75,
                    );
                  },
                  child: const Text('🚨 Test Leak Alert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendBudgetAlert(
                      percentageUsed: 85.0,
                      currentSpend: 425.50,
                      budgetLimit: 500.0,
                    );
                  },
                  child: const Text('💰 Test Budget Alert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendAchievementNotification(
                      achievementName: 'Water Warrior',
                      description: 'Saved 1000 liters this month',
                      pointsEarned: 200,
                    );
                  },
                  child: const Text('🏆 Test Achievement'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendWaterQualityAlert(
                      qualityLevel: 'Poor',
                      issue: 'High turbidity detected',
                      recommendation: 'Check filter system',
                    );
                  },
                  child: const Text('💧 Test Quality Alert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendDailySummary(
                      todayUsage: 125.5,
                      yesterdayUsage: 140.0,
                      todayCost: 6.28,
                      pointsEarned: 15,
                    );
                  },
                  child: const Text('📊 Test Daily Summary'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notificationService.sendConservationTip(
                      tip: 'Turn off tap while brushing teeth',
                      potentialSavings: 4380,
                    );
                  },
                  child: const Text('💡 Test Conservation Tip'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}