import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoAppTheme {
  // iOS Color Scheme
  static const Color primaryBlue = CupertinoColors.systemBlue;
  static const Color primaryGreen = CupertinoColors.systemGreen;
  static const Color primaryRed = CupertinoColors.systemRed;
  static const Color primaryOrange = CupertinoColors.systemOrange;
  static const Color backgroundLight = CupertinoColors.systemGroupedBackground;
  static const Color backgroundDark = CupertinoColors.black;
  
  // Cupertino Theme cho App "Con"
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      primaryColor: primaryBlue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: CupertinoColors.label,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: primaryBlue,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          color: CupertinoColors.label,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          color: CupertinoColors.label,
        ),
      ),
    );
  }
  
  // Cupertino Theme cho App "Cha Mẹ" (High Contrast, Large Text)
  static CupertinoThemeData get elderTheme {
    return const CupertinoThemeData(
      primaryColor: primaryBlue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 24,
          color: CupertinoColors.label,
          fontWeight: FontWeight.w500,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
        ),
      ),
    );
  }
  
  // iOS Style Card
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // iOS Style Button
  static BoxDecoration get buttonDecoration {
    return BoxDecoration(
      color: primaryBlue,
      borderRadius: BorderRadius.circular(12),
    );
  }
  
  // iOS Style List Tile
  static Widget buildListTile({
    required String title,
    required String? subtitle,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return CupertinoListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel,
              ),
            )
          : null,
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}





