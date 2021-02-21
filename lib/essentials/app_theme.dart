import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//TODO: material.io template should be used...

class AppTheme {
  AppTheme._();

  static final Map<String, ThemeData> themes = {
    'pinkLightTheme': generateThemeData(Colors.purple[300], Colors.pink[300], Brightness.light, Colors.white, Colors.pink[300]),
    'pinkDarkTheme': generateThemeData(Colors.pink[300], Colors.pink[200], Brightness.dark, Colors.white, Colors.pink[200]),
    'seaBlueLightTheme': generateThemeData(Colors.blue[700], Colors.blue[900], Brightness.light, Colors.white, Colors.blue[900]),
    'seaBlueDarkTheme': generateThemeData(Colors.blue[400], Colors.blue[300], Brightness.dark, Colors.white, Colors.blue[300]),
    'greenLightTheme': generateThemeData(Colors.green, Colors.green[700], Brightness.light, Colors.white, Colors.green[700]),
    'greenDarkTheme': generateThemeData(Colors.green[400], Colors.green[300], Brightness.dark, Colors.white, Colors.green[300]),
    'amberLightTheme': generateThemeData(Colors.amber[700], Colors.amber[500], Brightness.light, Colors.white, Colors.amber[500]),
    'amberDarkTheme': generateThemeData(Colors.amber[600], Colors.amber[500], Brightness.dark, Colors.black, Colors.amber[500]),
    'roseannaGradientLightTheme' : generateThemeData(Color.fromARGB(255, 255, 175, 189), Color.fromARGB(255, 255, 195, 160), Brightness.light, Colors.white, Color.fromARGB(255, 255, 175, 189)),
    'roseannaGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 175, 189), Color.fromARGB(255, 255, 195, 160), Brightness.dark, Colors.white, Color.fromARGB(255, 255, 175, 189)),
    'passionateBedGradientLightTheme' : generateThemeData(Color.fromARGB(255, 255, 117, 140), Color.fromARGB(255, 255, 148, 192), Brightness.light, Colors.white, Color.fromARGB(255, 255, 117, 140)),
    'passionateBedGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 117, 140), Color.fromARGB(255, 255, 148, 192), Brightness.dark, Colors.white, Color.fromARGB(255, 255, 117, 140)),
    'plumGradientLightTheme' : generateThemeData(Color.fromARGB(255, 152, 108, 240), Color.fromARGB(255, 118, 75, 162), Brightness.light, Colors.white, Color.fromARGB(255, 152, 108, 240)),
    'plumGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 152, 108, 240), Color.fromARGB(255, 118, 75, 162), Brightness.dark, Colors.white, Color.fromARGB(255, 152, 108, 240)),
    'celestialGradientLightTheme' : generateThemeData(Color.fromARGB(255, 195, 55, 100), Color.fromARGB(255, 29, 38, 113), Brightness.light, Colors.white, Color.fromARGB(255, 195, 55, 100)),
    'celestialGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 29, 38, 113), Color.fromARGB(255, 195, 55, 100), Brightness.dark, Colors.white, Color.fromARGB(255, 29, 38, 113)),
    'sexyBlueGradientLightTheme' : generateThemeData(Color.fromARGB(255, 33, 147, 176), Color.fromARGB(255, 109, 213, 237), Brightness.light, Colors.white, Color.fromARGB(255, 33, 147, 176)),
    'sexyBlueGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 33, 147, 176), Color.fromARGB(255, 109, 213, 237), Brightness.dark, Colors.white, Color.fromARGB(255, 33, 147, 176)),
    'endlessGradientLightTheme' : generateThemeData(Color.fromARGB(255, 67, 206, 162), Color.fromARGB(255, 24, 90, 157), Brightness.light, Colors.white, Color.fromARGB(255, 67, 206, 162)),
    'endlessGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 67, 206, 162), Color.fromARGB(255, 24, 90, 157), Brightness.dark, Colors.white, Color.fromARGB(255, 67, 206, 162)),
    'greenGradientLightTheme' : generateThemeData(Color.fromARGB(255, 24, 219, 56), Color.fromARGB(255, 62, 173, 81), Brightness.light, Colors.white, Color.fromARGB(255, 24, 219, 56)),
    'greenGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 24, 219, 56), Color.fromARGB(255, 62, 173, 81), Brightness.dark, Colors.white, Color.fromARGB(255, 24, 219, 56)),
    'yellowGradientLightTheme' : generateThemeData(Color.fromARGB(255, 255, 208, 0), Color.fromARGB(255, 255, 179, 0), Brightness.light, Colors.white, Color.fromARGB(255, 255, 208, 0)),
    'yellowGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 208, 0), Color.fromARGB(255, 255, 179, 0), Brightness.dark, Colors.black, Color.fromARGB(255, 255, 208, 0)),
    'orangeGradientLightTheme' : generateThemeData(Color.fromARGB(255, 255, 153, 102), Color.fromARGB(255, 255, 94, 98), Brightness.light, Colors.white, Color.fromARGB(255, 255, 153, 102)),
    'orangeGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 255, 153, 102), Color.fromARGB(255, 255, 94, 98), Brightness.dark, Colors.white, Color.fromARGB(255, 255, 153, 102)),
    'blackGradientLightTheme' : generateThemeData(Color.fromARGB(255, 67, 67, 67), Color.fromARGB(255, 0, 0, 0), Brightness.light, Colors.white, Color.fromARGB(255, 67, 67, 67)),
    'whiteGradientDarkTheme' : generateThemeData(Color.fromARGB(255, 253, 251, 251), Color.fromARGB(255, 235, 237, 238), Brightness.dark, Colors.black, Color.fromARGB(255, 253, 251, 251)),

    'rainbowGradientLightTheme' : generateThemeData(Colors.purple, Colors.red, Brightness.light, Colors.white, Colors.purple, secondGradientColor: Colors.blue, thirdGradientColor: Colors.green, fourthGradientColor: Colors.yellow, fifthGradientColor: Colors.orange),
    'rainbowGradientDarkTheme' : generateThemeData(Colors.purple, Colors.red, Brightness.dark, Colors.white, Colors.purple, secondGradientColor: Colors.blue, thirdGradientColor: Colors.green, fourthGradientColor: Colors.yellow, fifthGradientColor: Colors.orange),
  };



