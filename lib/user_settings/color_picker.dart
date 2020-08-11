import 'package:flutter/material.dart';
import 'package:csocsort_szamla/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:csocsort_szamla/app_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPicker extends StatefulWidget {
  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {

  List<Widget> _getColors(){
    return AppTheme.themes.entries.map((entry){
      return ColorElement(theme: entry.value, themeName: entry.key,);
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Card(

      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Text('Témaváltás', style: Theme.of(context).textTheme.headline6,)),
            SizedBox(height: 10),
            Container(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: _getColors(),
              ),
            )
//            Wrap(
//              spacing: 10,
//              children: _getLightColors(),
//            ),
//            SizedBox(height: 10),
//            Wrap(
//              spacing: 10,
//              children: _getDarkColors(),
//            ),
          ],

        ),
      ),
    );
  }
}


class ColorElement extends StatefulWidget {
  final ThemeData theme;
  final String themeName;
  const ColorElement({this.theme, this.themeName});
  @override
  _ColorElementState createState() => _ColorElementState();
}

class _ColorElementState extends State<ColorElement> {
  Future<SharedPreferences> _getPrefs() async{
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: (){
            Provider.of<AppStateNotifier>(context, listen: false).updateTheme(widget.themeName);
            _getPrefs().then((_prefs){
              _prefs.setString('theme', widget.themeName);
            });
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (widget.themeName==Provider.of<AppStateNotifier>(context, listen: false).themeName)?Colors.grey:Colors.transparent,
              shape: BoxShape.circle
          ),

            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.secondary,
                border: Border.all(color: widget.theme.scaffoldBackgroundColor, width: 10),
                shape: BoxShape.circle
              ),
              child: SizedBox(width: 20, height: 20,),

            ),
          ),
        ),
        SizedBox(width: 5,)
      ],
    );
  }
}
