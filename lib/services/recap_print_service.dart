import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/services/supabase_service.dart';
import 'package:universal_html/html.dart' as html;

class _AggregatedItem {
  int clean = 0;
  int rewash = 0;
  int total = 0;
}

/// Builds and opens an A4 print-ready Monthly Laundry Recap styled after
/// the official favehotel Padjajaran Bogor document layout.
class RecapPrintService {
  static const HtmlEscape _escape = HtmlEscape();

  /// Generates a self-contained A4 HTML document with screen preview toolbar
  /// and print media styles for the given month's laundry logs.
  static String buildMonthlyRecapPrintHtml({
    required int month,
    required int year,
    required List<LinenLogEntry> logs,
    String? logoBase64,
    DateTime? printDate,
  }) {
    final Map<String, _AggregatedItem> aggregated = {};

    for (final log in logs) {
      final isRewash = log.category.toUpperCase() == 'REWASH';
      log.items.forEach((item, count) {
        final entry = aggregated.putIfAbsent(item, _AggregatedItem.new);
        if (isRewash) {
          entry.rewash += count;
        } else {
          entry.clean += count;
        }
        entry.total += count;
      });

      log.secondaryItems.forEach((item, count) {
        final entry = aggregated.putIfAbsent(item, _AggregatedItem.new);
        entry.rewash += count;
        entry.total += count;
      });
    }

    final sortedEntries = aggregated.entries.toList()
      ..sort((a, b) {
        final totalCmp = b.value.total.compareTo(a.value.total);
        if (totalCmp != 0) return totalCmp;
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

    int totalClean = 0;
    int totalRewash = 0;
    int grandTotal = 0;
    for (final e in sortedEntries) {
      totalClean += e.value.clean;
      totalRewash += e.value.rewash;
      grandTotal += e.value.total;
    }

    final double rewashRate =
        grandTotal > 0 ? (totalRewash / grandTotal) * 100 : 0.0;

    final docNo = 'MLR-$year${month.toString().padLeft(2, '0')}';
    final periodLabel = DateFormat('MMMM yyyy').format(DateTime(year, month));
    final printDateStr =
        DateFormat('dd MMMM yyyy').format((printDate ?? DateTime.now()).toLocal());
    final intFormat = NumberFormat('#,##0');

    final safeDocNo = _escape.convert(docNo);
    final safePeriod = _escape.convert(periodLabel);
    final safePrintDate = _escape.convert(printDateStr);
    final safeSessions = _escape.convert('${logs.length} Handover(s)');
    final safeRewashRate = _escape.convert('${rewashRate.toStringAsFixed(1)}%');

    final logoHtml = (logoBase64 != null && logoBase64.isNotEmpty)
        ? '<img src="data:image/png;base64,$logoBase64" alt="favehotel Padjajaran Bogor" class="logo-img" />'
        : '<div class="logo-fallback"><span class="logo-main">favehotel</span><span class="logo-sub">Padjajaran - Bogor</span></div>';

    final rowsBuffer = StringBuffer();
    if (sortedEntries.isEmpty) {
      rowsBuffer.writeln('''
        <tr>
          <td colspan="5" class="empty-cell">No linen logs recorded for $safePeriod.</td>
        </tr>
      ''');
    } else {
      for (int i = 0; i < sortedEntries.length; i++) {
        final item = sortedEntries[i];
        rowsBuffer.writeln('''
        <tr>
          <td class="col-no">${i + 1}</td>
          <td class="col-desc">${_escape.convert(item.key)}</td>
          <td class="col-num">${intFormat.format(item.value.clean)}</td>
          <td class="col-num">${intFormat.format(item.value.rewash)}</td>
          <td class="col-num col-total">${intFormat.format(item.value.total)}</td>
        </tr>
        ''');
      }
    }

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Monthly Laundry Recap - $safeDocNo ($safePeriod)</title>
  <style>
    * { box-sizing: border-box; }
    html, body {
      margin: 0;
      padding: 0;
      font-family: Arial, Helvetica, sans-serif;
      color: #000;
      background: #525659;
      font-size: 11px;
      line-height: 1.4;
    }
    .toolbar {
      position: sticky;
      top: 0;
      z-index: 100;
      background: #323639;
      color: #f1f5f9;
      padding: 10px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.35);
    }
    .toolbar-title {
      font-size: 13px;
      font-weight: 600;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .toolbar-actions {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-shrink: 0;
    }
    .btn {
      border: 1px solid rgba(255, 255, 255, 0.22);
      background: #474c50;
      color: #fff;
      padding: 7px 14px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
    }
    .btn:hover { background: #5a6065; }
    .btn-primary {
      background: #a3004c;
      border-color: #a3004c;
    }
    .btn-primary:hover { background: #87003f; }
    .viewport {
      padding: 24px 16px 40px;
      display: flex;
      justify-content: center;
    }
    .page {
      width: 210mm;
      min-height: 297mm;
      background: #fff;
      padding: 14mm 16mm;
      box-shadow: 0 6px 24px rgba(0, 0, 0, 0.45);
      display: flex;
      flex-direction: column;
    }
    .letterhead {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 16px;
      padding-bottom: 12px;
      border-bottom: 1.5px solid #000;
    }
    .logo-img {
      height: 46px;
      width: auto;
      object-fit: contain;
    }
    .logo-fallback {
      display: flex;
      flex-direction: column;
      color: #a3004c;
    }
    .logo-main {
      font-size: 24px;
      font-weight: 700;
      letter-spacing: -0.5px;
      line-height: 1.1;
    }
    .logo-sub {
      font-size: 10px;
      letter-spacing: 0.8px;
    }
    .hotel-address {
      text-align: right;
      max-width: 58%;
      font-size: 10px;
      line-height: 1.38;
    }
    .hotel-name {
      font-size: 13px;
      font-weight: 700;
      margin-bottom: 2px;
    }
    .doc-title {
      text-align: center;
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 0.6px;
      margin: 16px 0 14px;
    }
    .meta-grid {
      display: flex;
      justify-content: space-between;
      gap: 24px;
      margin-bottom: 12px;
      font-size: 10.5px;
    }
    .meta-table {
      border-collapse: collapse;
    }
    .meta-table td {
      padding: 1.5px 4px 1.5px 0;
      vertical-align: top;
    }
    .meta-label {
      min-width: 96px;
      white-space: nowrap;
    }
    .meta-colon {
      width: 10px;
      text-align: center;
    }
    table.items-table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 4px;
      font-size: 10.5px;
    }
    .items-table th,
    .items-table td {
      border: 1px solid #000;
      padding: 5px 7px;
      vertical-align: middle;
    }
    .items-table thead th {
      font-weight: 700;
      background: #f8f8f8;
      text-align: left;
    }
    .items-table thead th.col-no { text-align: center; width: 34px; }
    .items-table thead th.col-num { text-align: right; width: 88px; }
    .col-no { text-align: center; }
    .col-desc { text-align: left; }
    .col-num {
      text-align: right;
      font-variant-numeric: tabular-nums;
    }
    .col-total { font-weight: 700; }
    .empty-cell {
      text-align: center;
      padding: 18px 8px;
      color: #444;
    }
    .total-spacer {
      border: none !important;
      background: transparent !important;
    }
    .total-label {
      text-align: right;
      font-weight: 700;
      letter-spacing: 0.4px;
    }
    .total-value {
      text-align: right;
      font-weight: 700;
      font-variant-numeric: tabular-nums;
    }
    .signatures {
      margin-top: auto;
      padding-top: 24px;
    }
    .sig-table {
      width: 100%;
      border-collapse: collapse;
      table-layout: fixed;
      font-size: 10px;
    }
    .sig-table td {
      border: 1px solid #000;
      padding: 6px 8px;
      text-align: center;
      vertical-align: top;
    }
    .sig-role {
      font-weight: 700;
    }
    .sig-dept {
      color: #333;
      font-size: 9.5px;
      margin-top: 1px;
    }
    .sig-space {
      height: 52px;
    }
    .sig-line {
      border-top: 1px solid #555;
      padding-top: 4px;
      font-size: 9.5px;
      color: #222;
    }
    @page {
      size: A4 portrait;
      margin: 12mm;
    }
    @media print {
      html, body {
        background: #fff;
      }
      .no-print {
        display: none !important;
      }
      .viewport {
        padding: 0;
        display: block;
      }
      .page {
        width: 100%;
        min-height: 273mm;
        padding: 0;
        margin: 0;
        box-shadow: none;
      }
      .items-table thead th {
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
      }
      .items-table tr {
        break-inside: avoid;
      }
      .signatures {
        break-inside: avoid;
      }
    }
  </style>
</head>
<body>
  <div class="toolbar no-print">
    <div class="toolbar-title">Monthly Laundry Recap - $safeDocNo favehotel Padjajaran Bogor</div>
    <div class="toolbar-actions">
      <button type="button" class="btn btn-primary" onclick="window.print()">Print / Save as PDF</button>
      <button type="button" class="btn" onclick="window.close()">Close</button>
    </div>
  </div>
  <div class="viewport">
    <div class="page">
      <div class="letterhead">
        <div>$logoHtml</div>
        <div class="hotel-address">
          <div class="hotel-name">favehotel Padjajaran Bogor</div>
          <div>Jl. Cidangiang No.1, RT.04/RW.05, Tegallega, Kecamatan Bogor Tengah, Kota Bogor, Jawa Barat</div>
          <div>+62 251 8356100</div>
        </div>
      </div>

      <div class="doc-title">MONTHLY LAUNDRY RECAP</div>

      <div class="meta-grid">
        <table class="meta-table">
          <tr>
            <td class="meta-label">Document No</td>
            <td class="meta-colon">:</td>
            <td>$safeDocNo</td>
          </tr>
          <tr>
            <td class="meta-label">Department</td>
            <td class="meta-colon">:</td>
            <td>Housekeeping</td>
          </tr>
          <tr>
            <td class="meta-label">Total Sessions</td>
            <td class="meta-colon">:</td>
            <td>$safeSessions</td>
          </tr>
        </table>
        <table class="meta-table">
          <tr>
            <td class="meta-label">Period</td>
            <td class="meta-colon">:</td>
            <td>$safePeriod</td>
          </tr>
          <tr>
            <td class="meta-label">Print Date</td>
            <td class="meta-colon">:</td>
            <td>$safePrintDate</td>
          </tr>
          <tr>
            <td class="meta-label">Rewash Rate</td>
            <td class="meta-colon">:</td>
            <td>$safeRewashRate</td>
          </tr>
        </table>
      </div>

      <table class="items-table">
        <thead>
          <tr>
            <th class="col-no">No</th>
            <th>Description / Linen Item</th>
            <th class="col-num">Clean (Pcs)</th>
            <th class="col-num">Rewash (Pcs)</th>
            <th class="col-num">Total (Pcs)</th>
          </tr>
        </thead>
        <tbody>
          $rowsBuffer
          <tr>
            <td class="total-spacer"></td>
            <td class="total-label">TOTAL</td>
            <td class="total-value">${intFormat.format(totalClean)}</td>
            <td class="total-value">${intFormat.format(totalRewash)}</td>
            <td class="total-value">${intFormat.format(grandTotal)}</td>
          </tr>
        </tbody>
      </table>

      <div class="signatures">
        <table class="sig-table">
          <tr>
            <td>
              <div class="sig-role">Prepared by</div>
              <div class="sig-dept">Housekeeping Staff</div>
              <div class="sig-space"></div>
              <div class="sig-line">Name &amp; Date</div>
            </td>
            <td>
              <div class="sig-role">Checked by</div>
              <div class="sig-dept">Housekeeping Supervisor</div>
              <div class="sig-space"></div>
              <div class="sig-line">Name &amp; Date</div>
            </td>
            <td>
              <div class="sig-role">Approved by</div>
              <div class="sig-dept">Hotel Manager</div>
              <div class="sig-space"></div>
              <div class="sig-line">Name &amp; Date</div>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</body>
</html>''';
  }

  /// Opens the A4 print preview in a new browser tab for Web users.
  static Future<String> openPrintPreview({
    required int month,
    required int year,
    required List<LinenLogEntry> logs,
  }) async {
    if (!kIsWeb) {
      return 'Print preview hanya tersedia di versi Web.';
    }

    String? logoBase64;
    try {
      final data = await rootBundle.load('assets/logo_clean.png');
      logoBase64 = base64Encode(data.buffer.asUint8List());
    } catch (_) {
      logoBase64 = null;
    }

    final htmlContent = buildMonthlyRecapPrintHtml(
      month: month,
      year: year,
      logs: logs,
      logoBase64: logoBase64,
    );

    final blob = html.Blob([htmlContent], 'text/html; charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final win = html.window.open(url, '_blank');

    // Keep the object URL alive long enough for the new tab to finish loading it.
    Future.delayed(const Duration(minutes: 2), () {
      html.Url.revokeObjectUrl(url);
    });

    if (win == null) {
      return 'Popup diblokir browser. Izinkan popup untuk membuka Print Preview.';
    }
    return 'Print preview dibuka di tab baru.';
  }
}
