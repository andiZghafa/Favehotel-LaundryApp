import 'package:flutter/material.dart';
import 'package:laundry_app/page/fast2.dart';
import 'dart:math' as math;

class Return2Screen extends StatefulWidget {
  final Map<String, int> fastItems;

  const Return2Screen({Key? key, required this.fastItems}) : super(key: key);

  @override
  State<Return2Screen> createState() => _Return2ScreenState();
}

class _Return2ScreenState extends State<Return2Screen>
    with TickerProviderStateMixin {
  late Map<String, int> _rewashItems;
  late Map<String, String> _rewashNotes;

  AnimationController? _particleController;
  Animation<double>? _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _rewashItems = {for (var entry in widget.fastItems.entries) entry.key: 0};
    _rewashNotes = {for (var key in widget.fastItems.keys) key: ''};

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController!, curve: Curves.linear),
    );

    _particleController!.repeat();
  }

  void _updateItemCount(String item, int count) {
    setState(() {
      _rewashItems[item] = count;
    });
  }

  void _updateItemNote(String item, String note) {
    setState(() {
      _rewashNotes[item] = note;
    });
  }

  Future<void> _showNumberInputDialog(String itemName, int currentValue) async {
    final TextEditingController controller = TextEditingController(
      text: currentValue.toString(),
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit $itemName',
              style: const TextStyle(
                color: Color(0xFF2D1B69),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
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
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Color(0xFF2D1B69),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF2D1B69)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF900C46), Color(0xFF7A0A3C)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final newValue =
                        int.tryParse(controller.text) ?? currentValue;
                    _updateItemCount(itemName, newValue);
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showNoteInputDialog(String itemName, String currentNote) async {
    final TextEditingController controller = TextEditingController(
      text: currentNote,
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Note for $itemName',
              style: const TextStyle(
                color: Color(0xFF2D1B69),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
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
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Color(0xFF2D1B69),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter note',
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF2D1B69)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF900C46), Color(0xFF7A0A3C)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _updateItemNote(itemName, controller.text.trim());
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Fast2Screen(
              fastItems: widget.fastItems,
              rewashItems: _rewashItems,
              fastNotes:
                  {}, // This was not passed in return.dart, ensure consistency if needed
              rewashNotes: _rewashNotes,
            ),
      ),
    );
  }

  void _navigateToPreviousPage() {
    Navigator.pop(context);
  }

  void _addNewItem() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Add New Item',
              style: TextStyle(
                color: Color(0xFF2D1B69),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
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
                  color: Color(0xFF2D1B69),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter item name',
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF2D1B69)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF900C46), Color(0xFF7A0A3C)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final newItem = controller.text.trim();
                    if (newItem.isNotEmpty &&
                        !_rewashItems.containsKey(newItem)) {
                      setState(() {
                        _rewashItems[newItem] = 0;
                        _rewashNotes[newItem] = '';
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
                  // Custom App Bar with logo
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
                    child: Column(
                      children: [
                        // Logo section
                        Center(
                          child: Image.asset(
                            'assets/IKON.png',
                            height: 80,
                            width: 120,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => const Text(
                                  'favehotel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        const Text(
                          'RE-WASH',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Items list card
                          _buildGlassCard(
                            child: Column(
                              children: [
                                // Section title
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.local_laundry_service,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Re-wash Items',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Items list
                                if (_rewashItems.isNotEmpty)
                                  ..._rewashItems.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildItemRow(
                                        itemName: entry.key,
                                        currentCount: entry.value,
                                        currentNote:
                                            _rewashNotes[entry.key] ?? '',
                                        onCountChanged:
                                            (count) => _updateItemCount(
                                              entry.key,
                                              count,
                                            ),
                                        onNoteChanged:
                                            (note) => _updateItemNote(
                                              entry.key,
                                              note,
                                            ),
                                      ),
                                    );
                                  }).toList()
                                else
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No items added yet',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // Add item button
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF900C46),
                                        Color(0xFF7A0A3C),
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
                                  child: ElevatedButton.icon(
                                    onPressed: _addNewItem,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add Item',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom navigation buttons
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
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _navigateToPreviousPage,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF900C46),
                            ),
                            label: const Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFF900C46),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),

                        // Next button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF900C46), Color(0xFF7A0A3C)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF900C46).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _navigateToNextPage,
                            label: const Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildItemRow({
    required String itemName,
    required int currentCount,
    required String currentNote, // Added currentNote
    required Function(int) onCountChanged,
    required Function(String) onNoteChanged, // Added onNoteChanged
  }) {
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
                  itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (currentNote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    currentNote,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      currentCount > 0
                          ? const Color(0xFF900C46).withOpacity(0.9)
                          : Colors.grey.withOpacity(0.3),
                  boxShadow:
                      currentCount > 0
                          ? [
                            BoxShadow(
                              color: const Color(0xFF900C46).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      currentCount > 0
                          ? () => onCountChanged(currentCount - 1)
                          : null,
                  color: Colors.white,
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Count display (tappable)
              GestureDetector(
                onTap: () => _showNumberInputDialog(itemName, currentCount),
                onLongPress: () => _showNoteInputDialog(itemName, currentNote),
                child: Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentCount.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Increase button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF900C46).withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF900C46).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onCountChanged(currentCount + 1),
                  color: Colors.white,
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _particleController?.dispose();
    super.dispose();
  }
}
