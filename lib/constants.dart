import 'package:flutter/material.dart';

// 💰 Water Cost Configuration
class WaterCosts {
  static const double costPerLiter = 0.05; // ₹0.05 per liter (adjust for your region)
  static const double avgDailyUsage = 150.0; // Average person uses 150L/day
  static const double monthlyTarget = 4000.0; // Monthly target in liters
}

// 🏆 Achievement System
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredPoints;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredPoints,
  });
}

// 🎯 Predefined Achievements
class Achievements {
  static List<Achievement> all = [
    Achievement(
      id: 'first_day',
      name: 'First Drop',
      description: 'Started monitoring water usage',
      icon: Icons.water_drop,
      color: Colors.blue,
      requiredPoints: 0,
    ),
    Achievement(
      id: 'week_saver',
      name: 'Week Saver',
      description: 'Used less than average for 7 days',
      icon: Icons.eco,
      color: Colors.green,
      requiredPoints: 100,
    ),
    Achievement(
      id: 'leak_hunter',
      name: 'Leak Hunter',
      description: 'Detected and fixed a leak',
      icon: Icons.search,
      color: Colors.orange,
      requiredPoints: 50,
    ),
    Achievement(
      id: 'water_warrior',
      name: 'Water Warrior',
      description: 'Saved 1000 liters this month',
      icon: Icons.shield,
      color: Colors.purple,
      requiredPoints: 200,
    ),
    Achievement(
      id: 'champion',
      name: 'Aqua Champion',
      description: 'Top 10% water saver in your area',
      icon: Icons.emoji_events,
      color: Colors.amber,
      requiredPoints: 500,
    ),
  ];
}

// 💡 Water Saving Tips
class WaterTip {
  final String title;
  final String description;
  final IconData icon;
  final int litersPerYear;
  final Color color;

  WaterTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.litersPerYear,
    required this.color,
  });
}

class WaterTips {
  static List<WaterTip> all = [
    WaterTip(
      title: 'Fix Leaky Faucets',
      description: 'A dripping tap can waste up to 15 liters per day. Fix leaks immediately to save water and money.',
      icon: Icons.plumbing,
      litersPerYear: 5475,
      color: Colors.red,
    ),
    WaterTip(
      title: 'Shorter Showers',
      description: 'Reduce shower time by 2 minutes to save up to 10 liters per shower.',
      icon: Icons.shower,
      litersPerYear: 3650,
      color: Colors.blue,
    ),
    WaterTip(
      title: 'Turn Off Taps',
      description: 'Turn off the tap while brushing teeth or soaping hands. This can save 6 liters per minute.',
      icon: Icons.water_drop_outlined,
      litersPerYear: 4380,
      color: Colors.cyan,
    ),
    WaterTip(
      title: 'Full Load Washing',
      description: 'Only run washing machines and dishwashers with full loads to maximize efficiency.',
      icon: Icons.local_laundry_service,
      litersPerYear: 3000,
      color: Colors.purple,
    ),
    WaterTip(
      title: 'Collect Cold Water',
      description: 'Collect cold water while waiting for hot water and use it for plants or cleaning.',
      icon: Icons.water,
      litersPerYear: 1825,
      color: Colors.green,
    ),
    WaterTip(
      title: 'Install Aerators',
      description: 'Install faucet aerators to reduce flow while maintaining pressure. Can save 50% water.',
      icon: Icons.settings,
      litersPerYear: 5000,
      color: Colors.orange,
    ),
    WaterTip(
      title: 'Reuse Water',
      description: 'Reuse water from washing vegetables or RO waste water for gardening.',
      icon: Icons.recycling,
      litersPerYear: 2500,
      color: Colors.teal,
    ),
    WaterTip(
      title: 'Check Toilet Leaks',
      description: 'A leaking toilet can waste up to 200 liters per day! Use food coloring to test for leaks.',
      icon: Icons.warning,
      litersPerYear: 73000,
      color: Colors.deepOrange,
    ),
  ];
}

