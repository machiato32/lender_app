import 'package:csocsort_szamla/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppTheme {
  AppTheme._();

  static final Map<String, ThemeData> themes = {
    'pinkLightTheme': generateThemeData(
      Colors.purple[300],
      Brightness.light,
    ),
    'pinkDarkTheme': generateThemeData(
      Colors.pink[300],
      Brightness.dark,
    ),
    'seaBlueLightTheme': generateThemeData(
      Colors.blue[700],
      Brightness.light,
    ),
    'seaBlueDarkTheme': generateThemeData(
      Colors.blue[400],
      Brightness.dark,
    ),
    'greenLightTheme': generateThemeData(
      Colors.green,
      Brightness.light,
    ),
    'greenDarkTheme': generateThemeData(
      Colors.green[400],
      Brightness.dark,
    ),
    'amberLightTheme': generateThemeData(
      Colors.amber[700],
      Brightness.light,
    ),
    'amberDarkTheme': generateThemeData(
      Colors.amber[600],
      Brightness.dark,
    ),
    'roseannaGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 255, 175, 189),
      Brightness.light,
    ),
    'roseannaGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 255, 175, 189),
      Brightness.dark,
    ),
    'passionateBedGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 255, 117, 140),
      Brightness.light,
    ),
    'passionateBedGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 255, 117, 140),
      Brightness.dark,
    ),
    'plumGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 152, 108, 240),
      Brightness.light,
    ),
    'plumGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 152, 108, 240),
      Brightness.dark,
    ),
    'celestialLightTheme': generateThemeData(
      Color.fromARGB(255, 195, 55, 100),
      Brightness.light,
    ),
    'celestialDarkTheme': generateThemeData(
      Color.fromARGB(255, 29, 38, 113),
      Brightness.dark,
    ),
    'sexyBlueGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 33, 147, 176),
      Brightness.light,
    ),
    'sexyBlueGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 33, 147, 176),
      Brightness.dark,
    ),
    'endlessGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 67, 206, 162),
      Brightness.light,
    ),
    'endlessGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 67, 206, 162),
      Brightness.dark,
    ),
    'greenGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 24, 219, 56),
      Brightness.light,
    ),
    'greenGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 24, 219, 56),
      Brightness.dark,
    ),
    'yellowGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 255, 208, 0),
      Brightness.light,
    ),
    'yellowGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 255, 208, 0),
      Brightness.dark,
    ),
    'orangeGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 255, 153, 102),
      Brightness.light,
    ),
    'orangeGradientDarkTheme': generateThemeData(
      Color.fromARGB(255, 255, 153, 102),
      Brightness.dark,
    ),
    'blackGradientLightTheme': generateThemeData(
      Color.fromARGB(255, 67, 67, 67),
      Brightness.light,
    ),
    'whiteGradientDarkTheme':
        generateThemeData(Color.fromARGB(255, 253, 251, 251), Brightness.dark),
    // 'rainbowGradientLightTheme': generateThemeData(Colors.purple, Colors.red,
    //     Brightness.light, Colors.white, Colors.purple,
    //     secondGradientColor: Colors.blue,
    //     thirdGradientColor: Colors.green,
    //     fourthGradientColor: Colors.yellow,
    //     fifthGradientColor: Colors.orange),
    // 'rainbowGradientDarkTheme': generateThemeData(
    //     Colors.purple, Colors.red, Brightness.dark, Colors.white, Colors.purple,
    //     secondGradientColor: Colors.blue,
    //     thirdGradientColor: Colors.green,
    //     fourthGradientColor: Colors.yellow,
    //     fifthGradientColor: Colors.orange),
  };

  static Map<String, List<Color>> gradientColors = {
    'orangeGradientLightTheme': [
      Color.fromARGB(255, 255, 153, 102),
      Color.fromARGB(255, 255, 94, 98),
    ],
    'orangeGradientDarkTheme': [
      Color.fromARGB(255, 255, 153, 102),
      Color.fromARGB(255, 255, 94, 98),
    ],
    'whiteGradientDarkTheme': [
      Color.fromARGB(255, 235, 237, 238),
      Color.fromARGB(255, 253, 251, 251),
    ],
    'blackGradientLightTheme': [
      Color.fromARGB(255, 67, 67, 67),
      Color.fromARGB(255, 0, 0, 0),
    ],
    'yellowGradientLightTheme': [
      Color.fromARGB(255, 255, 208, 0),
      Color.fromARGB(255, 255, 179, 0),
    ],
    'yellowGradientDarkTheme': [
      Color.fromARGB(255, 255, 208, 0),
      Color.fromARGB(255, 255, 179, 0),
    ],
    'roseannaGradientLightTheme': [
      Color.fromARGB(255, 255, 175, 189),
      Color.fromARGB(255, 255, 195, 160),
    ],
    'roseannaGradientDarkTheme': [
      Color.fromARGB(255, 255, 175, 189),
      Color.fromARGB(255, 255, 195, 160),
    ],
    'passionateBedGradientLightTheme': [
      Color.fromARGB(255, 255, 117, 140),
      Color.fromARGB(255, 255, 148, 192),
    ],
    'passionateBedGradientDarkTheme': [
      Color.fromARGB(255, 255, 117, 140),
      Color.fromARGB(255, 255, 148, 192),
    ],
    'plumGradientLightTheme': [
      Color.fromARGB(255, 152, 108, 240),
      Color.fromARGB(255, 118, 75, 162),
    ],
    'plumGradientDarkTheme': [
      Color.fromARGB(255, 152, 108, 240),
      Color.fromARGB(255, 126, 95, 158),
    ],
    'sexyBlueGradientLightTheme': [
      Color.fromARGB(255, 33, 147, 176),
      Color.fromARGB(255, 109, 213, 237),
    ],
    'sexyBlueGradientDarkTheme': [
      Color.fromARGB(255, 33, 147, 176),
      Color.fromARGB(255, 109, 213, 237),
    ],
    'endlessGradientLightTheme': [
      Color.fromARGB(255, 67, 206, 162),
      Color.fromARGB(255, 24, 90, 157),
    ],
    'endlessGradientDarkTheme': [
      Color.fromARGB(255, 67, 206, 162),
      Color.fromARGB(255, 24, 90, 157),
    ],
    'greenGradientLightTheme': [
      Color.fromARGB(255, 24, 219, 56),
      Color.fromARGB(255, 62, 173, 81),
    ],
    'greenGradientDarkTheme': [
      Color.fromARGB(255, 24, 219, 56),
      Color.fromARGB(255, 62, 173, 81),
    ],
  };

  static Gradient gradientFromTheme(String themeName,
      {bool useSecondary = false}) {
    // print(themeName);
    return gradientColors.keys.contains(themeName)
        ? LinearGradient(colors: [
            AppTheme.gradientColors[themeName][0],
            AppTheme.gradientColors[themeName][1]
          ])
        : useSecondary
            ? LinearGradient(colors: [
                AppTheme.themes[themeName].colorScheme.secondary,
                AppTheme.themes[themeName].colorScheme.secondary
              ])
            : LinearGradient(colors: [
                AppTheme.themes[themeName].colorScheme.primary,
                AppTheme.themes[themeName].colorScheme.primary
              ]);
  }

  static ThemeData generateThemeData(Color seedColor, Brightness brightness) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData.from(colorScheme: colorScheme, useMaterial3: true)
        .copyWith(
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    );
    // if (brightness == Brightness.light) {
    //   return ThemeData(
    //     appBarTheme: AppBarTheme(
    //         iconTheme: IconThemeData(color: fontOnSecondaryColor),
    //         elevation: 0),
    //     brightness: Brightness.light,
    //     primaryColor: primaryColor,
    //     accentColor: secondaryColor,
    //     scaffoldBackgroundColor:
    //         cardColor == null ? Colors.grey[200] : cardColor,
    //     canvasColor: Colors.grey[200],
    //     colorScheme: ColorScheme.light(
    //         primary: primaryColor,
    //         secondary: secondaryColor,
    //         onSecondary: fontOnSecondaryColor,
    //         surface: Colors.grey[400],
    //         onSurface: Colors.grey[100],
    //         onPrimary: gradientColor,
    //         onBackground: Colors.pink,
    //         error: secondGradientColor ?? Colors.transparent,
    //         primaryVariant: thirdGradientColor ?? Colors.transparent,
    //         onError: fourthGradientColor ?? Colors.transparent,
    //         secondaryVariant: fifthGradientColor ?? Colors.transparent),
    //     cardTheme: CardTheme(
    //       color: Colors.white,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(15),
    //       ),
    //       elevation: 0,
    //       margin: EdgeInsets.symmetric(vertical: 7, horizontal: 12),
    //     ),
    //     dialogTheme: DialogTheme(
    //       backgroundColor: Colors.white,
    //       shape:
    //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    //     ),
    //     buttonTheme: ButtonThemeData(
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(15))),
    //     textTheme: TextTheme(
    //       headline6: TextStyle(fontSize: 25, color: primaryColor),
    //       bodyText1: TextStyle(
    //         fontSize: 20,
    //         color: Colors.grey[700],
    //       ),
    //       bodyText2: TextStyle(
    //         fontSize: 20,
    //         fontWeight: FontWeight.bold,
    //         color: secondaryColor,
    //       ),
    //       subtitle2: TextStyle(
    //         fontSize: 15,
    //         color: Colors.grey[700],
    //       ),
    //       button: TextStyle(fontSize: 20, color: Colors.white),
    //     ),
    //     dividerColor: Colors.grey[500],
    //     inputDecorationTheme: InputDecorationTheme(
    //       hintStyle: TextStyle(color: Colors.grey[400]),
    //     ),
    //   );
    // } else {
    //   return ThemeData(
    //     appBarTheme: AppBarTheme(
    //       brightness: Brightness.dark,
    //       iconTheme: IconThemeData(color: fontOnSecondaryColor),
    //     ),
    //     brightness: Brightness.dark,
    //     canvasColor: Colors.grey[800],
    //     primaryColor: primaryColor,
    //     accentColor: secondaryColor,
    //     scaffoldBackgroundColor: Colors.black,
    //     colorScheme: ColorScheme.dark(
    //         primary: primaryColor,
    //         secondary: secondaryColor,
    //         background: Colors.grey[500],
    //         onPrimary: gradientColor, //nem hasznalom
    //         //history icon
    //         onSecondary: fontOnSecondaryColor, //szovegek szine
    //         onBackground: Color.fromARGB(255, 50, 50, 50), //nem hasznalom
    //         //box decoration
    //         surface: Colors.grey[400],
    //         //history date
    //         onSurface: Color.fromARGB(255, 40, 40, 40),
    //         error: secondGradientColor ?? Colors.transparent,
    //         primaryVariant: thirdGradientColor ?? Colors.transparent,
    //         onError: fourthGradientColor ?? Colors.transparent,
    //         secondaryVariant: fifthGradientColor ?? Colors.transparent),
    //     dialogTheme: DialogTheme(
    //         shape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    //         backgroundColor: cardColor ?? Color.fromARGB(255, 50, 50, 50)),
    //     cardTheme: CardTheme(
    //       color: cardColor ?? Color.fromARGB(255, 25, 25, 25),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(15),
    //       ),
    //       margin: EdgeInsets.symmetric(vertical: 7, horizontal: 12),
    //     ),
    //     buttonTheme: ButtonThemeData(
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(15))),
    //     textTheme: TextTheme(
    //       headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
    //       bodyText1: TextStyle(
    //         color: Colors.white,
    //       ),
    //       bodyText2: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         color: secondaryColor,
    //       ),
    //       subtitle2: TextStyle(
    //         color: Colors.white,
    //       ),
    //       button: TextStyle(
    //         color: fontOnSecondaryColor,
    //       ),
    //     ),
    //     dividerColor: Colors.grey[500],
    //     bottomSheetTheme: BottomSheetThemeData(
    //       backgroundColor: cardColor,
    //     ),
    //   );
    // }
  }

  static ThemeData getDateRangePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: Theme.of(context).colorScheme.primary,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            onSurface: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[800]
                : Theme.of(context).colorScheme.onSecondary,
            onPrimary: Colors.white,
            surface: Theme.of(context).colorScheme.primary,
          ),
      scaffoldBackgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      textTheme: Theme.of(context).textTheme.copyWith(
            bodyText2: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.normal),
            headline5: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            headline4: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
    );
  }

  static void addDynamicThemes(
      ColorScheme lightScheme, ColorScheme darkScheme) {
    try {
      AppTheme.themes['lightDynamic'] = ThemeData.from(
        colorScheme: lightScheme,
        useMaterial3: true,
      ).copyWith(
        cardTheme: CardTheme(
          elevation: 0,
          color: ElevationOverlay.applySurfaceTint(
              lightScheme.surface, lightScheme.surfaceTint, 1),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      );
      AppTheme.themes['darkDynamic'] = ThemeData.from(
        colorScheme: darkScheme.copyWith(brightness: Brightness.dark),
        useMaterial3: true,
      ).copyWith(
        cardTheme: CardTheme(
          elevation: 0,
          color: ElevationOverlay.applySurfaceTint(
              darkScheme.surface, darkScheme.surfaceTint, 1),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      );
    } catch (exception) {
      print(exception);
    }
  }
}
