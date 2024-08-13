import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  Color bottomNavbarColor = const Color(0xFF77B0AA);
  Color qrcodeColor = const Color(0xFFE3FEF7);
  Color logoColor = const Color(0xFFE3FEF7);
  double buttonHeight = 60;
  EdgeInsetsGeometry snackbarMargin =
      const EdgeInsets.symmetric(horizontal: 10);
  ThemeData get themeData {
    ThemeData theme = ThemeData(
      appBarTheme: const AppBarTheme(
          color: Color(0xFF003C43),
          titleTextStyle: TextStyle(
            fontSize: 40,
            color: Color(0xFFE3FEF7),
          )
          // elevation: 0,
          ),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF003C43),
          showDragHandle: true,
          dragHandleColor: Color(0xFF77B0AA)),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Color(0xFFE3FEF7)),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFFE3FEF7),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFFE3FEF7),
        ),
        helperStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE3FEF7),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        prefixIconColor: const Color(0xFFE3FEF7),
        suffixIconColor: const Color(0xFFE3FEF7),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE3FEF7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE3FEF7),
          ),
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
          backgroundColor: Color(0xFF77B0AA),
          iconColor: Color(0xFFE3FEF7),
          collapsedBackgroundColor: Color(0xFF003C43)),
      listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: const Color(0xFF77B0AA),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE3FEF7),
            overflow: TextOverflow.ellipsis,
          ),
          subtitleTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFE3FEF7),
            overflow: TextOverflow.ellipsis,
          ),
          leadingAndTrailingTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE3FEF7),
            overflow: TextOverflow.ellipsis,
          ),
          iconColor: const Color(0xFFE3FEF7)),
      dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(
              const Color(0xFF77B0AA),
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFE3FEF7),
          ),
          inputDecorationTheme: InputDecorationTheme()),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF135D66),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE3FEF7)),
      dialogBackgroundColor: const Color(0xFF003C43),
      scaffoldBackgroundColor: const Color(0xFF003C43),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        showCloseIcon: true,
        // width: double.maxFinite * 0.9,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      primaryColorLight: const Color(0xFFE3FEF7),
      primaryColorDark: const Color(0xFF003C43),
      primaryColor: const Color(0xFF77B0AA),
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Color(0xFFE3FEF7),
        ),
        titleMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFFE3FEF7),
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE3FEF7),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFE3FEF7),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Color(0xFFE3FEF7),
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Color(0xFFE3FEF7),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(
            const Color(0xFFE3FEF7),
          ),
          side: MaterialStateProperty.all<BorderSide>(
            const BorderSide(
              color: Color(0xFFE3FEF7),
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          overlayColor: MaterialStateProperty.all(const Color(0xFF77B0AA)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(
            const Color(0xFFE3FEF7),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: const MaterialStatePropertyAll(Color(0xFF77B0AA)),
          overlayColor: MaterialStateProperty.all(const Color(0xFF77B0AA)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF77B0AA),
      ),
      scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(
            const Color(0xFF77B0AA),
          ),
          radius: const Radius.circular(50)),
    );
    return theme;
  }
}