// 🏠 Location-Based Appliance Detection
class ApplianceLocation {
  final String id;
  final String name;
  final String room;
  final IconData icon;
  final double typicalFlow; // L/min

  ApplianceLocation({
    required this.id,
    required this.name,
    required this.room,
    required this.icon,
    required this.typicalFlow,
  });
}

class KnownAppliances {
  static List<ApplianceLocation> all = [
    // Kitchen
    ApplianceLocation(
      id: 'kitchen_tap',
      name: 'Kitchen Tap',
      room: 'Kitchen',
      icon: Icons.kitchen,
      typicalFlow: 6.0,
    ),
    ApplianceLocation(
      id: 'kitchen_dishwasher',
      name: 'Dishwasher',
      room: 'Kitchen',
      icon: Icons.clean_hands,
      typicalFlow: 4.5,
    ),
    
    // Bathroom 1
    ApplianceLocation(
      id: 'bathroom1_tap',
      name: 'Bathroom 1 Tap',
      room: 'Bathroom 1',
      icon: Icons.water_drop,
      typicalFlow: 8.0, // Higher flow than kitchen
    ),
    ApplianceLocation(
      id: 'bathroom1_shower',
      name: 'Bathroom 1 Shower',
      room: 'Bathroom 1',
      icon: Icons.shower,
      typicalFlow: 10.0,
    ),
    ApplianceLocation(
      id: 'bathroom1_toilet',
      name: 'Bathroom 1 Toilet',
      room: 'Bathroom 1',
      icon: Icons.wc,
      typicalFlow: 7.0,
    ),
    
    // Bathroom 2
    ApplianceLocation(
      id: 'bathroom2_tap',
      name: 'Bathroom 2 Tap',
      room: 'Bathroom 2',
      icon: Icons.water_drop,
      typicalFlow: 7.5,
    ),
    ApplianceLocation(
      id: 'bathroom2_shower',
      name: 'Bathroom 2 Shower',
      room: 'Bathroom 2',
      icon: Icons.shower,
      typicalFlow: 9.5,
    ),
    
    // Utility
    ApplianceLocation(
      id: 'utility_washing_machine',
      name: 'Washing Machine',
      room: 'Utility Room',
      icon: Icons.local_laundry_service,
      typicalFlow: 5.0,
    ),
    
    // Garden
    ApplianceLocation(
      id: 'garden_hose',
      name: 'Garden Hose',
      room: 'Garden',
      icon: Icons.grass,
      typicalFlow: 12.0,
    ),
  ];
}

// Smart detection logic
class SmartDetection {
  // Detect which specific tap based on flow rate and context
  static String detectSpecificTap(double flowRate, int hourOfDay) {
    // Morning hours (6-10 AM) - likely bathroom
    if (hourOfDay >= 6 && hourOfDay <= 10) {
      if (flowRate >= 7.5 && flowRate <= 9.0) {
        return 'Bathroom Tap (Morning routine)';
      }
    }
    
    // Meal times (12-2 PM, 7-9 PM) - likely kitchen
    if ((hourOfDay >= 12 && hourOfDay <= 14) || (hourOfDay >= 19 && hourOfDay <= 21)) {
      if (flowRate >= 5.0 && flowRate <= 7.0) {
        return 'Kitchen Tap (Meal prep)';
      }
    }
    
    // Night hours (10 PM - 12 AM) - likely bathroom
    if (hourOfDay >= 22 || hourOfDay <= 1) {
      if (flowRate >= 6.0 && flowRate <= 8.0) {
        return 'Bathroom Tap (Night routine)';
      }
    }
    
    // Default - compare flow rates
    if (flowRate >= 7.5) {
      return 'Bathroom Tap (Higher flow detected)';
    } else if (flowRate >= 5.0 && flowRate <= 7.0) {
      return 'Kitchen Tap (Lower flow detected)';
    }
    
    return 'Tap (Location uncertain)';
  }
}