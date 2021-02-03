import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: Text(
                'about_us'.tr(),
                style:
                Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'about_us_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.info, color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: (){
                    showAboutDialog(
                      context: context,
                      applicationName: 'Lender',
                      children: <Widget>[
                        Text('about_us_text'.tr(),
                          textAlign: TextAlign.justify,
                        )
                      ],
                      applicationIcon: Container(child: Image(image: AssetImage('assets/dodo_color.png'),), width: 24, height: 24,),
                      routeSettings: RouteSettings(
                        // arguments: ,
                      ),

                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
