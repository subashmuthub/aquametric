import 'package:flutter/material.dart';
import 'notification_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final NotificationService _notificationService = NotificationService();
  double monthlyBudget = 500.0;
  double currentSpend = 245.50;
  bool alertsEnabled = true;
  double alertThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _checkBudgetStatus();
  }
  
  // Check budget status and send notification if needed
  void _checkBudgetStatus() {
    double percentageUsed = (currentSpend / monthlyBudget) * 100;
    
    if (alertsEnabled) {
      if (percentageUsed >= 100) {
        _notificationService.sendBudgetAlert(
          percentageUsed: percentageUsed,
          currentSpend: currentSpend,
          budgetLimit: monthlyBudget,
        );
      } else if (percentageUsed >= alertThreshold) {
        _notificationService.sendBudgetAlert(
          percentageUsed: percentageUsed,
          currentSpend: currentSpend,
          budgetLimit: monthlyBudget,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentageUsed = (currentSpend / monthlyBudget) * 100;
    bool isOverBudget = percentageUsed > 100;
    bool isNearLimit = percentageUsed > alertThreshold;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('💳 Budget Manager'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Overview Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOverBudget 
                    ? [Colors.red.shade400, Colors.red.shade700]
                    : isNearLimit
                    ? [Colors.orange.shade400, Colors.orange.shade700]
                    : [Colors.teal.shade400, Colors.teal.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Water Budget',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${monthlyBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (percentageUsed / 100).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ₹${currentSpend.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${percentageUsed.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    isOverBudget
                      ? '⚠️ Over budget by ₹${(currentSpend - monthlyBudget).toStringAsFixed(2)}'
                      : 'Remaining: ₹${(monthlyBudget - currentSpend).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Set Budget
            const Text(
              'Budget Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Budget Limit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: monthlyBudget,
                          min: 100,
                          max: 2000,
                          divisions: 38,
                          label: '₹${monthlyBudget.toStringAsFixed(0)}',
                          activeColor: Colors.teal,
                          onChanged: (value) {
                            setState(() {
                              monthlyBudget = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '₹${monthlyBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Alert Settings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Alerts',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Get notified when nearing limit',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: alertsEnabled,
                        activeThumbColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            alertsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  if (alertsEnabled) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Alert When Budget Reaches',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: alertThreshold,
                            min: 50,
                            max: 95,
                            divisions: 9,
                            label: '${alertThreshold.toStringAsFixed(0)}%',
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                alertThreshold = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          '${alertThreshold.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Spending History
            const Text(
              'Spending History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildHistoryItem('January 2025', 245.50, 500, false),
            const SizedBox(height: 12),
            _buildHistoryItem('December 2024', 520.30, 500, true),
            const SizedBox(height: 12),
            _buildHistoryItem('November 2024', 395.00, 500, false),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String month, double spent, double budget, bool overBudget) {
    double percentage = (spent / budget) * 100;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overBudget ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$spent / ₹$budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: overBudget ? Colors.red : Colors.green,
                ),
              ),
              if (overBudget)
                const Text(
                  'Over budget',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}