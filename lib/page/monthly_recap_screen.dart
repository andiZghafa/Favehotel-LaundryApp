import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/services/supabase_service.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyRecapScreen extends StatefulWidget {
  const MonthlyRecapScreen({super.key});

  @override
  State<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen> {
  static const String _prefPinKey = 'fave_hotel_pin';

  DateTime _selectedDate = DateTime.now();
  String? _unlockedPin;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _errorMessage;
  List<LinenLogEntry> _logs = [];

  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString(_prefPinKey);
      if (savedPin != null && savedPin.isNotEmpty) {
        _unlockedPin = savedPin;
        _pinController.text = savedPin;
        _fetchLogs();
      }
    } catch (_) {}
  }

  Future<void> _unlockWithPin(String pin) async {
    final cleanPin = pin.trim();
    if (cleanPin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final logs = await SupabaseService.fetchMonthlyLogs(
      pin: cleanPin,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    // If query failed or PIN was rejected by Postgres function
    // Note: If no logs exist yet, it returns [] with valid pin
    // If pin != '8821', function returns empty set
    if (cleanPin != SupabaseService.defaultPin && logs.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect PIN. Please enter the valid hotel access code.';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefPinKey, cleanPin);
    } catch (_) {}

    setState(() {
      _unlockedPin = cleanPin;
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _fetchLogs() async {
    if (_unlockedPin == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final logs = await SupabaseService.fetchMonthlyLogs(
      pin: _unlockedPin!,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
    _fetchLogs();
  }

  Future<void> _handleExportExcel() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No records found for this month to export.'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    final res = await SupabaseService.exportMonthlyRecapExcel(
      month: _selectedDate.month,
      year: _selectedDate.year,
      logs: _logs,
    );

    setState(() => _isExporting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: res.success ? AppColors.statusSuccess : AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  int get _totalCleanPieces {
    int sum = 0;
    for (var log in _logs) {
      if (log.category != 'REWASH') {
        sum += log.totalPieces;
      }
    }
    return sum;
  }

  int get _totalRewashPieces {
    int sum = 0;
    for (var log in _logs) {
      if (log.category == 'REWASH') {
        sum += log.totalPieces;
      }
    }
    return sum;
  }

  Map<String, int> get _aggregatedItemTotals {
    final Map<String, int> map = {};
    for (var log in _logs) {
      log.items.forEach((k, v) => map[k] = (map[k] ?? 0) + v);
      log.secondaryItems.forEach((k, v) => map[k] = (map[k] ?? 0) + v);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);

    return AppBackground(
      maxWidth: 1140,
      child: Column(
        children: [
          // ── Top Navigation Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
            child: Row(
              children: [
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hairline),
                        boxShadow: const [
                          BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Recap (Rekap Bulanan)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _unlockedPin != null
                            ? 'favehotel Padjajaran • Verified Housekeeping Records'
                            : 'Confidential Internal Records',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (_unlockedPin != null)
                  IconButton(
                    tooltip: 'Lock Records',
                    icon: const Icon(Icons.lock_open_rounded, color: AppColors.brandMagenta, size: 20),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove(_prefPinKey);
                      setState(() {
                        _unlockedPin = null;
                        _logs = [];
                      });
                    },
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.hairline),

          // ── Main Content Area ───────────────────────────────────────────
          Expanded(
            child: _unlockedPin == null ? _buildPinEntryView() : _buildUnlockedDashboard(monthLabel),
          ),
        ],
      ),
    );
  }

  // ── PIN Entry View (For Public Portfolio Protection) ─────────────────────
  Widget _buildPinEntryView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 20, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.brandMagentaLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandMagenta.withOpacity(0.2)),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.brandMagenta, size: 28),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hotel Staff Verification',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monthly records contain real favehotel housekeeping operational logs. Enter the department PIN to access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: AppColors.brandMagenta,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  hintStyle: const TextStyle(letterSpacing: 4, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  fillColor: AppColors.surfaceInput,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.brandMagenta, width: 1.5),
                  ),
                ),
                onSubmitted: _unlockWithPin,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _unlockWithPin(_pinController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandMagenta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Unlock Records', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Unlocked Monthly Dashboard View ──────────────────────────────────────
  Widget _buildUnlockedDashboard(String monthLabel) {
    final totals = _aggregatedItemTotals;

    return Column(
      children: [
        // Month Switcher Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: () => _changeMonth(-1),
                tooltip: 'Previous Month',
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.brandMagenta),
                  const SizedBox(width: 8),
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: () => _changeMonth(1),
                tooltip: 'Next Month',
              ),
            ],
          ),
        ),

        // KPI Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Clean Linen Logged',
                  value: '$_totalCleanPieces pcs',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.catFren,
                  bgColor: AppColors.catFrenBg,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'Rewash / Defects',
                  value: '$_totalRewashPieces pcs',
                  icon: Icons.autorenew_rounded,
                  color: AppColors.catRewash,
                  bgColor: AppColors.catRewashBg,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Handover Shifts',
                  value: '${_logs.length} entries',
                  icon: Icons.history_rounded,
                  color: AppColors.catFast,
                  bgColor: AppColors.catFastBg,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Main List or Empty State
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandMagenta))
              : _logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No logs recorded for $monthLabel',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Records will appear automatically when staff export logbooks.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
                      children: [
                        const Text(
                          'Aggregated Monthly Item Totals',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Column(
                            children: totals.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: AppColors.hairline, width: 0.6)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} pcs',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandMagenta,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
        ),

        // Bottom Export CTA Bar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Master Sheet (.xlsx) • ${_logs.length} logs ready',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isExporting || _logs.isEmpty ? null : _handleExportExcel,
                icon: _isExporting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.file_download_rounded, size: 18),
                label: const Text('Export Monthly Recap (.xlsx)', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMagenta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
