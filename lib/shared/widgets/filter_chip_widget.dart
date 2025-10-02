import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.fontSize,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? Theme.of(context).colorScheme.primary)
              : (unselectedColor ?? Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? (selectedColor ?? Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (selectedColor ?? Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.w,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : (textColor ??
                          Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : (textColor ??
                          Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7)),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.onSelectionChanged,
    this.selectedOption,
    this.icons,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.fontSize,
    this.alignment = MainAxisAlignment.start,
    this.scrollable = false,
  });
  final List<String> options;
  final String? selectedOption;
  final void Function(String) onSelectionChanged;
  final List<IconData>? icons;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final double? fontSize;
  final MainAxisAlignment alignment;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final chips = options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: FilterChipWidget(
          label: option,
          isSelected: selectedOption == option,
          onTap: () => onSelectionChanged(option),
          icon: icons != null && index < icons!.length ? icons![index] : null,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          textColor: textColor,
          fontSize: fontSize,
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }

    return Wrap(spacing: 8.w, runSpacing: 8.h, children: chips);
  }
}

class MultiSelectFilterChipGroup extends StatelessWidget {
  const MultiSelectFilterChipGroup({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
    this.icons,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.fontSize,
    this.scrollable = false,
    this.maxSelections,
  });
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onSelectionChanged;
  final List<IconData>? icons;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final double? fontSize;
  final bool scrollable;
  final int? maxSelections;

  void _handleSelection(String option) {
    final newSelection = List<String>.from(selectedOptions);

    if (newSelection.contains(option)) {
      newSelection.remove(option);
    } else {
      if (maxSelections == null || newSelection.length < maxSelections!) {
        newSelection.add(option);
      }
    }

    onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final chips = options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: FilterChipWidget(
          label: option,
          isSelected: selectedOptions.contains(option),
          onTap: () => _handleSelection(option),
          icon: icons != null && index < icons!.length ? icons![index] : null,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          textColor: textColor,
          fontSize: fontSize,
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }

    return Wrap(spacing: 8.w, runSpacing: 8.h, children: chips);
  }
}
