import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'notification_service.dart';

class WaterQualityScreen extends StatefulWidget {
  const WaterQualityScreen({super.key});

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  final NotificationService _notificationService = NotificationService();
  double tdsLevel = 150.0; // Total Dissolved Solids (PPM)
  double ph = 7.2;
  double turbidity = 2.5; // NTU
  String qualityRating = 'Good';
  String previousQualityRating = 'Good';
  Color ratingColor = Colors.green;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _simulateQualityReading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateQualityReading() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        Random random = Random();
        
        // Simulate slight variations
        tdsLevel = 120 + random.nextDouble() * 100; // 120-220 PPM
        ph = 6.8 + random.nextDouble() * 0.8; // 6.8-7.6
        turbidity = 1.0 + random.nextDouble() * 4.0; // 1-5 NTU
        
        // Determine overall quality
        if (tdsLevel < 300 && ph >= 6.5 && ph <= 8.5 && turbidity < 5) {
          qualityRating = 'Excellent';
          ratingColor = Colors.green;
        } else if (tdsLevel < 500 && ph >= 6.0 && ph <= 9.0 && turbidity < 10) {
          qualityRating = 'Good';
          ratingColor = Colors.lightGreen;
        } else if (tdsLevel < 1000 && turbidity < 25) {
          qualityRating = 'Fair';
          ratingColor = Colors.orange;
        } else {
          qualityRating = 'Poor';
          ratingColor = Colors.red;
        }
        
        // Send notification if quality changed for the worse
        if (qualityRating != previousQualityRating && 
            (qualityRating == 'Poor' || qualityRating == 'Fair')) {
          String issue = '';
          String recommendation = '';
          
          if (qualityRating == 'Poor') {
            issue = 'Water quality has degraded significantly.';
            recommendation = 'Consider using filtered water or check your filtration system.';
          } else if (qualityRating == 'Fair') {
            issue = 'Water quality has decreased.';
            recommendation = 'Monitor closely and consider maintenance.';
          }
          
          _notificationService.sendWaterQualityAlert(
            qualityLevel: qualityRating,
            issue: issue,
            recommendation: recommendation,
          );
        }
        
        previousQualityRating = qualityRating;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('💧 Water Quality Monitor'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Overall Rating Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ratingColor.withOpacity(0.8), ratingColor],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Water Quality',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    qualityRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Safe for drinking & household use',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // TDS Level
            _buildQualityParameter(
              'TDS Level',
              '${tdsLevel.toStringAsFixed(1)} PPM',
              'Total Dissolved Solids',
              Icons.science,
              Colors.blue,
              tdsLevel / 500,
              'Ideal: < 300 PPM',
            ),
            
            const SizedBox(height: 16),
            
            // pH Level
            _buildQualityParameter(
              'pH Level',
              ph.toStringAsFixed(2),
              'Acidity/Alkalinity',
              Icons.water_drop,
              Colors.purple,
              (ph - 6.0) / 3.0,
              'Ideal: 6.5 - 8.5',
            ),
            
            const SizedBox(height: 16),
            
            // Turbidity
            _buildQualityParameter(
              'Turbidity',
              '${turbidity.toStringAsFixed(1)} NTU',
              'Water Clarity',
              Icons.visibility,
              Colors.amber,
              turbidity / 10,
              'Ideal: < 5 NTU',
            ),
            
            const SizedBox(height: 24),
            
            // Recommendations
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      const Text(
                        'Recommendations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendation('✓ Water quality is within safe limits'),
                  _buildRecommendation('✓ Regular filter maintenance recommended'),
                  _buildRecommendation('✓ Next quality check: In 7 days'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityParameter(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
    String idealRange,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            idealRange,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}