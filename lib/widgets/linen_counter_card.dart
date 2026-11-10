import 'dart:ui' show FontFeature;
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

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.easeSmoothOut,
      margin: const EdgeInsets.only(bottom: 10),
      // Concentric border radius: outer 18px, padding 14px, inner controls 10px
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: hasCount
            ? AppColors.surfaceCardLight
            : AppColors.surfaceCard.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasCount
              ? AppColors.coralAccent.withOpacity(0.45)
              : Colors.white.withOpacity(0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(hasCount ? 0.24 : 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                    fontSize: 15.5,
                    fontWeight: hasCount ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.15,
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasNote
                        ? AppColors.coralAccent.withOpacity(0.18)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasNote
                          ? AppColors.coralAccent.withOpacity(0.55)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasNote ? Icons.sticky_note_2_outlined : Icons.edit_note_rounded,
                        size: 16,
                        color: hasNote ? AppColors.peachLight : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hasNote ? 'Edit note' : (isRewash ? 'Stain note' : 'Note'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: hasNote ? AppColors.peachLight : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (hasNote) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.plumDark.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Row 2: Quick Add Chips + Stepper
          Row(
            children: [
              // Quick chips: +1, +5, +10
              Wrap(
                spacing: 6,
                children: [1, 5, 10].map((step) {
                  return InkWell(
                    onTap: () => onCountChanged(count + step),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Text(
                        '+$step',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFeatures: [FontFeature.tabularFigures()],
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CounterIconButton(
                      icon: Icons.remove_rounded,
                      onPressed: count > 0 ? () => onCountChanged(count - 1) : null,
                    ),

                    // Tappable count display with tabular numerals
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: hasCount
                                  ? AppColors.coralAccent
                                  : AppColors.textMuted,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),

                    _CounterIconButton(
                      icon: Icons.add_rounded,
                      onPressed: () => onCountChanged(count + 1),
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
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? AppColors.textPrimary
                : AppColors.textMuted.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}
