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
      Colors.lightGreen,
      Brightness.light,
    ),
    'greenDarkTheme': generateThemeData(
      Colors.green,
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
      themeName: 'plumGradientDarkTheme',
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
      themeName: 'endlessGradientDarkTheme',
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
    'rainbowGradientLightTheme':
        generateThemeData(Colors.purple, Brightness.light, themeName: 'rainbowGradientLightTheme'),
    'rainbowGradientDarkTheme':
        generateThemeData(Colors.purple, Brightness.dark, themeName: 'rainbowGradientDarkTheme'),
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
    'rainbowGradientLightTheme': [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ],
    'rainbowGradientDarkTheme': [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ],
  };

  static Gradient gradientFromTheme(
    String themeName, {
    bool useSecondary = false,
    bool useTertiaryContainer = false,
    bool usePrimaryContainer = false,
    bool useSecondaryContainer = false,
  }) {
    return gradientColors.keys.contains(themeName)
        ? themeName.contains('rainbow')
            ? LinearGradient(colors: [
                AppTheme.gradientColors[themeName][0],
                AppTheme.gradientColors[themeName][1],
                AppTheme.gradientColors[themeName][2],
                AppTheme.gradientColors[themeName][3],
                AppTheme.gradientColors[themeName][4],
              ])
            : LinearGradient(colors: [
                AppTheme.gradientColors[themeName][0],
                AppTheme.gradientColors[themeName][1]
              ])
        : useSecondary
            ? LinearGradient(colors: [
                AppTheme.themes[themeName].colorScheme.secondary, //TODO: revert
                AppTheme.themes[themeName].colorScheme.secondary
              ])
            : usePrimaryContainer
                ? LinearGradient(colors: [
                    AppTheme.themes[themeName].colorScheme.primaryContainer,
                    AppTheme.themes[themeName].colorScheme.primaryContainer
                  ])
                : useSecondaryContainer
                    ? LinearGradient(colors: [
                        AppTheme.themes[themeName].colorScheme.secondaryContainer,
                        AppTheme.themes[themeName].colorScheme.secondaryContainer
                      ])
                    : useTertiaryContainer
                        ? LinearGradient(colors: [
                            AppTheme.themes[themeName].colorScheme.tertiaryContainer,
                            AppTheme.themes[themeName].colorScheme.tertiaryContainer
                          ])
                        : LinearGradient(colors: [
                            AppTheme.themes[themeName].colorScheme.primary,
                            AppTheme.themes[themeName].colorScheme.primary
                          ]);
  }

  static ThemeData generateThemeData(Color seedColor, Brightness brightness,
      {String themeName = ''}) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    if (themeName != '') {
      ColorScheme newColorScheme;
      if (themeName == 'plumGradientDarkTheme') {
        newColorScheme = colorScheme.copyWith(onPrimary: Color.fromARGB(255, 40, 1, 92));
      } else if (themeName.contains('endlessGradientDarkTheme')) {
        newColorScheme = colorScheme.copyWith(onPrimary: Color.fromARGB(255, 0, 20, 14));
      } else if (themeName.contains('rainbow')) {
        newColorScheme = colorScheme.copyWith(onPrimary: Colors.white);
      }
      return ThemeData.from(colorScheme: colorScheme, useMaterial3: true)
          .copyWith(
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            bottomSheetTheme: BottomSheetThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          )
          .copyWith(colorScheme: newColorScheme);
    }
    return ThemeData.from(colorScheme: colorScheme, useMaterial3: true).copyWith(
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static void addDynamicThemes(ColorScheme lightScheme, ColorScheme darkScheme) {
    try {
      AppTheme.themes['lightDynamic'] = ThemeData.from(
        colorScheme: lightScheme,
        useMaterial3: true,
      ).copyWith(
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
      AppTheme.themes['darkDynamic'] = ThemeData.from(
        colorScheme: darkScheme.copyWith(brightness: Brightness.dark),
        useMaterial3: true,
      ).copyWith(
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
    } catch (exception) {
      print(exception);
    }
  }
}
