import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_app/services/recap_print_service.dart';
import 'package:laundry_app/services/supabase_service.dart';

void main() {
  test('buildMonthlyRecapPrintHtml aggregates clean, rewash, secondaryItems and escapes HTML', () {
    final logs = [
      LinenLogEntry(
        id: '1',
        createdAt: DateTime(2026, 11, 10, 9, 0),
        category: 'FREN',
        handlerName: 'Pak Ilham',
        items: {'Pillowcase': 30, 'Bathtowel': 5},
        notes: {},
        secondaryItems: {'Bathtowel': 2},
      ),
      LinenLogEntry(
        id: '2',
        createdAt: DateTime(2026, 11, 12, 14, 0),
        category: 'REWASH',
        handlerName: 'Siti',
        items: {'Pillowcase': 4, '<script>alert(1)</script>': 100},
        notes: {},
        secondaryItems: {},
      ),
    ];

    final html = RecapPrintService.buildMonthlyRecapPrintHtml(
      month: 11,
      year: 2026,
      logs: logs,
      printDate: DateTime(2026, 11, 24),
    );

    // Letterhead & metadata
    expect(html, contains('favehotel Padjajaran Bogor'));
    expect(html, contains('+62 251 8356100'));
    expect(html, contains('MONTHLY LAUNDRY RECAP'));
    expect(html, contains('MLR-202611'));
    expect(html, contains('November 2026'));
    expect(html, contains('24 November 2026'));
    expect(html, contains('2 Handover(s)'));

    // Print styles + clean full-width TOTAL row (no signature block)
    expect(html, contains('@media print'));
    expect(html, contains('<td colspan="2" class="total-label">TOTAL</td>'));
    expect(html, isNot(contains('Prepared by')));
    expect(html, isNot(contains('Checked by')));
    expect(html, isNot(contains('Approved by')));

    // HTML escaping + descending sort order:
    // '<script>alert(1)</script>' total = 100 (rewash 100, clean 0) -> row 1
    // 'Pillowcase' total = 34 (clean 30, rewash 4) -> row 2
    // 'Bathtowel' total = 7 (clean 5, rewash 2 from secondaryItems) -> row 3
    expect(html, isNot(contains('<script>alert(1)</script>')));
    expect(html, contains('&lt;script&gt;alert(1)&lt;&#47;script&gt;'));

    final xssIdx = html.indexOf('&lt;script&gt;alert(1)&lt;&#47;script&gt;');
    final pillowIdx = html.indexOf('Pillowcase');
    final towelIdx = html.indexOf('Bathtowel');
    expect(xssIdx, lessThan(pillowIdx));
    expect(pillowIdx, lessThan(towelIdx));

    // Totals: clean = 35, rewash = 106, grandTotal = 141, rewashRate = 75.2%
    expect(html, contains('75.2%'));
    expect(html, contains('<td class="total-value">35</td>'));
    expect(html, contains('<td class="total-value">106</td>'));
    expect(html, contains('<td class="total-value">141</td>'));
  });
}
