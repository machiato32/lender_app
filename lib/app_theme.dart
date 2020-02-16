import 'package:flutter/material.dart';

class AppTheme{
  AppTheme._();
  static final Map<String, ThemeData> lightThemes = {'amberLightTheme':amberLightTheme, 'greenLightTheme':greenLightTheme, 'pinkLightTheme':pinkLightTheme, 'seaBlueLightTheme':seaBlueLightTheme};
  static final Map<String, ThemeData> darkThemes = {'amberDarkTheme':amberDarkTheme, 'greenDarkTheme':greenDarkTheme, 'pinkDarkTheme':pinkDarkTheme, 'seaBlueDarkTheme':seaBlueDarkTheme};

  static final ThemeData greenLightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.green,
    ),
    primaryColor: Colors.green,
    accentColor: Colors.green[700],
    scaffoldBackgroundColor: Colors.grey[200],
    canvasColor: Colors.grey[200],
    colorScheme: ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.green[700],
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      surface: Colors.grey[400],
      onSurface: Colors.grey[300]
    ),
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.green
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.grey[700],
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.white
      ),
    ),
  );
  static final ThemeData greenDarkTheme = ThemeData(
    appBarTheme: AppBarTheme(
        color: Colors.grey[900],
        textTheme: TextTheme(
            title: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        actionsIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white)
    ),
    canvasColor: Colors.grey[800],
    primaryColor: Colors.green[700],
    accentColor: Colors.green[700],
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.light(
      primary: Colors.grey[200],
      secondary: Colors.green[700],
      onPrimary: Colors.black, //history icon
      onSecondary: Colors.grey[400], //icons in button
      onBackground: Colors.grey[800], //box decoration
      surface: Colors.grey[400], //history date
      onSurface: Colors.grey[800], //box shadow
    ),
    dividerColor: Colors.white,
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.grey[200]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.grey[400]
      ),
    ),
  );
  static final ThemeData amberLightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.amber[700],
    ),
    primaryColor: Colors.amber[700],
    accentColor: Colors.amber[400],
    scaffoldBackgroundColor: Colors.grey[200],
    canvasColor: Colors.grey[200],
    colorScheme: ColorScheme.light(
        primary: Colors.amber[700],
        secondary: Colors.amber[400],
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: Colors.grey[400],
        onSurface: Colors.grey[300]
    ),
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.amber[700]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.grey[700],
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.amber[400],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.white
      ),
    ),
  );
  static final ThemeData amberDarkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      textTheme: TextTheme(
        title: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
      ),
      actionsIconTheme: IconThemeData(color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white)
    ),
    canvasColor: Colors.grey[800],
    primaryColor: Colors.amber[400],
    accentColor: Colors.amber[400],
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.light(
        primary: Colors.grey[200],
        secondary: Colors.amber[400],
        onPrimary: Colors.black, //history icon
        onSecondary: Colors.grey[700], //icons in button
        onBackground: Colors.grey[800], //box decoration
        surface: Colors.grey[400], //history date
        onSurface: Colors.grey[800], //box shadow
    ),
    dividerColor: Colors.white,
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.grey[200]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.amber[400],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.grey[700]
      ),
    ),
  );
  static final ThemeData pinkDarkTheme = ThemeData(
    appBarTheme: AppBarTheme(
        color: Colors.grey[900],
        textTheme: TextTheme(
            title: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        actionsIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white)
    ),
    canvasColor: Colors.grey[800],
    primaryColor: Colors.pink[300],
    accentColor: Colors.pink[300],
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.light(
      primary: Colors.grey[200],
      secondary: Colors.pink[300],
      onPrimary: Colors.black, //history icon
      onSecondary: Colors.grey[700], //icons in button
      onBackground: Colors.grey[800], //box decoration
      surface: Colors.grey[400], //history date
      onSurface: Colors.grey[800], //box shadow
    ),
    dividerColor: Colors.white,
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.grey[200]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.pink[300],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.grey[700]
      ),
    ),
  );
  static final ThemeData pinkLightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.purple[300],
    ),
    primaryColor: Colors.purple[300],
    accentColor: Colors.pink[300],
    scaffoldBackgroundColor: Colors.grey[200],
    canvasColor: Colors.grey[200],
    colorScheme: ColorScheme.light(
        primary: Colors.purple[300],
        secondary: Colors.pink[300],
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: Colors.grey[400],
        onSurface: Colors.grey[300]
    ),
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.purple[300]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.grey[700],
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.pink[300],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.white
      ),
    ),
  );
  static final ThemeData seaBlueDarkTheme = ThemeData(
    appBarTheme: AppBarTheme(
        color: Colors.grey[900],
        textTheme: TextTheme(
            title: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        actionsIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white)
    ),
    canvasColor: Colors.grey[800],
    primaryColor: Colors.blue[700],
    accentColor: Colors.blue[700],
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.light(
      primary: Colors.grey[200],
      secondary: Colors.blue[900],
      onPrimary: Colors.black, //history icon
      onSecondary: Colors.grey[500], //icons in button
      onBackground: Colors.grey[800], //box decoration
      surface: Colors.grey[400], //history date
      onSurface: Colors.grey[800], //box shadow
    ),
    dividerColor: Colors.white,
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.grey[200]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.grey[500]
      ),
    ),
  );
  static final ThemeData seaBlueLightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.blue[700],
    ),
    primaryColor: Colors.blue[700],
    accentColor: Colors.blue[900],
    scaffoldBackgroundColor: Colors.grey[200],
    canvasColor: Colors.grey[200],
    colorScheme: ColorScheme.light(
        primary: Colors.blue[700],
        secondary: Colors.blue[900],
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: Colors.grey[400],
        onSurface: Colors.grey[300]
    ),
    textTheme: TextTheme(
      title: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.blue[700]
      ),
      body2: TextStyle(
        fontSize: 20,
        color: Colors.grey[700],
      ),
      body1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
      button: TextStyle(
          fontSize: 20,
          color: Colors.white
      ),
    ),
  );
}