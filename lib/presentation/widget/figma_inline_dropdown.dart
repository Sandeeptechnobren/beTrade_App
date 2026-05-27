import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One option in a [FigmaInlineDropdown]. `trailing` shows on the right
/// of the item row — used by the MoMo-provider dropdown to render
/// brand logos.
class FigmaInlineDropdownItem<T> {
  final T value;
  final String label;
  final Widget? trailing;

  const FigmaInlineDropdownItem({
    required this.value,
    required this.label,
    this.trailing,
  });
}

/// Dropdown that expands **inline** below the trigger (pushes content
/// down) instead of opening Material's popup overlay. Matches the
/// Figma "Frame 2609865 + DropdownMenu / Menu" spec used across the
/// deposit / withdraw flows.
///
///   - Trigger: 62 tall, `#F4F4F5` bg, 16 radius, chevron rotates 180°
///     when open.
///   - Panel: white, 1px `#F4F4F5` border, 12 radius, soft shadow,
///     padding 4 around items.
///   - Items: 16/400, the selected item gets a `#F3E6FF` (light
///     purple) background with 6 radius.
///
/// Closes when the user taps any item, or taps the trigger again.
class FigmaInlineDropdown<T> extends StatefulWidget {
  final T? value;
  final String? hint;
  final List<FigmaInlineDropdownItem<T>> items;
  final ValueChanged<T> onChanged;

  const FigmaInlineDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  State<FigmaInlineDropdown<T>> createState() =>
      _FigmaInlineDropdownState<T>();
}

class _FigmaInlineDropdownState<T> extends State<FigmaInlineDropdown<T>> {
  static const Color _inputBg = Color(0xFFF4F4F5);
  static const Color _inputText = Color(0xFF09090B);
  static const Color _hintColor = Color(0xFFA1A1AA);
  static const Color _chevron = Color(0xFF1C274C);
  static const Color _panelBorder = Color(0xFFF4F4F5);
  static const Color _selectedBg = Color(0xFFF3E6FF);

  bool _isOpen = false;

  FigmaInlineDropdownItem<T>? get _selected {
    final v = widget.value;
    if (v == null) return null;
    if (v is String && v.isEmpty) return null;
    for (final item in widget.items) {
      if (item.value == v) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final showHint = selected == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Trigger ───────────────────────────────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Container(
            height: 62.h,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    showHint ? (widget.hint ?? '') : selected.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: showHint ? _hintColor : _inputText,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 24.sp,
                    color: _chevron,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ─── Inline panel ──────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _isOpen ? _buildPanel() : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _panelBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.items.map((item) {
          final isSelected = item.value == widget.value;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onChanged(item.value);
                setState(() => _isOpen = false);
              },
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? _selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: _inputText,
                        ),
                      ),
                    ),
                    if (item.trailing != null) item.trailing!,
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
