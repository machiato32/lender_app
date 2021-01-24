import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main/in_app_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:csocsort_szamla/essentials/app_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class ColorPicker extends StatefulWidget {
  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  List<Widget> _getSolidColors() {
    return AppTheme.themes.entries.where((element) => !element.key.contains('Gradient')).map((entry) {
      return ColorElement(
        theme: entry.value,
        themeName: entry.key,
      );
    }).toList();
  }
  List<Widget> _getGradientColors({bool enabled}) {
    return AppTheme.themes.entries.where((element) => element.key.contains('Gradient')).map((entry) {
      return ColorElement(
        theme: entry.value,
        themeName: entry.key,
        enabled: enabled
      );
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
            Center(
                child: Text(
              'change_theme'.tr(),
              style: Theme.of(context).textTheme.headline6,
            )),
            SizedBox(height: 10),
            Center(
              child: Wrap(
                runSpacing: 5,
                spacing: 5,
                children: _getSolidColors(),
              ),
            ),
            SizedBox(height: 7,),
            Divider(),
            SizedBox(height: 7,),
            Visibility(
              visible: !useGradients,
              child: Text('gradient_available_in_paid_version'.tr(), style: Theme.of(context).textTheme.subtitle2,),
            ),
            Center(
              child: Wrap(
                runSpacing: 5,
                spacing: 5,
                children: _getGradientColors(enabled: useGradients),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ColorElement extends StatefulWidget {
  final ThemeData theme;
  final String themeName;
  final bool enabled;
  const ColorElement({this.theme, this.themeName, this.enabled=true});

  @override
  _ColorElementState createState() => _ColorElementState();
}

class _ColorElementState extends State<ColorElement> {
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: (widget.themeName ==
                Provider.of<AppStateNotifier>(context, listen: false)
                    .themeName)
            ? AppTheme.gradientFromTheme(widget.theme)
            : LinearGradient(colors:[Colors.transparent, Colors.transparent]),
        borderRadius: BorderRadius.circular(20)
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if(widget.enabled){
            Provider.of<AppStateNotifier>(context, listen: false)
                .updateTheme(widget.themeName);
            _getPrefs().then((_prefs) {
              _prefs.setString('theme', widget.themeName);
            });
          }else{
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InAppPurchasePage())
            );
          }
        },
        child: Ink(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              boxShadow: ( Theme.of(context).brightness==Brightness.light)
                  ?[ BoxShadow(
                    color: Colors.grey[500],
                    offset: Offset(0.0, 1.5),
                    blurRadius: 1.5,
                  )]
                  : [],
              gradient: AppTheme.gradientFromTheme(widget.theme),
              border: Border.all(
                  color: widget.theme.scaffoldBackgroundColor, 
                  width: 8
              ),
              borderRadius: BorderRadius.circular(20)
            ),
          child: SizedBox(
            width: 25,
            height: 25,
          ),
        ),
      ),
    );

  }
}
