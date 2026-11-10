import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_dialogs.dart';

class LinenCounterCard extends StatelessWidget {
  final String itemName;
  final int count;
  final String note;
  final bool isRewash;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<String> onNoteChanged;

  const LinenCounterCard({
    super.key,
    required this.itemName,
    required this.count,
    required this.note,
    this.isRewash = false,
    required this.onCountChanged,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCount = count > 0;
    final bool hasNote = note.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasCount
            ? AppColors.surfaceCardLight
            : AppColors.surfaceCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCount
              ? AppColors.coralAccent.withOpacity(0.5)
              : AppColors.surfaceGlassBorder,
          width: hasCount ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasCount
                ? AppColors.brandMagenta.withOpacity(0.2)
                : Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Item Name + Note Action
            Row(
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: hasCount ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Note Icon Button with badge indicator
                InkWell(
                  onTap: () async {
                    final res = await AppDialogs.showNotesDialog(
                      context: context,
                      itemName: itemName,
                      initialNote: note,
                      isRewash: isRewash,
                    );
                    if (res != null) {
                      onNoteChanged(res);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasNote
                          ? AppColors.coralAccent.withOpacity(0.2)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasNote
                            ? AppColors.coralAccent.withOpacity(0.8)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasNote ? Icons.sticky_note_2 : Icons.note_add_outlined,
                          size: 16,
                          color: hasNote ? AppColors.peachLight : AppColors.textMuted,
                        ),
                        if (hasNote) ...[
                          const SizedBox(width: 4),
                          const Text(
                            'Note',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.peachLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (hasNote) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.plumDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Row 2: Counter and Quick Add Chips
            Row(
              children: [
                // Quick chips: +1, +5, +10
                Wrap(
                  spacing: 6,
                  children: [1, 5, 10].map((step) {
                    return InkWell(
                      onTap: () => onCountChanged(count + step),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Text(
                          '+$step',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                // Stepper: [-] [Count] [+]
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInput,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceGlassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minus button
                      _CounterIconButton(
                        icon: Icons.remove,
                        onPressed: count > 0 ? () => onCountChanged(count - 1) : null,
                      ),

                      // Tappable count display
                      InkWell(
                        onTap: () async {
                          final res = await AppDialogs.showQuantityDialog(
                            context: context,
                            itemName: itemName,
                            initialValue: count,
                          );
                          if (res != null) {
                            onCountChanged(res);
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 44),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: AppMotion.quick,
                            transitionBuilder: (child, anim) {
                              return ScaleTransition(scale: anim, child: child);
                            },
                            child: Text(
                              '$count',
                              key: ValueKey<int>(count),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: hasCount ? AppColors.coralAccent : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Plus button
                      _CounterIconButton(
                        icon: Icons.add,
                        onPressed: () => onCountChanged(count + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? AppColors.textPrimary : AppColors.textMuted.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
