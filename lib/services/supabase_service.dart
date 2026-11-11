import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:laundry_app/services/excel_service.dart';
import 'package:laundry_app/services/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

class FetchLogsResult {
  final bool isAuthorized;
  final List<LinenLogEntry> logs;
  final String? errorMessage;

  FetchLogsResult({
    required this.isAuthorized,
    required this.logs,
    this.errorMessage,
  });
}

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

    final rawCreatedAt = json['created_at']?.toString() ?? '';
    final parsedDate = DateTime.tryParse(rawCreatedAt);
    final localCreatedAt = parsedDate != null ? parsedDate.toLocal() : DateTime.now();

    return LinenLogEntry(
      id: json['id']?.toString() ?? '',
      createdAt: localCreatedAt,
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

  /// Auto-detects whether Supabase sync should be active.
  /// On your portfolio domain (andiportofolio.my.id), cloud DB writes are disabled
  /// so visitors never pollute real hotel logs.
  static bool get isDatabaseSyncEnabled {
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.contains('andiportofolio.my.id')) {
        return false;
      }
    }
    return true;
  }

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
    // If running under portfolio showcase domain, safely skip DB persistence
    if (!isDatabaseSyncEnabled) {
      if (kDebugMode) print('Portfolio Demo Mode: Supabase sync skipped.');
      return true;
    }

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

  /// Securely query logs for a specific month using the hotel passcode (verified exclusively by Supabase)
  static Future<FetchLogsResult> fetchMonthlyLogs({
    required String pin,
    required int month,
    required int year,
  }) async {
    try {
      final payload = jsonEncode({
        'pin': pin.trim(),
        'target_month': month.toString(),
        'target_year': year,
      });

      final res = await http.post(
        Uri.parse('$url/rest/v1/rpc/get_hotel_logs'),
        headers: _headers,
        body: payload,
      );

      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        final logs = list.map((item) => LinenLogEntry.fromJson(item)).toList();
        return FetchLogsResult(isAuthorized: true, logs: logs);
      } else {
        final bodyStr = res.body.toLowerCase();
        final isInvalidPin = bodyStr.contains('invalid_pin') || res.statusCode == 400 || res.statusCode == 401;
        if (kDebugMode) print('Fetch logs response code ${res.statusCode}: ${res.body}');
        return FetchLogsResult(
          isAuthorized: !isInvalidPin,
          logs: [],
          errorMessage: isInvalidPin ? 'Passcode salah.' : 'Gagal terhubung ke database.',
        );
      }
    } catch (e) {
      if (kDebugMode) print('Supabase fetchMonthlyLogs error: $e');
      return FetchLogsResult(
        isAuthorized: false,
        logs: [],
        errorMessage: 'Gagal terhubung ke database.',
      );
    }
  }

  /// Export an executive-grade Monthly Master Spreadsheet (.xlsx)
  static Future<ExcelExportResult> exportMonthlyRecapExcel({
    required int month,
    required int year,
    required List<LinenLogEntry> logs,
  }) async {
    try {
      final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));
      final generatedTime = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final xls.Workbook workbook = xls.Workbook();

      // ── Sheet 1: Monthly Aggregated Summary ──────────────────────────────
      final xls.Worksheet summarySheet = workbook.worksheets[0];
      summarySheet.name = 'REKAP BULANAN';

      // 1. Hotel Brand Banner
      final bannerRange = summarySheet.getRangeByName('A1:E1');
      bannerRange.merge();
      bannerRange.setText('FAVEHOTEL PADJAJARAN - BOGOR');
      bannerRange.cellStyle.fontSize = 15;
      bannerRange.cellStyle.bold = true;
      bannerRange.cellStyle.fontColor = '#FFFFFF';
      bannerRange.cellStyle.backColor = '#900C46';

      final titleRange = summarySheet.getRangeByName('A2:E2');
      titleRange.merge();
      titleRange.setText('HOUSEKEEPING LAUNDRY LOGBOOK — REKAP BULANAN ($monthName)');
      titleRange.cellStyle.fontSize = 12;
      titleRange.cellStyle.bold = true;
      titleRange.cellStyle.fontColor = '#900C46';
      titleRange.cellStyle.backColor = '#FDF2F8';

      final metaRange = summarySheet.getRangeByName('A3:E3');
      metaRange.merge();
      metaRange.setText('Lokasi: Jl. Raya Pajajaran No.77, Bogor • Dicetak pada: $generatedTime • Total Sesi: ${logs.length}');
      metaRange.cellStyle.fontSize = 9.5;
      metaRange.cellStyle.fontColor = '#64748B';

      // 2. Aggregate Data
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

      int grandClean = 0;
      int grandRewash = 0;
      for (var c in cleanCounts.values) { grandClean += c; }
      for (var r in rewashCounts.values) { grandRewash += r; }
      final int grandTotalAll = grandClean + grandRewash;

      // 3. Table Headers
      final summaryHeaders = ['Item / Linen Name', 'Linen Bersih (Pcs)', 'Rewash / Noda (Pcs)', 'Total Handover (Pcs)', 'Kontribusi (%)'];
      for (int i = 0; i < summaryHeaders.length; i++) {
        final cell = summarySheet.getRangeByIndex(5, i + 1);
        cell.setText(summaryHeaders[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#900C46';
        cell.cellStyle.fontColor = '#FFFFFF';
      }

      final sortedItems = allItemNames.toList()..sort();
      int summaryRow = 6;

      for (var item in sortedItems) {
        final clean = cleanCounts[item] ?? 0;
        final rewash = rewashCounts[item] ?? 0;
        final total = clean + rewash;
        final pct = grandTotalAll > 0 ? (total / grandTotalAll * 100).toStringAsFixed(1) + '%' : '0.0%';

        summarySheet.getRangeByIndex(summaryRow, 1).setText(item);
        summarySheet.getRangeByIndex(summaryRow, 2).setNumber(clean.toDouble());
        summarySheet.getRangeByIndex(summaryRow, 3).setNumber(rewash.toDouble());
        summarySheet.getRangeByIndex(summaryRow, 4).setNumber(total.toDouble());
        summarySheet.getRangeByIndex(summaryRow, 5).setText(pct);

        // Zebra striping
        if (summaryRow % 2 == 1) {
          summarySheet.getRangeByName('A$summaryRow:E$summaryRow').cellStyle.backColor = '#F8FAFC';
        }

        summaryRow++;
      }

      // Grand Total Row
      final totalRowRange = summarySheet.getRangeByName('A$summaryRow:E$summaryRow');
      totalRowRange.cellStyle.bold = true;
      totalRowRange.cellStyle.backColor = '#FDF2F8';

      summarySheet.getRangeByIndex(summaryRow, 1).setText('GRAND TOTAL');
      summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.fontColor = '#900C46';
      summarySheet.getRangeByIndex(summaryRow, 2).setNumber(grandClean.toDouble());
      summarySheet.getRangeByIndex(summaryRow, 3).setNumber(grandRewash.toDouble());
      summarySheet.getRangeByIndex(summaryRow, 4).setNumber(grandTotalAll.toDouble());
      summarySheet.getRangeByIndex(summaryRow, 5).setText('100.0%');

      // 4. Executive KPI Summary Box
      summaryRow += 2;
      summarySheet.getRangeByIndex(summaryRow, 1).setText('RINGKASAN EKSEKUTIF:');
      summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
      summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.fontColor = '#900C46';
      summaryRow++;

      final double rewashRate = grandTotalAll > 0 ? (grandRewash / grandTotalAll * 100) : 0.0;
      final kpis = [
        ['Total Linen Bersih Terlayani', '$grandClean pcs'],
        ['Total Linen Rewash / Defect', '$grandRewash pcs'],
        ['Total Putaran Handover Linen', '$grandTotalAll pcs'],
        ['Tingkat Rewash (Rewash Rate)', '${rewashRate.toStringAsFixed(2)}%'],
        ['Total Sesi / Shift Input', '${logs.length} kali'],
      ];

      for (var kpi in kpis) {
        summarySheet.getRangeByIndex(summaryRow, 1).setText(kpi[0]);
        summarySheet.getRangeByIndex(summaryRow, 2).setText(kpi[1]);
        summarySheet.getRangeByIndex(summaryRow, 2).cellStyle.bold = true;
        summaryRow++;
      }

      for (int i = 1; i <= 5; i++) {
        summarySheet.autoFitColumn(i);
      }

      // ── Sheet 2: Daily Log Details ───────────────────────────────────────
      final xls.Worksheet detailSheet = workbook.worksheets.addWithName('DETAIL LOG HARIAN');
      final detailHeaders = ['Tanggal', 'Waktu', 'Kategori', 'Petugas / Handler', 'Total (Pcs)', 'Rincian Linen', 'Catatan / Noda'];

      final detailBanner = detailSheet.getRangeByName('A1:G1');
      detailBanner.merge();
      detailBanner.setText('FAVEHOTEL PADJAJARAN BOGOR — RIWAYAT LOG HARIAN ($monthName)');
      detailBanner.cellStyle.fontSize = 13;
      detailBanner.cellStyle.bold = true;
      detailBanner.cellStyle.fontColor = '#FFFFFF';
      detailBanner.cellStyle.backColor = '#900C46';

      for (int i = 0; i < detailHeaders.length; i++) {
        final cell = detailSheet.getRangeByIndex(3, i + 1);
        cell.setText(detailHeaders[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#900C46';
        cell.cellStyle.fontColor = '#FFFFFF';
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

        if (detailRow % 2 == 1) {
          detailSheet.getRangeByName('A$detailRow:G$detailRow').cellStyle.backColor = '#F8FAFC';
        }

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
        message: 'Rekap bulanan berhasil diexport ke Excel!',
        filePath: path,
      );
    } catch (e) {
      return ExcelExportResult(
        success: false,
        message: 'Gagal mengekspor rekap bulanan: $e',
      );
    }
  }
}
