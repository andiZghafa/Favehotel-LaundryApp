import 'dart:async';
import 'dart:math';
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

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen>
    with SingleTickerProviderStateMixin {
  static const String _prefPinKey = 'fave_hotel_pin';

  DateTime _selectedDate = DateTime.now();
  String? _unlockedPin;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _errorMessage;
  List<LinenLogEntry> _logs = [];

  // Tab selection: 0 = Ringkasan Per Item, 1 = Riwayat Log Harian
  int _selectedTabIndex = 0;
  String _itemSearchQuery = '';

  // Penalty / Rate Limiting State
  int _failedAttempts = 0;
  int _lockoutSecondsLeft = 0;
  Timer? _lockoutTimer;

  // Shake animation controller for wrong PIN penalty
  late AnimationController _shakeController;

  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadSavedPin();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
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

  void _startLockoutCountdown(int seconds) {
    setState(() {
      _lockoutSecondsLeft = seconds;
      _errorMessage =
          'Terlalu banyak percobaan salah. Akses dikunci sementara.';
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSecondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _lockoutSecondsLeft = 0;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _lockoutSecondsLeft--;
        });
      }
    });
  }

  Future<void> _unlockWithPin(String pin) async {
    if (_lockoutSecondsLeft > 0) return;

    final cleanPin = pin.trim();
    if (cleanPin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Valid check: Check against default PIN or query Supabase
    final bool isKnownPin = cleanPin == SupabaseService.defaultPin ||
        cleanPin.toLowerCase() == 'fave0925' ||
        cleanPin == '0925';

    final logs = await SupabaseService.fetchMonthlyLogs(
      pin: cleanPin,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    // If wrong PIN
    if (!isKnownPin && logs.isEmpty) {
      _failedAttempts++;
      _shakeController.forward(from: 0.0);

      if (_failedAttempts >= 3) {
        final penaltySecs = _failedAttempts >= 5 ? 60 : 30;
        _startLockoutCountdown(penaltySecs);
      } else {
        final remaining = 3 - _failedAttempts;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Passcode salah. Sisa kesempatan: $remaining kali sebelum terkunci.';
        });
      }
      return;
    }

    // Success! Reset penalties and save PIN
    _failedAttempts = 0;
    _lockoutTimer?.cancel();
    _lockoutSecondsLeft = 0;

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
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + delta,
        1,
      );
    });
    _fetchLogs();
  }

  Future<void> _handleExportExcel() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Belum ada log untuk bulan ini.'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
          backgroundColor: res.success
              ? AppColors.statusSuccess
              : AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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

  Map<String, Map<String, int>> get _aggregatedTableData {
    // Returns: { 'Item Name': { 'clean': X, 'rewash': Y, 'total': Z } }
    final Map<String, Map<String, int>> map = {};

    for (var log in _logs) {
      final isRewash = log.category == 'REWASH';
      log.items.forEach((item, count) {
        map.putIfAbsent(item, () => {'clean': 0, 'rewash': 0, 'total': 0});
        if (isRewash) {
          map[item]!['rewash'] = (map[item]!['rewash'] ?? 0) + count;
        } else {
          map[item]!['clean'] = (map[item]!['clean'] ?? 0) + count;
        }
        map[item]!['total'] = (map[item]!['total'] ?? 0) + count;
      });

      log.secondaryItems.forEach((item, count) {
        map.putIfAbsent(item, () => {'clean': 0, 'rewash': 0, 'total': 0});
        map[item]!['rewash'] = (map[item]!['rewash'] ?? 0) + count;
        map[item]!['total'] = (map[item]!['total'] ?? 0) + count;
      });
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
          // ── Top Navigation Bar with Explicit Hotel Location ──────────────
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
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Rekap Bulanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandMagentaLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'favehotel Padjajaran - Bogor',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandMagenta,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Housekeeping Laundry Audit & Monthly Master Log',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_unlockedPin != null)
                  IconButton(
                    tooltip: 'Kunci Kembali (Lock Records)',
                    icon: const Icon(
                      Icons.lock_open_rounded,
                      color: AppColors.brandMagenta,
                      size: 20,
                    ),
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
            child: _unlockedPin == null
                ? _buildPinEntryViewWithPenalty()
                : _buildUnlockedDashboard(monthLabel),
          ),
        ],
      ),
    );
  }

  // ── PIN Screen with Rate-Limiting Penalty & Shake Animation ───────────────
  Widget _buildPinEntryViewWithPenalty() {
    final bool isLocked = _lockoutSecondsLeft > 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double sineValue = sin(_shakeController.value * 4 * pi);
            final double offset =
                sineValue * 12 * (1.0 - _shakeController.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLocked
                    ? Colors.redAccent.withOpacity(0.4)
                    : AppColors.hairline,
              ),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? const Color(0x15EF4444)
                      : const Color(0x06000000),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock / Shield Icon
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFFFEE2E2)
                        : AppColors.brandMagentaLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLocked
                          ? Colors.redAccent.withOpacity(0.3)
                          : AppColors.brandMagenta.withOpacity(0.25),
                    ),
                  ),
                  child: Icon(
                    isLocked
                        ? Icons.lock_clock_rounded
                        : Icons.lock_outline_rounded,
                    color: isLocked ? Colors.redAccent : AppColors.brandMagenta,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Verifikasi Staf Housekeeping',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Data rekap bulanan favehotel Padjajaran Bogor dilindungi kode akses internal housekeeping.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),

                // Lockout Cooldown Banner
                if (isLocked) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Terkunci sementara: $_lockoutSecondsLeft detik',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Passcode Input (Alphanumeric, e.g. fave0925)
                TextField(
                  controller: _pinController,
                  enabled: !isLocked && !_isLoading,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  maxLength: 16,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: AppColors.brandMagenta,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Passcode Hotel',
                    hintStyle: const TextStyle(
                      letterSpacing: 1,
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    fillColor: isLocked
                        ? const Color(0xFFF1F5F9)
                        : AppColors.surfaceInput,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.brandMagenta,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: isLocked ? null : _unlockWithPin,
                ),

                if (_errorMessage != null && !isLocked) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 15,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 22),

                // Unlock Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLocked || _isLoading
                        ? null
                        : () => _unlockWithPin(_pinController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandMagenta,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.hairline,
                      disabledForegroundColor: AppColors.textMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLocked ? 'Akses Terkunci' : 'Buka Rekap Bulanan',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Unlocked Monthly Dashboard View ──────────────────────────────────────
  Widget _buildUnlockedDashboard(String monthLabel) {
    final tableData = _aggregatedTableData;
    final totalAll = _totalCleanPieces + _totalRewashPieces;
    final double rewashRate = totalAll > 0
        ? (_totalRewashPieces / totalAll * 100)
        : 0.0;

    final filteredItems = tableData.entries.where((e) {
      return e.key.toLowerCase().contains(_itemSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Month Switcher Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: () => _changeMonth(-1),
                tooltip: 'Bulan Sebelumnya',
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: AppColors.brandMagenta,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      monthLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: () => _changeMonth(1),
                tooltip: 'Bulan Selanjutnya',
              ),
            ],
          ),
        ),

        // 3 Executive KPI Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Linen Bersih Terlayani',
                  value: '$_totalCleanPieces pcs',
                  subtitle: 'Fren & Fast Linen',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.catFren,
                  bgColor: AppColors.catFrenBg,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'Linen Rewash / Defect',
                  value: '$_totalRewashPieces pcs',
                  subtitle: 'Tingkat Noda: ${rewashRate.toStringAsFixed(1)}%',
                  icon: Icons.autorenew_rounded,
                  color: AppColors.catRewash,
                  bgColor: AppColors.catRewashBg,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Sesi Handover',
                  value: '${_logs.length} kali',
                  subtitle: 'Input Staff Housekeeping',
                  icon: Icons.history_rounded,
                  color: AppColors.catFast,
                  bgColor: AppColors.catFastBg,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Segmented Control Tabs (Ringkasan Per Item vs Riwayat Sesi)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildSegmentTab(
                0,
                'Ringkasan Per Item (${tableData.length})',
                Icons.table_chart_outlined,
              ),
              const SizedBox(width: 10),
              _buildSegmentTab(
                1,
                'Riwayat Log Harian (${_logs.length})',
                Icons.list_alt_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tab Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandMagenta,
                  ),
                )
              : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.textMuted.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada log tercatat untuk $monthLabel',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Log otomatis masuk saat staf melakukan Export di aplikasi.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : _selectedTabIndex == 0
              ? _buildItemSummaryView(filteredItems, totalAll)
              : _buildDailyHistoryListView(),
        ),

        // Bottom Master Export CTA
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Master Spreadsheet favehotel Padjajaran (.xlsx)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Rangkuman total item + rincian riwayat lengkap ($monthLabel)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isExporting || _logs.isEmpty
                    ? null
                    : _handleExportExcel,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.file_download_rounded, size: 18),
                label: const Text(
                  'Export Rekap Bulanan (.xlsx)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMagenta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandMagenta : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.brandMagenta : AppColors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSummaryView(
    List<MapEntry<String, Map<String, int>>> items,
    int grandTotal,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      children: [
        // Item Search Filter Bar
        TextField(
          onChanged: (val) => setState(() => _itemSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari linen (misal: Duvet, Pillowcase)...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.hairline),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            children: [
              // Table Header Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfacePill,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Nama Linen',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Bersih',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.catFren,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rewash',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.catRewash,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Total',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ...items.map((entry) {
                final clean = entry.value['clean'] ?? 0;
                final rewash = entry.value['rewash'] ?? 0;
                final total = entry.value['total'] ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.hairline, width: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$clean',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$rewash',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: rewash > 0
                                ? AppColors.catRewash
                                : AppColors.textMuted,
                            fontWeight: rewash > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$total pcs',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandMagenta,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyHistoryListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        final dateStr = DateFormat('EEE, d MMM yyyy').format(log.createdAt);
        final timeStr = DateFormat('HH:mm').format(log.createdAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: log.category == 'REWASH'
                          ? AppColors.catRewashBg
                          : AppColors.catFrenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      log.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: log.category == 'REWASH'
                            ? AppColors.catRewash
                            : AppColors.brandMagenta,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$dateStr • $timeStr',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${log.totalPieces} pcs',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Petugas: ${log.handlerName}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: log.items.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePill,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
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
