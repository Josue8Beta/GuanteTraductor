import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData miTema(BuildContext com) {
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.brown, // Color principal en tonos madera
      accentColor: Colors.amber, // Color de acento en tono cálido
      backgroundColor: Colors.brown[200], // Fondo en tono beige
      cardColor:
          const Color(0xFFF5F5DC), // Color de las tarjetas en tono madera
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      bodyLarge: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 24,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black, // Color del texto de los botones
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor:
            Colors.brown[300], // Color de fondo de los botones elevados
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black), // Color del borde
      ),
    ),
  );
}
