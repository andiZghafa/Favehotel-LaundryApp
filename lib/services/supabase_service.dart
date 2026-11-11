import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:laundry_app/services/excel_service.dart';
import 'package:laundry_app/services/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

/// Single log entry representation returned by Supabase
class LinenLogEntry {
  final String id;
  final DateTime createdAt;
  final String category;
  final String handlerName;
  final Map<String, int> items;
  final Map<String, String> notes;
  final Map<String, int> secondaryItems;

  LinenLogEntry({
    required this.id,
    required this.createdAt,
    required this.category,
    required this.handlerName,
    required this.items,
    required this.notes,
    required this.secondaryItems,
  });

  factory LinenLogEntry.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as Map<String, dynamic>? ?? {};
    final rawNotes = json['notes'] as Map<String, dynamic>? ?? {};
    final rawSec = json['secondary_items'] as Map<String, dynamic>? ?? {};

    return LinenLogEntry(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      category: json['category']?.toString() ?? '',
      handlerName: json['handler_name']?.toString() ?? 'Staff',
      items: rawItems.map((k, v) => MapEntry(k, (v as num).toInt())),
      notes: rawNotes.map((k, v) => MapEntry(k, v.toString())),
      secondaryItems: rawSec.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  int get totalPieces {
    int sum = 0;
    items.forEach((_, count) => sum += count);
    secondaryItems.forEach((_, count) => sum += count);
    return sum;
  }
}

class SupabaseService {
  // Built-in defaults ensure immediate functionality; can be overridden via --dart-define
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jqizcrambkwrmiwnyfte.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_s3rQL-l_H_t86Y2OTs_4ag_bxsDl02o',
  );

  static const String defaultPin = String.fromEnvironment(
    'HOTEL_PIN',
    defaultValue: '8821',
  );

  static Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  /// Save a session log into Supabase asynchronously (never blocks Excel export)
  static Future<bool> saveLog({
    required String category,
    required String handlerName,
    required Map<String, int> items,
    required Map<String, String> notes,
    Map<String, int>? secondaryItems,
  }) async {
    try {
      final cleanItems = <String, int>{};
      items.forEach((k, v) {
        if (v > 0) cleanItems[k] = v;
      });

      final cleanNotes = <String, String>{};
      notes.forEach((k, v) {
        if (v.trim().isNotEmpty) cleanNotes[k] = v.trim();
      });

      final cleanSecondary = <String, int>{};
      secondaryItems?.forEach((k, v) {
        if (v > 0) cleanSecondary[k] = v;
      });

      final payload = jsonEncode({
        'category': category.toUpperCase(),
        'handler_name': handlerName.trim().isEmpty ? 'Housekeeping Staff' : handlerName.trim(),
        'items': cleanItems,
        'notes': cleanNotes,
        'secondary_items': cleanSecondary,
      });

      final res = await http.post(
        Uri.parse('$url/rest/v1/laundry_logs'),
        headers: {
          ..._headers,
          'Prefer': 'return=minimal',
        },
        body: payload,
      );

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Supabase saveLog error: $e');
      return false;
    }
  }

