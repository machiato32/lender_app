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

  };

  // static final ThemeData greenLightTheme = ThemeData(
  //     brightness: Brightness.light,
  //     primaryColor: Colors.green,
  //     accentColor: Colors.green[700],
  //     scaffoldBackgroundColor: Colors.grey[200],
  //     canvasColor: Colors.grey[200],
  //     colorScheme: ColorScheme.light(
  //         primary: Colors.green,
  //         secondary: Colors.green[700],
  //         onPrimary: Colors.white,
  //         onSecondary: Colors.white,
  //         onBackground: Colors.white,
  //         surface: Colors.grey[400],
  //         onSurface: Colors.grey[300]),
  //     cardTheme: CardTheme(
  //       color: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(3),
  //       ),
  //       elevation: 1,
  //     ),
  //     buttonTheme: ButtonThemeData(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  //     textTheme: TextTheme(
  //       headline6: TextStyle(fontSize: 25, color: Colors.green),
  //       bodyText1: TextStyle(
  //         fontSize: 20,
  //         color: Colors.grey[700],
  //       ),
  //       bodyText2: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.green[700],
  //       ),
  //       subtitle2: TextStyle(
  //         fontSize: 15,
  //         color: Colors.grey[700],
  //       ),
  //       button: TextStyle(fontSize: 20, color: Colors.white),
  //     ),
  //     dividerColor: Colors.grey[500]
  // );
  // static final ThemeData greenDarkTheme = ThemeData(
  //     appBarTheme: AppBarTheme(brightness: Brightness.dark),
  //     brightness: Brightness.dark,
  //     canvasColor: Colors.grey[800],
  //     primaryColor: Colors.green[400],
  //     accentColor: Colors.green[300],
  //     scaffoldBackgroundColor: Colors.black,
  //     colorScheme: ColorScheme.dark(
  //       primary: Colors.green[400],
  //       secondary: Colors.green[300],
  //       onPrimary: Colors.black,
  //       //history icon
  //       onSecondary: Colors.black,
  //       onBackground: Color.fromARGB(255, 25, 25, 25),
  //       //box decoration
  //       surface: Colors.grey[400],
  //       //history date
  //       onSurface: Colors.grey[700],
  //     ),
  //     cardTheme: CardTheme(
  //       color: Color.fromARGB(255, 25, 25, 25),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       ),
  //       elevation: 5,
  //     ),
  //     buttonTheme: ButtonThemeData(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  //     textTheme: TextTheme(
  //       headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
  //       bodyText1: TextStyle(
  //         fontSize: 20,
  //         color: Colors.white,
  //       ),
  //       bodyText2: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.green[700],
  //       ),
  //       subtitle2: TextStyle(
  //         fontSize: 15,
  //         color: Colors.white,
  //       ),
  //       button: TextStyle(
  //         fontSize: 20,
  //         color: Colors.black,
  //       ),
  //     ),
  //     dividerColor: Colors.grey[500]
  // );
