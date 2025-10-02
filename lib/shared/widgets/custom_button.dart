import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.isLoading = false,
    this.enabled = true,
    this.animationDuration,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final double? borderWidth;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool isLoading;
  final bool enabled;
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !isLoading && onPressed != null;

    Widget button = Container(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      margin: margin,
      decoration: BoxDecoration(
        gradient: isEnabled ? gradient : null,
        color: isEnabled
            ? (gradient == null
                  ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
                  : null)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
            : null,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color:
                      (backgroundColor ?? Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          child: Container(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? textColor ?? Colors.white,
                    size: iconSize ?? 20.w,
                  ),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isEnabled
                          ? (textColor ??
                                Theme.of(context).colorScheme.onPrimary)
                          : Theme.of(context).colorScheme.outline,
                      fontSize: fontSize ?? 16.sp,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (animationDuration != null) {
      return FadeInUp(duration: animationDuration!, child: button);
    }

    return button;
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.borderColor,
    this.borderWidth,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final double? borderWidth;
  final bool isLoading;
  final bool enabled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !isLoading && onPressed != null;

    Widget button = Container(
      width: size ?? 48.w,
      height: size ?? 48.h,
      margin: margin,
      decoration: BoxDecoration(
        gradient: isEnabled ? gradient : null,
        color: isEnabled
            ? (gradient == null
                  ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
                  : null)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
            : null,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color:
                      (backgroundColor ?? Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          child: Container(
            padding: padding ?? EdgeInsets.all(8.w),
            child: isLoading
                ? SizedBox(
                    width: iconSize ?? 24.w,
                    height: iconSize ?? 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        iconColor ?? Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isEnabled
                        ? (iconColor ?? Theme.of(context).colorScheme.onPrimary)
                        : Theme.of(context).colorScheme.outline,
                    size: iconSize ?? 24.w,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }

    return button;
  }
}

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderWidth,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.isLoading = false,
    this.enabled = true,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !isLoading && onPressed != null;
    final Color effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.primary;
    final Color effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: Border.all(
          color: isEnabled
              ? effectiveBorderColor
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: borderWidth ?? 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          child: Container(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveTextColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? effectiveTextColor,
                    size: iconSize ?? 20.w,
                  ),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isEnabled
                          ? effectiveTextColor
                          : Colors.grey.shade600,
                      fontSize: fontSize ?? 16.sp,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