  static Gradient gradientFromTheme(ThemeData theme, {bool useSecondary=false}){
    return
      theme.colorScheme.error==Colors.transparent?
        useSecondary?
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
        )
      :LinearGradient(
        stops: [0.1, 0.25, 0.45, 0.6, 0.75, 0.9],
        colors: [theme.colorScheme.onPrimary, theme.colorScheme.error, theme.colorScheme.primaryVariant, theme.colorScheme.onError, theme.colorScheme.secondaryVariant, theme.colorScheme.secondary]
      )
    ;
  }

  static ThemeData generateThemeData(Color primaryColor, Color secondaryColor, Brightness brightness, Color fontOnSecondaryColor, Color gradientColor, {Color secondGradientColor, Color thirdGradientColor, Color fourthGradientColor, Color fifthGradientColor}){
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
            onSecondary: fontOnSecondaryColor,
            surface: Colors.grey[400],
            onSurface: Colors.grey[300],
            onPrimary: gradientColor,
            onBackground: Colors.pink,
            error: secondGradientColor??Colors.transparent,
            primaryVariant: thirdGradientColor??Colors.transparent,
            onError: fourthGradientColor??Colors.transparent,
            secondaryVariant: fifthGradientColor??Colors.transparent
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.all(5),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
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
            onBackground: Color.fromARGB(255, 50, 50, 50), //nem hasznalom
            //box decoration
            surface: Colors.grey[400],
            //history date
            onSurface: Colors.grey[700],
            error: secondGradientColor??Colors.transparent,
            primaryVariant: thirdGradientColor??Colors.transparent,
            onError: fourthGradientColor??Colors.transparent,
            secondaryVariant: fifthGradientColor??Colors.transparent
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            backgroundColor: Color.fromARGB(255, 50, 50, 50)
          ),
          cardTheme: CardTheme(
            color: Color.fromARGB(255, 25, 25, 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.all(5),
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

