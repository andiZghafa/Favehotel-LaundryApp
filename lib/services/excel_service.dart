import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class ExcelExportResult {
  final bool success;
  final String message;
  final String? filePath;

  ExcelExportResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

class ExcelExportService {
  /// Export a single category (FREN or FAST) logbook to Excel
  static Future<ExcelExportResult> exportSingleCategory({
    required String categoryName,
    required String handlerName,
    required Map<String, int> items,
    required Map<String, String> notes,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('dd-MM-yyyy').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      final xls.Workbook workbook = xls.Workbook();
      final xls.Worksheet sheet = workbook.worksheets[0];
      sheet.name = categoryName.toUpperCase();

      // Setup styling
      _applyHeaderStyles(sheet, '$categoryName LOGBOOK - $dateStr ($timeStr)');
      _setupTableHeaders(sheet, 3);

      int row = 4;
      int totalQuantity = 0;

      items.forEach((item, qty) {
        if (qty > 0 || (notes[item]?.isNotEmpty ?? false)) {
          sheet.getRangeByIndex(row, 1).setText(item);
          sheet.getRangeByIndex(row, 2).setNumber(qty.toDouble());
          sheet.getRangeByIndex(row, 3).setText(notes[item] ?? '-');
          sheet.getRangeByIndex(row, 4).setText(handlerName);
          sheet.getRangeByIndex(row, 5).setText(dateStr);
          sheet.getRangeByIndex(row, 6).setText(timeStr);
          totalQuantity += qty;
          row++;
        }
      });

      // Total row
      sheet.getRangeByIndex(row, 1).setText('TOTAL PIECES');
      sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(row, 2).setNumber(totalQuantity.toDouble());
      sheet.getRangeByIndex(row, 2).cellStyle.bold = true;

      // Auto-fit columns
      for (int i = 1; i <= 6; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final fileName = '${categoryName.toUpperCase()}_${handlerName.replaceAll(' ', '_')}_$dateStr.xlsx';
      return await _saveOrDownload(bytes, fileName, categoryName);
    } catch (e) {
      return ExcelExportResult(
        success: false,
        message: 'Failed to export Excel: ${e.toString()}',
      );
    }
  }

  /// Export REWASH logbook with FREN and FAST tabs/sheets
  static Future<ExcelExportResult> exportRewashLog({
    required String handlerName,
    required Map<String, int> frenRewashItems,
    required Map<String, String> frenRewashNotes,
    required Map<String, int> fastRewashItems,
    required Map<String, String> fastRewashNotes,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('dd-MM-yyyy').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      final xls.Workbook workbook = xls.Workbook();

      // Sheet 1: FREN REWASH
      final xls.Worksheet frenSheet = workbook.worksheets[0];
      frenSheet.name = 'FREN REWASH';
      _populateRewashSheet(frenSheet, 'FREN REWASH LOG', handlerName, dateStr, timeStr, frenRewashItems, frenRewashNotes);

      // Sheet 2: FAST REWASH
      final xls.Worksheet fastSheet = workbook.worksheets.addWithName('FAST REWASH');
      _populateRewashSheet(fastSheet, 'FAST REWASH LOG', handlerName, dateStr, timeStr, fastRewashItems, fastRewashNotes);

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final fileName = 'REWASH_${handlerName.replaceAll(' ', '_')}_$dateStr.xlsx';
      return await _saveOrDownload(bytes, fileName, 'REWASH');
    } catch (e) {
      return ExcelExportResult(
        success: false,
        message: 'Failed to export Rewash Excel: ${e.toString()}',
      );
    }
  }

  static void _populateRewashSheet(
    xls.Worksheet sheet,
    String title,
    String handlerName,
    String dateStr,
    String timeStr,
    Map<String, int> items,
    Map<String, String> notes,
  ) {
    _applyHeaderStyles(sheet, '$title - $dateStr ($timeStr)');
    _setupTableHeaders(sheet, 3, isRewash: true);

    int row = 4;
    int totalQuantity = 0;

    items.forEach((item, qty) {
      if (qty > 0 || (notes[item]?.isNotEmpty ?? false)) {
        sheet.getRangeByIndex(row, 1).setText(item);
        sheet.getRangeByIndex(row, 2).setNumber(qty.toDouble());
        sheet.getRangeByIndex(row, 3).setText(notes[item] ?? 'Stained/Rewash');
        sheet.getRangeByIndex(row, 4).setText(handlerName);
        sheet.getRangeByIndex(row, 5).setText(dateStr);
        sheet.getRangeByIndex(row, 6).setText(timeStr);
        totalQuantity += qty;
        row++;
      }
    });

    sheet.getRangeByIndex(row, 1).setText('TOTAL REWASH PIECES');
    sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(row, 2).setNumber(totalQuantity.toDouble());
    sheet.getRangeByIndex(row, 2).cellStyle.bold = true;

    for (int i = 1; i <= 6; i++) {
      sheet.autoFitColumn(i);
    }
  }

  static void _applyHeaderStyles(xls.Worksheet sheet, String title) {
    final titleRange = sheet.getRangeByName('A1:F1');
    titleRange.merge();
    titleRange.setText(title);
    titleRange.cellStyle.fontSize = 14;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontColor = '#900C46';
  }

  static void _setupTableHeaders(xls.Worksheet sheet, int row, {bool isRewash = false}) {
    final headers = [
      'Item Name',
      'Quantity',
      isRewash ? 'Reason / Stain Note' : 'Notes',
      'Handler / Person',
      'Date',
      'Time',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(row, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#900C46';
      cell.cellStyle.fontColor = '#FFFFFF';
    }
  }

  static Future<ExcelExportResult> _saveOrDownload(
    List<int> bytes,
    String fileName,
    String categoryName,
  ) async {
    if (kIsWeb) {
      final blob = html.Blob(
        [bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return ExcelExportResult(
        success: true,
        message: 'Downloaded $fileName successfully in browser.',
        filePath: fileName,
      );
    } else {
      try {
        io.Directory? directory;
        if (io.Platform.isAndroid) {
          final downloadDir = io.Directory('/storage/emulated/0/Download/laundry/$categoryName/');
          if (await downloadDir.exists() || await downloadDir.create(recursive: true).then((_) => true).catchError((_) => false)) {
            directory = downloadDir;
          }
        }
        directory ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

        final filePath = '${directory.path}${directory.path.endsWith('/') ? '' : '/'}$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        return ExcelExportResult(
          success: true,
          message: 'Saved to $filePath',
          filePath: filePath,
        );
      } catch (e) {
        return ExcelExportResult(
          success: false,
          message: 'Error saving file: ${e.toString()}',
        );
      }
    }
  }
}
