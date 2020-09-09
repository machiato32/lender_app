import 'package:flutter/material.dart';

//TODO: material.io template should be used...

class AppTheme {
  AppTheme._();

  static final Map<String, ThemeData> themes = {
    'amberLightTheme': amberLightTheme,
    'amberDarkTheme': amberDarkTheme,
    'greenLightTheme': greenLightTheme,
    'greenDarkTheme': greenDarkTheme,
    'pinkLightTheme': pinkLightTheme,
    'pinkDarkTheme': pinkDarkTheme,
    'seaBlueLightTheme': seaBlueLightTheme,
    'seaBlueDarkTheme': blueDarkTheme
  };

  static final ThemeData greenLightTheme = ThemeData(
      brightness: Brightness.light,
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
          onSurface: Colors.grey[300]),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        elevation: 1,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.green),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.grey[700],
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
        ),
        button: TextStyle(fontSize: 20, color: Colors.white),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData greenDarkTheme = ThemeData(
      appBarTheme: AppBarTheme(brightness: Brightness.dark),
      brightness: Brightness.dark,
      canvasColor: Colors.grey[800],
      primaryColor: Colors.green[400],
      accentColor: Colors.green[300],
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: Colors.green[400],
        secondary: Colors.green[300],
        onPrimary: Colors.black,
        //history icon
        onSecondary: Colors.black,
        onBackground: Color.fromARGB(255, 25, 25, 25),
        //box decoration
        surface: Colors.grey[400],
        //history date
        onSurface: Colors.grey[700],
      ),
      cardTheme: CardTheme(
        color: Color.fromARGB(255, 25, 25, 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 5,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        button: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData amberLightTheme = ThemeData(
//    appBarTheme: AppBarTheme(
//      color: Colors.amber[700],
//    ),
      brightness: Brightness.light,
      primaryColor: Colors.amber[700],
      accentColor: Colors.amber[500],
      scaffoldBackgroundColor: Colors.grey[200],
      canvasColor: Colors.grey[200],
      colorScheme: ColorScheme.light(
          primary: Colors.amber[700],
          secondary: Colors.amber[500],
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          surface: Colors.grey[400],
          onSurface: Colors.grey[300]),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.amber[700]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.grey[700],
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amber[500],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
        ),
        button: TextStyle(fontSize: 20, color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
//          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
        elevation: 1,
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData amberDarkTheme = ThemeData(
      appBarTheme: AppBarTheme(
        //color: Colors.grey[900],
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      canvasColor: Colors.grey[800],
      primaryColor: Colors.amber[600],
      accentColor: Colors.amber[500],
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: Colors.amber[600],
        secondary: Colors.amber[500],
        background: Colors.grey[500],
        onPrimary: Colors.black,
        //history icon
        onSecondary: Color.fromARGB(255, 25, 25, 25),
        //icons in button
        onBackground: Color.fromARGB(255, 25, 25, 25),
        //box decoration
        surface: Colors.grey[400],
        //history date
        onSurface: Colors.grey[700],
      ),
      cardTheme: CardTheme(
        color: Color.fromARGB(255, 25, 25, 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
//          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
        elevation: 5,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amber[500],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        button: TextStyle(fontSize: 20, color: Color.fromARGB(255, 25, 25, 25)),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData pinkDarkTheme = ThemeData(
      appBarTheme: AppBarTheme(brightness: Brightness.dark),
      brightness: Brightness.dark,
      canvasColor: Colors.grey[800],
      primaryColor: Colors.pink[300],
      accentColor: Colors.pink[200],
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: Colors.pink[300],
        secondary: Colors.pink[200],
        background: Colors.grey[500],
        onPrimary: Colors.black,
        //history icon
        onSecondary: Colors.white,
        onBackground: Color.fromARGB(255, 25, 25, 25),
        //box decoration
        surface: Colors.grey[400],
        //history date
        onSurface: Colors.grey[700], //box shadow
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        color: Color.fromARGB(255, 25, 25, 25),
        elevation: 1,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink[300],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        button: TextStyle(
            fontSize: 20,
//          color: Color.fromARGB(255, 25, 25, 25),
            color: Colors.white),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData pinkLightTheme = ThemeData(
      brightness: Brightness.light,
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
          onSurface: Colors.grey[300]),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
//          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
        elevation: 1,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.purple[300]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.grey[700],
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink[300],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
        ),
        button: TextStyle(fontSize: 20, color: Colors.white),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData blueDarkTheme = ThemeData(
      appBarTheme: AppBarTheme(brightness: Brightness.dark),
      brightness: Brightness.dark,
      canvasColor: Colors.grey[800],
      primaryColor: Colors.blue[400],
      accentColor: Colors.blue[300],
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue[400],
        secondary: Colors.blue[300],
        background: Colors.grey[500],
        onPrimary: Colors.black,
        //history icon
        onSecondary: Colors.black,
        onBackground: Color.fromARGB(255, 25, 25, 25),
        //box decoration
        surface: Colors.grey[400],
        //history date
        onSurface: Colors.grey[700],
      ),
      cardTheme: CardTheme(
        color: Color.fromARGB(255, 25, 25, 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
//          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
        elevation: 5,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        button: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      dividerColor: Colors.grey[500]);
  static final ThemeData seaBlueLightTheme = ThemeData(
      brightness: Brightness.light,
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
          onSurface: Colors.grey[300]),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
//          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
        elevation: 1,
      ),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 25, color: Colors.blue[700]),
        bodyText1: TextStyle(
          fontSize: 20,
          color: Colors.grey[700],
        ),
        bodyText2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
        subtitle2: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
        ),
        button: TextStyle(fontSize: 20, color: Colors.white),
      ),
      dividerColor: Colors.grey[500]);
}