  /// Securely query logs for a specific month using the hotel PIN
  static Future<List<LinenLogEntry>> fetchMonthlyLogs({
    required String pin,
    required int month,
    required int year,
  }) async {
    try {
      final payload = jsonEncode({
        'pin': pin.trim(),
        'target_month': month,
        'target_year': year,
      });

      final res = await http.post(
        Uri.parse('$url/rest/v1/rpc/get_hotel_logs'),
        headers: _headers,
        body: payload,
      );

      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((item) => LinenLogEntry.fromJson(item)).toList();
      } else {
        if (kDebugMode) print('Fetch logs error code ${res.statusCode}: ${res.body}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) print('Supabase fetchMonthlyLogs error: $e');
      return [];
    }
  }

  /// Export an aggregated Monthly Master Spreadsheet (.xlsx)
  static Future<ExcelExportResult> exportMonthlyRecapExcel({
    required int month,
    required int year,
    required List<LinenLogEntry> logs,
  }) async {
    try {
      final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));
      final xls.Workbook workbook = xls.Workbook();

      // ── Sheet 1: Monthly Aggregated Summary ──────────────────────────────
      final xls.Worksheet summarySheet = workbook.worksheets[0];
      summarySheet.name = 'MONTHLY SUMMARY';

      // Header Banner
      final titleRange = summarySheet.getRangeByName('A1:D1');
      titleRange.merge();
      titleRange.setText('FAVEHOTEL LAUNDRY - REKAP BULANAN ($monthName)');
      titleRange.cellStyle.fontSize = 13;
      titleRange.cellStyle.bold = true;
      titleRange.cellStyle.fontColor = '#FFFFFF';
      titleRange.cellStyle.backColor = '#900C46';

      // Table headers
      final summaryHeaders = ['Item / Linen Name', 'Total Clean (FREN+FAST)', 'Total Rewash', 'Grand Total'];
      for (int i = 0; i < summaryHeaders.length; i++) {
        final cell = summarySheet.getRangeByIndex(3, i + 1);
        cell.setText(summaryHeaders[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#F1F5F9';
        cell.cellStyle.fontColor = '#0F172A';
      }

      // Aggregate item counts across all logs
      final Map<String, int> cleanCounts = {};
      final Map<String, int> rewashCounts = {};
      final Set<String> allItemNames = {};

      for (var log in logs) {
        final isRewash = log.category == 'REWASH';
        log.items.forEach((item, count) {
          allItemNames.add(item);
          if (isRewash) {
            rewashCounts[item] = (rewashCounts[item] ?? 0) + count;
          } else {
            cleanCounts[item] = (cleanCounts[item] ?? 0) + count;
          }
        });
        log.secondaryItems.forEach((item, count) {
          allItemNames.add(item);
          rewashCounts[item] = (rewashCounts[item] ?? 0) + count;
        });
      }

      final sortedItems = allItemNames.toList()..sort();
      int summaryRow = 4;
      int grandClean = 0;
      int grandRewash = 0;

      for (var item in sortedItems) {
        final clean = cleanCounts[item] ?? 0;
        final rewash = rewashCounts[item] ?? 0;
        final total = clean + rewash;

        grandClean += clean;
        grandRewash += rewash;

        summarySheet.getRangeByIndex(summaryRow, 1).setText(item);
        summarySheet.getRangeByIndex(summaryRow, 2).setNumber(clean.toDouble());
        summarySheet.getRangeByIndex(summaryRow, 3).setNumber(rewash.toDouble());
        summarySheet.getRangeByIndex(summaryRow, 4).setNumber(total.toDouble());
        summaryRow++;
      }

      // Total row
      summarySheet.getRangeByIndex(summaryRow, 1).setText('TOTAL PIECES');
      summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
      summarySheet.getRangeByIndex(summaryRow, 2).setNumber(grandClean.toDouble());
      summarySheet.getRangeByIndex(summaryRow, 2).cellStyle.bold = true;
      summarySheet.getRangeByIndex(summaryRow, 3).setNumber(grandRewash.toDouble());
      summarySheet.getRangeByIndex(summaryRow, 3).cellStyle.bold = true;
      summarySheet.getRangeByIndex(summaryRow, 4).setNumber((grandClean + grandRewash).toDouble());
      summarySheet.getRangeByIndex(summaryRow, 4).cellStyle.bold = true;

      for (int i = 1; i <= 4; i++) {
        summarySheet.autoFitColumn(i);
      }

      // ── Sheet 2: Daily Log Details ───────────────────────────────────────
      final xls.Worksheet detailSheet = workbook.worksheets.addWithName('LOG DETAILS');
      final detailHeaders = ['Date', 'Time', 'Category', 'Handler Name', 'Total Items', 'Items Breakdown', 'Notes'];

      final detailTitle = detailSheet.getRangeByName('A1:G1');
      detailTitle.merge();
      detailTitle.setText('DAILY LOG HISTORY - $monthName');
      detailTitle.cellStyle.fontSize = 13;
      detailTitle.cellStyle.bold = true;
      detailTitle.cellStyle.fontColor = '#FFFFFF';
      detailTitle.cellStyle.backColor = '#900C46';

      for (int i = 0; i < detailHeaders.length; i++) {
        final cell = detailSheet.getRangeByIndex(3, i + 1);
        cell.setText(detailHeaders[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#F1F5F9';
        cell.cellStyle.fontColor = '#0F172A';
      }

      int detailRow = 4;
      for (var log in logs) {
        final dateStr = DateFormat('dd/MM/yyyy').format(log.createdAt);
        final timeStr = DateFormat('HH:mm').format(log.createdAt);

        final itemsText = log.items.entries.map((e) => '${e.key}: ${e.value}').join(', ');
        final notesText = log.notes.entries.map((e) => '${e.key}: ${e.value}').join('; ');

        detailSheet.getRangeByIndex(detailRow, 1).setText(dateStr);
        detailSheet.getRangeByIndex(detailRow, 2).setText(timeStr);
        detailSheet.getRangeByIndex(detailRow, 3).setText(log.category);
        detailSheet.getRangeByIndex(detailRow, 4).setText(log.handlerName);
        detailSheet.getRangeByIndex(detailRow, 5).setNumber(log.totalPieces.toDouble());
        detailSheet.getRangeByIndex(detailRow, 6).setText(itemsText);
        detailSheet.getRangeByIndex(detailRow, 7).setText(notesText.isEmpty ? '-' : notesText);
        detailRow++;
      }

      for (int i = 1; i <= 7; i++) {
        detailSheet.autoFitColumn(i);
      }

      // Save bytes and download
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final fileName = 'favehotel_Laundry_Recap_${year}_${month.toString().padLeft(2, '0')}.xlsx';
      final path = await saveExportFile(bytes, fileName, 'MONTHLY_RECAP');

      return ExcelExportResult(
        success: true,
        message: 'Monthly recap exported successfully!',
        filePath: path,
      );
    } catch (e) {
      return ExcelExportResult(
        success: false,
        message: 'Failed to export monthly recap: $e',
      );
    }
  }
}
