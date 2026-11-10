import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Fast2Screen extends StatefulWidget {
  final Map<String, int> fastItems;
  final Map<String, String> fastNotes;
  final Map<String, int> rewashItems;
  final Map<String, String> rewashNotes;

  const Fast2Screen({
    super.key,
    required this.fastItems,
    required this.fastNotes,
    required this.rewashItems,
    required this.rewashNotes,
  });

  @override
  State<Fast2Screen> createState() => _Fast2ScreenState();
}

class _Fast2ScreenState extends State<Fast2Screen>
    with TickerProviderStateMixin {
  late TextEditingController _handlerNameController;

  // Animation controllers
  AnimationController? _particleController;
  Animation<double>? _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _handlerNameController = TextEditingController();
    requestPermission();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController!, curve: Curves.linear),
    );

    _particleController!.repeat();
  }

  @override
  void dispose() {
    _particleController?.dispose();
    _handlerNameController.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Storage permission denied.");
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final handlerName = _handlerNameController.text.trim();

    if (handlerName.isEmpty) {
      _showSnackBar(
        'Please enter the handler\'s name before exporting.',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    try {
      final now = DateTime.now();
      final formattedDate =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

      final xls.Workbook workbook = xls.Workbook();
      final xls.Worksheet fastSheet = workbook.worksheets[0];
      fastSheet.name = 'FAST';
      final xls.Worksheet rewashSheet = workbook.worksheets.addWithName(
        'REWASH',
      );

      for (final sheet in [fastSheet, rewashSheet]) {
        sheet.getRangeByIndex(1, 1).setText('Item Name');
        sheet.getRangeByIndex(1, 2).setText('Quantity');
        sheet.getRangeByIndex(1, 3).setText('Notes');
        sheet.getRangeByIndex(1, 4).setText('Handler');
        sheet.getRangeByIndex(1, 5).setText('Date');
      }

      int fastRow = 2;
      widget.fastItems.forEach((item, count) {
        fastSheet.getRangeByIndex(fastRow, 1).setText(item);
        fastSheet.getRangeByIndex(fastRow, 2).setNumber(count.toDouble());
        fastSheet
            .getRangeByIndex(fastRow, 3)
            .setText(widget.fastNotes[item] ?? '');
        fastSheet.getRangeByIndex(fastRow, 4).setText(handlerName);
        fastSheet.getRangeByIndex(fastRow, 5).setText(formattedDate);
        fastRow++;
      });

      int rewashRow = 2;
      widget.rewashItems.forEach((item, count) {
        rewashSheet.getRangeByIndex(rewashRow, 1).setText(item);
        rewashSheet.getRangeByIndex(rewashRow, 2).setNumber(count.toDouble());
        rewashSheet
            .getRangeByIndex(rewashRow, 3)
            .setText(widget.rewashNotes[item] ?? '');
        rewashSheet.getRangeByIndex(rewashRow, 4).setText(handlerName);
        rewashSheet.getRangeByIndex(rewashRow, 5).setText(formattedDate);
        rewashRow++;
      });

      // Create a custom subdirectory: /storage/emulated/0/Download/laundry/test/
      final String subdirectoryPath =
          '/storage/emulated/0/Download/laundry/FAST/';
      final Directory subdirectory = Directory(subdirectoryPath);

      // Ensure the directory exists
      if (!await subdirectory.exists()) {
        await subdirectory.create(recursive: true);
      }

      // Full file path
      final String fileName =
          '${subdirectory.path}FAST_REWASH_${handlerName}_$formattedDate.xlsx';
      final File file = File(fileName);

      // Save the Excel file
      await file.writeAsBytes(await workbook.save());
      workbook.dispose();

      _showSnackBar(
        'Excel file exported successfully to Downloads/laundry/FAST/',
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      _showSnackBar(
        'Failed to export: ${e.toString()}',
        Colors.red,
        Icons.error,
      );
    }
  }

  void _showNotesDialog(
    String itemName,
    Map<String, String> notesMap,
    bool isRewash,
  ) async {
    final controller = TextEditingController(text: notesMap[itemName] ?? '');

    await showDialog(
      context: context,
      builder:
          (context) => Theme(
            data: Theme.of(
              context,
            ).copyWith(dialogBackgroundColor: Colors.transparent),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit Notes for $itemName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D1B69),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter additional notes',
                          hintStyle: TextStyle(
                            color: const Color(0xFF2D1B69).withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF900C46),
                                  const Color(0xFF7A0A3C),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF900C46,
                                  ).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  notesMap[itemName] = controller.text;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0B2E),
              Color(0xFF2D1B69),
              Color(0xFF900C46),
              Color(0xFFFF6B6B),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            if (_rotateAnimation != null)
              ...List.generate(
                12,
                (index) => AnimatedBuilder(
                  animation: _rotateAnimation!,
                  builder: (context, child) {
                    final angle =
                        (_rotateAnimation!.value * 2 * math.pi) + (index * 0.5);
                    final radius = 60 + (index * 15);
                    final x = screenWidth / 2 + radius * 0.7 * math.cos(angle);
                    final y = screenHeight / 2 + radius * 0.3 * math.sin(angle);

                    return Positioned(
                      left: x,
                      top: y,
                      child: Opacity(
                        opacity: 0.08 + (index % 3) * 0.02,
                        child: Container(
                          width: 2 + (index % 3),
                          height: 2 + (index % 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Export Data',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF900C46),
                                const Color(0xFF7A0A3C),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF900C46).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                            ),
                            onPressed: _exportToExcel,
                            tooltip: 'Export to Excel',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handler name input card
                          _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Handler Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _handlerNameController,
                                  'Enter Handler\'s Name',
                                  Icons.badge,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // FAST Items section
                          _buildSectionHeader('FAST Items', Icons.speed),
                          const SizedBox(height: 16),
                          _buildItemsList(
                            widget.fastItems,
                            widget.fastNotes,
                            false,
                          ),

                          const SizedBox(height: 32),

                          // REWASH Items section
                          _buildSectionHeader('RE-WASH Items', Icons.refresh),
                          const SizedBox(height: 16),
                          _buildItemsList(
                            widget.rewashItems,
                            widget.rewashNotes,
                            true,
                          ),

                          const SizedBox(height: 32),

                          // Export button
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF900C46),
                                    const Color(0xFF7A0A3C),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF900C46,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.file_download_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Export to Downloads',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                onPressed: _exportToExcel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D1B69),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF900C46)),
          labelStyle: TextStyle(
            color: const Color(0xFF2D1B69).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    Map<String, int> items,
    Map<String, String> notesMap,
    bool isRewash,
  ) {
    if (items.isEmpty) {
      return _buildGlassCard(
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No items to display',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          items.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildItemTile(entry.key, entry.value, notesMap, isRewash),
            );
          }).toList(),
    );
  }

  Widget _buildItemTile(
    String item,
    int count,
    Map<String, String> notesMap,
    bool isRewash,
  ) {
    final hasNotes = notesMap[item]?.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (hasNotes) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF900C46).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF900C46).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      notesMap[item]!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              // Quantity badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors:
                        hasNotes
                            ? [const Color(0xFF900C46), const Color(0xFF7A0A3C)]
                            : [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2),
                            ],
                  ),
                  boxShadow:
                      hasNotes
                          ? [
                            BoxShadow(
                              color: const Color(0xFF900C46).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color:
                        hasNotes ? Colors.white : Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Edit notes button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF900C46).withOpacity(0.8),
                      const Color(0xFF7A0A3C).withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF900C46).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      color: Colors.white,
                      onPressed:
                          () => _showNotesDialog(item, notesMap, isRewash),
                    ),
                    if (hasNotes)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
