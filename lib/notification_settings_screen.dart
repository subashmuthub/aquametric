import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  // Notification preferences
  bool leakAlerts = true;
  bool budgetAlerts = true;
  bool achievements = true;
  bool qualityAlerts = true;
  bool dailySummary = true;
  bool tips = true;
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  // Load current notification preferences
  Future<void> _loadNotificationPreferences() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Map<String, dynamic>? prefs = data['notificationPreferences'];
          
          if (prefs != null) {
            setState(() {
              leakAlerts = prefs['leakAlerts'] ?? true;
              budgetAlerts = prefs['budgetAlerts'] ?? true;
              achievements = prefs['achievements'] ?? true;
              qualityAlerts = prefs['qualityAlerts'] ?? true;
              dailySummary = prefs['dailySummary'] ?? true;
              tips = prefs['tips'] ?? true;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading notification preferences: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save notification preferences
  Future<void> _savePreferences() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _notificationService.updateNotificationPreferences(
        leakAlerts: leakAlerts,
        budgetAlerts: budgetAlerts,
        achievements: achievements,
        qualityAlerts: qualityAlerts,
        dailySummary: dailySummary,
        tips: tips,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Test notification
  Future<void> _sendTestNotification() async {
    print('🧪 Test button pressed');
    await _notificationService.sendTestNotification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check the browser console for debug info.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🔔 Notification Settings'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
            onPressed: isLoading ? null : _savePreferences,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_active, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Notification Preferences',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Customize which notifications you want to receive',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sendTestNotification,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Send Test Notification'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Critical Alerts
                  _buildSectionTitle('🚨 Critical Alerts'),
                  _buildNotificationTile(
                    title: 'Leak Detection',
                    subtitle: 'Immediate alerts when water leaks are detected',
                    icon: Icons.water_damage,
                    color: Colors.red,
                    value: leakAlerts,
                    onChanged: (value) => setState(() => leakAlerts = value),
                  ),
                  
                  _buildNotificationTile(
                    title: 'Water Quality Alerts',
                    subtitle: 'Notifications about water quality issues',
                    icon: Icons.water_drop,
                    color: Colors.teal,
                    value: qualityAlerts,
                    onChanged: (value) => setState(() => qualityAlerts = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Budget & Usage
                  _buildSectionTitle('💰 Budget & Usage'),
                  _buildNotificationTile(
                    title: 'Budget Alerts',
                    subtitle: 'Warnings when approaching or exceeding budget',
                    icon: Icons.account_balance_wallet,
                    color: Colors.orange,
                    value: budgetAlerts,
                    onChanged: (value) => setState(() => budgetAlerts = value),
                  ),
                  
                  _buildNotificationTile(
                    title: 'Daily Summary',
                    subtitle: 'Daily water usage and cost summaries',
                    icon: Icons.today,
                    color: Colors.blue,
                    value: dailySummary,
                    onChanged: (value) => setState(() => dailySummary = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Engagement
                  _buildSectionTitle('🎯 Engagement'),
                  _buildNotificationTile(
                    title: 'Achievements',
                    subtitle: 'Celebrate your water conservation milestones',
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                    value: achievements,
                    onChanged: (value) => setState(() => achievements = value),
                  ),
                  
                  _buildNotificationTile(
                    title: 'Water Saving Tips',
                    subtitle: 'Helpful tips to conserve water and save money',
                    icon: Icons.lightbulb,
                    color: Colors.green,
                    value: tips,
                    onChanged: (value) => setState(() => tips = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _savePreferences,
                      icon: isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(isLoading ? 'Saving...' : 'Save Preferences'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Notification permissions can be managed in your device settings. Critical leak alerts will always be sent regardless of these preferences.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}