//   static final ThemeData amberLightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Colors.amber[700],
//       accentColor: Colors.amber[500],
//       scaffoldBackgroundColor: Colors.grey[200],
//       canvasColor: Colors.grey[200],
//       colorScheme: ColorScheme.light(
//           primary: Colors.amber[700],
//           secondary: Colors.amber[500],
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onBackground: Colors.white,
//           surface: Colors.grey[400],
//           onSurface: Colors.grey[300]),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.amber[700]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.grey[700],
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.amber[500],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.grey[700],
//         ),
//         button: TextStyle(fontSize: 20, color: Colors.white),
//       ),
//       cardTheme: CardTheme(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 1,
//       ),
//       dividerColor: Colors.grey[500]);
//   static final ThemeData amberDarkTheme = ThemeData(
//       appBarTheme: AppBarTheme(
//         brightness: Brightness.dark,
//       ),
//       brightness: Brightness.dark,
//       canvasColor: Colors.grey[800],
//       primaryColor: Colors.amber[600],
//       accentColor: Colors.amber[500],
//       scaffoldBackgroundColor: Colors.black,
//       colorScheme: ColorScheme.dark(
//         primary: Colors.amber[600],
//         secondary: Colors.amber[500],
//         background: Colors.grey[500],
//         onPrimary: Colors.black,
//         //history icon
//         onSecondary: Color.fromARGB(255, 25, 25, 25),
//         //icons in button
//         onBackground: Color.fromARGB(255, 25, 25, 25),
//         //box decoration
//         surface: Colors.grey[400],
//         //history date
//         onSurface: Colors.grey[700],
//       ),
//       cardTheme: CardTheme(
//         color: Color.fromARGB(255, 25, 25, 25),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 5,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.white,
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.amber[500],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.white,
//         ),
//         button: TextStyle(fontSize: 20, color: Color.fromARGB(255, 25, 25, 25)),
//       ),
//       dividerColor: Colors.grey[500]);
//   static final ThemeData pinkDarkTheme = ThemeData(
//       appBarTheme: AppBarTheme(brightness: Brightness.dark),
//       brightness: Brightness.dark,
//       canvasColor: Colors.grey[800],
//       primaryColor: Colors.pink[300],
//       accentColor: Colors.pink[200],
//       scaffoldBackgroundColor: Colors.black,
//       colorScheme: ColorScheme.dark(
//         primary: Colors.pink[300],
//         secondary: Colors.pink[200],
//         background: Colors.grey[500],
//         onPrimary: Colors.black,
//         //history icon
//         onSecondary: Colors.white,
//         onBackground: Color.fromARGB(255, 25, 25, 25),
//         //box decoration
//         surface: Colors.grey[400],
//         //history date
//         onSurface: Colors.grey[700], //box shadow
//       ),
//       cardTheme: CardTheme(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
//         color: Color.fromARGB(255, 25, 25, 25),
//         elevation: 1,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.white,
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.pink[300],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.white,
//         ),
//         button: TextStyle(
//             fontSize: 20,
// //          color: Color.fromARGB(255, 25, 25, 25),
//             color: Colors.white),
//       ),
//       dividerColor: Colors.grey[500]
//   );
//   static final ThemeData pinkLightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Colors.purple[300],
//       accentColor: Colors.pink[300],
//       scaffoldBackgroundColor: Colors.grey[200],
//       canvasColor: Colors.grey[200],
//       colorScheme: ColorScheme.light(
//           primary: Colors.purple[300],
//           secondary: Colors.pink[300],
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onBackground: Colors.white,
//           surface: Colors.grey[400],
//           onSurface: Colors.grey[300]),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       cardTheme: CardTheme(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 1,
//       ),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.purple[300]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.grey[700],
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.pink[300],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.grey[700],
//         ),
//         button: TextStyle(fontSize: 20, color: Colors.white),
//       ),
//       dividerColor: Colors.grey[500]);
//   static final ThemeData seaBlueDarkTheme = ThemeData(
//       appBarTheme: AppBarTheme(brightness: Brightness.dark),
//       brightness: Brightness.dark,
//       canvasColor: Colors.grey[800],
//       primaryColor: Colors.blue[400],
//       accentColor: Colors.blue[300],
//       scaffoldBackgroundColor: Colors.black,
//       colorScheme: ColorScheme.dark(
//         primary: Colors.blue[400],
//         secondary: Colors.blue[300],
//         background: Colors.grey[500],
//         onPrimary: Colors.black, //nem hasznalom
//         //history icon
//         onSecondary: Colors.black, //szovegek szine
//         onBackground: Color.fromARGB(255, 25, 25, 25), //nem hasznalom
//         //box decoration
//         surface: Colors.grey[400],
//         //history date
//         onSurface: Colors.grey[700],
//       ),
//       cardTheme: CardTheme(
//         color: Color.fromARGB(255, 25, 25, 25),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 5,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.white,
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue[800],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.white,
//         ),
//         button: TextStyle(
//           fontSize: 20,
//           color: Colors.black,
//         ),
//       ),
//       dividerColor: Colors.grey[500]
//   );
//   static final ThemeData seaBlueLightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Colors.blue[700],
//       accentColor: Colors.blue[900],
//       scaffoldBackgroundColor: Colors.grey[200],
//       canvasColor: Colors.grey[200],
//       colorScheme: ColorScheme.light(
//           primary: Colors.blue[700],
//           secondary: Colors.blue[900],
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onBackground: Colors.white,
//           surface: Colors.grey[400],
//           onSurface: Colors.grey[300]),
//       cardTheme: CardTheme(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 1,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.blue[700]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.grey[700],
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue[900],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.grey[700],
//         ),
//         button: TextStyle(fontSize: 20, color: Colors.white),
//       ),
//       dividerColor: Colors.grey[500]
//   );
//   static final ThemeData roseannaLightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Color.fromARGB(255, 255, 175, 189),
//       accentColor: Color.fromARGB(255, 255, 195, 160),
//       scaffoldBackgroundColor: Colors.grey[200],
//       canvasColor: Colors.grey[200],
//       colorScheme: ColorScheme.light(
//           primary: Color.fromARGB(255, 255, 175, 189),
//           secondary: Color.fromARGB(255, 255, 195, 160),
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onBackground: Colors.white,
//           surface: Colors.grey[400],
//           onSurface: Colors.grey[300]),
//       cardTheme: CardTheme(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
//         elevation: 1,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.green),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.grey[700],
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.green[700],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.grey[700],
//         ),
//         button: TextStyle(fontSize: 20, color: Colors.white),
//       ),
//       dividerColor: Colors.grey[500]
//   );
//   static final ThemeData sexyBlueLightTheme = ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Color.fromARGB(255, 33, 147, 176),
//       accentColor: Color.fromARGB(255, 109, 213, 237),
//       scaffoldBackgroundColor: Colors.grey[200],
//       canvasColor: Colors.grey[200],
//       colorScheme: ColorScheme.light(
//           primary: Color.fromARGB(255, 33, 147, 176),
//           secondary: Color.fromARGB(255, 109, 213, 237),
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onBackground: Colors.white,
//           surface: Colors.grey[400],
//           onSurface: Colors.grey[300]),
//       cardTheme: CardTheme(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(3),
//         ),
//         elevation: 1,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.green),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.grey[700],
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.green[700],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.grey[700],
//         ),
//         button: TextStyle(fontSize: 20, color: Colors.white),
//       ),
//       dividerColor: Colors.grey[500]
//   );
//   static final ThemeData sexyBlueDarkTheme = ThemeData(
//       appBarTheme: AppBarTheme(brightness: Brightness.dark),
//       brightness: Brightness.dark,
//       canvasColor: Colors.grey[800],
//       primaryColor: Color.fromARGB(255, 33, 147, 176),
//       accentColor: Color.fromARGB(255, 109, 213, 237),
//       scaffoldBackgroundColor: Colors.black,
//       colorScheme: ColorScheme.dark(
//         primary: Color.fromARGB(255, 33, 147, 176),
//         secondary: Color.fromARGB(255, 109, 213, 237),
//         background: Colors.grey[500],
//         onPrimary: Colors.black,
//         //history icon
//         onSecondary: Colors.black,
//         onBackground: Color.fromARGB(255, 25, 25, 25),
//         //box decoration
//         surface: Colors.grey[400],
//         //history date
//         onSurface: Colors.grey[700],
//       ),
//       cardTheme: CardTheme(
//         color: Color.fromARGB(255, 25, 25, 25),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
// //          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
//         elevation: 5,
//       ),
//       buttonTheme: ButtonThemeData(
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//       textTheme: TextTheme(
//         headline6: TextStyle(fontSize: 25, color: Colors.grey[200]),
//         bodyText1: TextStyle(
//           fontSize: 20,
//           color: Colors.white,
//         ),
//         bodyText2: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue[800],
//         ),
//         subtitle2: TextStyle(
//           fontSize: 15,
//           color: Colors.white,
//         ),
//         button: TextStyle(
//           fontSize: 20,
//           color: Colors.black,
//         ),
//       ),
//       dividerColor: Colors.grey[500]
//   );

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

