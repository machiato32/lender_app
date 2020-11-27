import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//TODO: material.io template should be used...

class AppTheme {
  AppTheme._();

  static final Map<String, ThemeData> themes = {
    'amberLightTheme': generateThemeData(Colors.amber[700], Colors.amber[500], Brightness.light, Colors.white, Colors.amber[500]),
    'amberDarkTheme': generateThemeData(Colors.amber[600], Colors.amber[500], Brightness.dark, Colors.black, Colors.amber[500]),
    'greenLightTheme': generateThemeData(Colors.green, Colors.green[700], Brightness.light, Colors.white, Colors.green[700]),
    'greenDarkTheme': generateThemeData(Colors.green[400], Colors.green[300], Brightness.dark, Colors.white, Colors.green[300]),
    'pinkLightTheme': generateThemeData(Colors.purple[300], Colors.pink[300], Brightness.light, Colors.white, Colors.pink[300]),
    'pinkDarkTheme': generateThemeData(Colors.pink[300], Colors.pink[200], Brightness.dark, Colors.white, Colors.pink[200]),
    'seaBlueLightTheme': generateThemeData(Colors.blue[700], Colors.blue[900], Brightness.light, Colors.white, Colors.blue[900]),
    'seaBlueDarkTheme': generateThemeData(Colors.blue[400], Colors.blue[300], Brightness.dark, Colors.black, Colors.blue[300]),
    'roseannaLightTheme' : generateThemeData(Color.fromARGB(255, 255, 175, 189), Color.fromARGB(255, 255, 195, 160), Brightness.light, Colors.white, Color.fromARGB(255, 255, 175, 189)),
    'roseannaDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 175, 189), Color.fromARGB(255, 255, 195, 160), Brightness.dark, Colors.black, Color.fromARGB(255, 255, 175, 189)),
    'sexyBlueLightTheme' : generateThemeData(Color.fromARGB(255, 33, 147, 176), Color.fromARGB(255, 109, 213, 237), Brightness.light, Colors.white, Color.fromARGB(255, 33, 147, 176)),
    'sexyBlueDarkTheme' : generateThemeData(Color.fromARGB(255, 33, 147, 176), Color.fromARGB(255, 109, 213, 237), Brightness.dark, Colors.white, Color.fromARGB(255, 33, 147, 176)),
    'celestialLightTheme' : generateThemeData(Color.fromARGB(255, 195, 55, 100), Color.fromARGB(255, 29, 38, 113), Brightness.light, Colors.white, Color.fromARGB(255, 195, 55, 100)),
    'celestialDarkTheme' : generateThemeData(Color.fromARGB(255, 29, 38, 113), Color.fromARGB(255, 195, 55, 100), Brightness.dark, Colors.white, Color.fromARGB(255, 29, 38, 113)),
    'orangeLightTheme' : generateThemeData(Color.fromARGB(255, 255, 153, 102), Color.fromARGB(255, 255, 94, 98), Brightness.light, Colors.white, Color.fromARGB(255, 255, 153, 102)),
    'orangeDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 153, 102), Color.fromARGB(255, 255, 94, 98), Brightness.dark, Colors.white, Color.fromARGB(255, 255, 153, 102)),
    'endlessLightTheme' :generateThemeData(Color.fromARGB(255, 67, 206, 162), Color.fromARGB(255, 24, 90, 157), Brightness.light, Colors.white, Color.fromARGB(255, 67, 206, 162)),
  };



  static LinearGradient gradientFromTheme(ThemeData theme, {bool useSecondary=false}){
    return useSecondary?
      LinearGradient(
        colors: [theme.colorScheme.onPrimary, theme.colorScheme.secondary]
      )
      :
      theme.colorScheme.secondary==theme.colorScheme.onPrimary?
      LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary]
      )
      :
      LinearGradient(
          colors: [theme.colorScheme.onPrimary, theme.colorScheme.secondary]
      );
  }

  static ThemeData generateThemeData(Color primaryColor, Color secondaryColor, Brightness brightness, Color fontOnSecondaryColor, Color gradientColor){
    if(brightness==Brightness.light){
      return ThemeData(
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: fontOnSecondaryColor),
          ),
          brightness: Brightness.light,
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          scaffoldBackgroundColor: Colors.grey[200],
          canvasColor: Colors.grey[200],
          colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: secondaryColor,
              onPrimary: gradientColor,
              onSecondary: fontOnSecondaryColor,
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),
          textTheme: TextTheme(
            headline6: TextStyle(fontSize: 25, color: primaryColor),
            bodyText1: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
            ),
            bodyText2: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
            subtitle2: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
            button: TextStyle(fontSize: 20, color: Colors.white),
          ),
          dividerColor: Colors.grey[500]
      );
    }else{
      return ThemeData(
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            iconTheme: IconThemeData(color: fontOnSecondaryColor),
          ),
          brightness: Brightness.dark,
          canvasColor: Colors.grey[800],
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: primaryColor,
            secondary: secondaryColor,
            background: Colors.grey[500],
            onPrimary: gradientColor, //nem hasznalom
            //history icon
            onSecondary: fontOnSecondaryColor, //szovegek szine
            onBackground: Color.fromARGB(255, 25, 25, 25), //nem hasznalom
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
              color: secondaryColor,
            ),
            subtitle2: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
            button: TextStyle(
              fontSize: 20,
              color: fontOnSecondaryColor,
            ),
          ),
          dividerColor: Colors.grey[500]
      );
    }
  }
}

