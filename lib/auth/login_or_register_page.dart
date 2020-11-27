import 'package:csocsort_szamla/gradient_button.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginOrRegisterPage extends StatefulWidget {

  LoginOrRegisterPage();

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      needsLogin=false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/dodo_color.png'),
              height: MediaQuery.of(context).size.width / 3,
            ),
            Center(
              child: Text(
                'title'.tr().toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(letterSpacing: 2.5),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
                child: Text(
              'subtitle'.tr().toUpperCase(),
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginRoute()));
                  },
                  child: Text(
                    'login'.tr(),
                    style: Theme.of(context).textTheme.button,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RegisterRoute()));
                  },
                  child: Text('register'.tr(),
                      style: Theme.of(context).textTheme.button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
