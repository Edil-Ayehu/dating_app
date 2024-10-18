import 'package:dating_app/export.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.pink,
      elevation: 0,
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodySmall: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.pink[700],
      elevation: 0,
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodySmall: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.8),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
