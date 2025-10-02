import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  // Screen dimensions
  static double get screenWidth => ScreenUtil().screenWidth;
  static double get screenHeight => ScreenUtil().screenHeight;
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // Responsive sizing
  static double width(double width) => width.w;
  static double height(double height) => height.h;
  static double fontSize(double fontSize) => fontSize.sp;
  static double radius(double radius) => radius.r;

  // Responsive spacing
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0).w,
      top: (top ?? vertical ?? all ?? 0).h,
      right: (right ?? horizontal ?? all ?? 0).w,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
    );
  }

  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0).w,
      top: (top ?? vertical ?? all ?? 0).h,
      right: (right ?? horizontal ?? all ?? 0).w,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
    );
  }

  // Device type checks
  static bool get isMobile => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  static bool get isDesktop => screenWidth >= 1200;

  // Orientation
  static bool get isPortrait => screenHeight > screenWidth;
  static bool get isLandscape => screenWidth > screenHeight;

  // Safe area
  static double get safeAreaTop => ScreenUtil().statusBarHeight;
  static double get safeAreaBottom => ScreenUtil().bottomBarHeight;

  // Text scaling
  static double getResponsiveFontSize(double fontSize) {
    if (isMobile) {
      return fontSize.sp;
    } else if (isTablet) {
      return (fontSize * 1.2).sp;
    } else {
      return (fontSize * 1.4).sp;
    }
  }

  // Responsive spacing based on device type
  static double getResponsiveSpacing(double spacing) {
    if (isMobile) {
      return spacing.w;
    } else if (isTablet) {
      return (spacing * 1.3).w;
    } else {
      return (spacing * 1.6).w;
    }
  }

  // Responsive icon size
  static double getResponsiveIconSize(double iconSize) {
    if (isMobile) {
      return iconSize.w;
    } else if (isTablet) {
      return (iconSize * 1.2).w;
    } else {
      return (iconSize * 1.4).w;
    }
  }

  // Responsive button height
  static double getResponsiveButtonHeight(double height) {
    if (isMobile) {
      return height.h;
    } else if (isTablet) {
      return (height * 1.1).h;
    } else {
      return (height * 1.2).h;
    }
  }

  // Responsive card padding
  static EdgeInsets getResponsiveCardPadding() {
    if (isMobile) {
      return EdgeInsets.all(16.w);
    } else if (isTablet) {
      return EdgeInsets.all(20.w);
    } else {
      return EdgeInsets.all(24.w);
    }
  }

  // Responsive grid columns
  static int getResponsiveGridColumns() {
    if (isMobile) {
      return isPortrait ? 2 : 3;
    } else if (isTablet) {
      return isPortrait ? 3 : 4;
    } else {
      return isPortrait ? 4 : 6;
    }
  }

  // Responsive list tile height
  static double getResponsiveListTileHeight() {
    if (isMobile) {
      return 60.h;
    } else if (isTablet) {
      return 70.h;
    } else {
      return 80.h;
    }
  }
}
