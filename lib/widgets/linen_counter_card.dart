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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasCount
              ? AppColors.brandMagenta.withOpacity(0.35)
              : AppColors.hairline,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasCount
                ? AppColors.brandMagenta.withOpacity(0.06)
                : const Color(0x04000000),
            blurRadius: hasCount ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Item Name & Note Trigger
          Row(
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: hasCount ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Note trigger pill
              Material(
                color: Colors.transparent,
                child: InkWell(
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
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasNote
                          ? AppColors.coralDim
                          : AppColors.surfacePill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasNote
                            ? AppColors.coralAccent.withOpacity(0.3)
                            : AppColors.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasNote ? Icons.sticky_note_2_rounded : Icons.edit_note_rounded,
                          size: 15,
                          color: hasNote ? AppColors.coralAccent : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasNote ? 'Note added' : (isRewash ? '+ Stain note' : '+ Note'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: hasNote ? AppColors.coralAccent : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (hasNote) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.coralDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.coralAccent.withOpacity(0.2)),
              ),
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.coralAccent,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Row 2: Quick-Add Chips & Stepper Control
          Row(
            children: [
              // Quick-add pill chips (+1, +5, +10)
              Wrap(
                spacing: 6,
                children: [1, 5, 10].map((step) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onCountChanged(count + step),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfacePill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.hairline),
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
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Stepper: [-] [Count] [+] with Emil Kowalski press feedback
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfacePill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                      icon: Icons.remove_rounded,
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
                        constraints: const BoxConstraints(minWidth: 46),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: AppMotion.quick,
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Text(
                            '$count',
                            key: ValueKey<int>(count),
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: hasCount
                                  ? AppColors.brandMagenta
                                  : AppColors.textMuted,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),

                    _StepButton(
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

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({
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
                : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
