import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelService {
  
  // Generate Monthly Report Excel
  static Future<String?> generateMonthlyReport() async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        // Try manageExternalStorage for Android 11+
        if (Platform.isAndroid) {
          await Permission.manageExternalStorage.request();
        }
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      
      // Remove default sheet
      excel.delete('Sheet1');
      
      // Create sheets
      _createSummarySheet(excel);
      _createDailyUsageSheet(excel);
      _createApplianceBreakdownSheet(excel);
      _createLeakHistorySheet(excel);
      _createCostAnalysisSheet(excel);
      
      // Save to file
      String? filePath = await _saveExcelFile(excel, 'Aqua_Metric_Report');
      
      return filePath;
      
    } catch (e) {
      print('Error generating Excel: $e');
      return null;
    }
  }

  // Summary Sheet
  static void _createSummarySheet(Excel excel) {
    var sheet = excel['Summary'];
    
    // Title
    var cell1 = sheet.cell(CellIndex.indexByString('A1'));
    cell1.value = TextCellValue('Aqua-Metric Water Usage Report');
    cell1.cellStyle = CellStyle(bold: true, fontSize: 16);
    
    var cell2 = sheet.cell(CellIndex.indexByString('A2'));
    cell2.value = TextCellValue('Generated: ${DateTime.now().toString().split('.')[0]}');
    cell2.cellStyle = CellStyle(fontSize: 12);
    
    // Summary data (row 4 onwards)
    _setCell(sheet, 'A4', 'Total Usage This Month', bold: true);
    _setCell(sheet, 'B4', '3,245 Liters');
    
    _setCell(sheet, 'A5', 'Total Cost', bold: true);
    _setCell(sheet, 'B5', '₹162.25');
    
    _setCell(sheet, 'A6', 'Average Daily Usage', bold: true);
    _setCell(sheet, 'B6', '108 Liters');
    
    _setCell(sheet, 'A7', 'Leaks Detected', bold: true);
    _setCell(sheet, 'B7', '2');
    
    _setCell(sheet, 'A8', 'Water Saved vs Average', bold: true);
    _setCell(sheet, 'B8', '850 Liters (25%)');
    
    _setCell(sheet, 'A9', 'Money Saved', bold: true);
    _setCell(sheet, 'B9', '₹42.50');
  }

  // Daily Usage Sheet
  static void _createDailyUsageSheet(Excel excel) {
    var sheet = excel['Daily Usage'];
    
    // Headers
    _setCell(sheet, 'A1', 'Date', bold: true);
    _setCell(sheet, 'B1', 'Usage (Liters)', bold: true);
    _setCell(sheet, 'C1', 'Cost (₹)', bold: true);
    _setCell(sheet, 'D1', 'Status', bold: true);
    
    // Sample data
    List<Map<String, dynamic>> dailyData = [
      {'date': '2025-01-01', 'usage': 125, 'cost': 6.25, 'status': 'Good'},
      {'date': '2025-01-02', 'usage': 98, 'cost': 4.90, 'status': 'Excellent'},
      {'date': '2025-01-03', 'usage': 142, 'cost': 7.10, 'status': 'Fair'},
      {'date': '2025-01-04', 'usage': 87, 'cost': 4.35, 'status': 'Excellent'},
      {'date': '2025-01-05', 'usage': 110, 'cost': 5.50, 'status': 'Good'},
      {'date': '2025-01-06', 'usage': 95, 'cost': 4.75, 'status': 'Excellent'},
      {'date': '2025-01-07', 'usage': 118, 'cost': 5.90, 'status': 'Good'},
    ];
    
    for (int i = 0; i < dailyData.length; i++) {
      int row = i + 2;
      _setCell(sheet, 'A$row', dailyData[i]['date'].toString());
      _setCell(sheet, 'B$row', dailyData[i]['usage'].toString());
      _setCell(sheet, 'C$row', dailyData[i]['cost'].toString());
      _setCell(sheet, 'D$row', dailyData[i]['status'].toString());
    }
  }

  // Appliance Breakdown Sheet
  static void _createApplianceBreakdownSheet(Excel excel) {
    var sheet = excel['Appliance Breakdown'];
    
    // Headers
    _setCell(sheet, 'A1', 'Appliance', bold: true);
    _setCell(sheet, 'B1', 'Location', bold: true);
    _setCell(sheet, 'C1', 'Usage (L)', bold: true);
    _setCell(sheet, 'D1', 'Percentage', bold: true);
    _setCell(sheet, 'E1', 'Cost (₹)', bold: true);
    
    // Sample data
    List<Map<String, dynamic>> applianceData = [
      {'appliance': 'Shower', 'location': 'Bathroom 1', 'usage': 1250, 'percentage': '35%', 'cost': 62.50},
      {'appliance': 'Kitchen Tap', 'location': 'Kitchen', 'usage': 980, 'percentage': '28%', 'cost': 49.00},
      {'appliance': 'Bathroom Tap', 'location': 'Bathroom 1', 'usage': 850, 'percentage': '24%', 'cost': 42.50},
      {'appliance': 'Washing Machine', 'location': 'Utility', 'usage': 450, 'percentage': '13%', 'cost': 22.50},
    ];
    
    for (int i = 0; i < applianceData.length; i++) {
      int row = i + 2;
      _setCell(sheet, 'A$row', applianceData[i]['appliance'].toString());
      _setCell(sheet, 'B$row', applianceData[i]['location'].toString());
      _setCell(sheet, 'C$row', applianceData[i]['usage'].toString());
      _setCell(sheet, 'D$row', applianceData[i]['percentage'].toString());
      _setCell(sheet, 'E$row', applianceData[i]['cost'].toString());
    }
  }

  // Leak History Sheet
  static void _createLeakHistorySheet(Excel excel) {
    var sheet = excel['Leak History'];
    
    // Headers
    _setCell(sheet, 'A1', 'Date & Time', bold: true);
    _setCell(sheet, 'B1', 'Location', bold: true);
    _setCell(sheet, 'C1', 'Flow Rate (L/min)', bold: true);
    _setCell(sheet, 'D1', 'Water Lost (L)', bold: true);
    _setCell(sheet, 'E1', 'Cost Impact (₹)', bold: true);
    
    // Sample data
    List<Map<String, dynamic>> leakData = [
      {
        'datetime': '2025-01-03 14:25',
        'location': 'Bathroom 1 Tap',
        'flow': 0.8,
        'lost': 45,
        'cost': 2.25
      },
      {
        'datetime': '2025-01-05 22:10',
        'location': 'Kitchen Tap',
        'flow': 0.5,
        'lost': 28,
        'cost': 1.40
      },
    ];
    
    for (int i = 0; i < leakData.length; i++) {
      int row = i + 2;
      _setCell(sheet, 'A$row', leakData[i]['datetime'].toString());
      _setCell(sheet, 'B$row', leakData[i]['location'].toString());
      _setCell(sheet, 'C$row', leakData[i]['flow'].toString());
      _setCell(sheet, 'D$row', leakData[i]['lost'].toString());
      _setCell(sheet, 'E$row', leakData[i]['cost'].toString());
    }
  }

  // Cost Analysis Sheet
  static void _createCostAnalysisSheet(Excel excel) {
    var sheet = excel['Cost Analysis'];
    
    // Headers
    _setCell(sheet, 'A1', 'Category', bold: true);
    _setCell(sheet, 'B1', 'Amount (₹)', bold: true);
    
    // Data
    _setCell(sheet, 'A2', 'Water Bill This Month');
    _setCell(sheet, 'B2', '162.25');
    
    _setCell(sheet, 'A3', 'Average Previous Months');
    _setCell(sheet, 'B3', '215.00');
    
    _setCell(sheet, 'A4', 'Savings This Month', bold: true);
    _setCell(sheet, 'B4', '52.75', bold: true);
    
    _setCell(sheet, 'A6', 'Projected Annual Cost');
    _setCell(sheet, 'B6', '1947.00');
    
    _setCell(sheet, 'A7', 'Potential Annual Savings');
    _setCell(sheet, 'B7', '633.00');
  }

  // Helper method to set cell value and style
  static void _setCell(Sheet sheet, String cellAddress, String value, {bool bold = false}) {
    var cell = sheet.cell(CellIndex.indexByString(cellAddress));
    cell.value = TextCellValue(value);
    if (bold) {
      cell.cellStyle = CellStyle(bold: true);
    }
  }

  // Save Excel file
  static Future<String?> _saveExcelFile(Excel excel, String filename) async {
    try {
      // Get the Downloads directory
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) return null;
      
      // Create filename with timestamp
      String timestamp = DateTime.now().toIso8601String().split('.')[0].replaceAll(':', '-');
      String fullPath = '${directory.path}/${filename}_$timestamp.xlsx';
      
      // Encode and save
      var fileBytes = excel.save();
      if (fileBytes == null) return null;
      
      File file = File(fullPath);
      await file.writeAsBytes(fileBytes);
      
      return fullPath;
      
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }
}