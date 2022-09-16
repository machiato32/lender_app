import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_page.dart';
import 'register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  final String inviteURL;
  LoginOrRegisterPage({this.inviteURL});

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _doubleTapped = false;
  bool _tapped = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (useTest) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: Duration(hours: 10),
          content: Text(
            'Test Mode',
            style: Theme.of(context).textTheme.button,
          ),
          action: SnackBarAction(
            label: 'Back to Normal Mode',
            textColor: Theme.of(context).textTheme.button.color,
            onPressed: () {
              setState(() {
                useTest = !useTest;
                _tapped = false;
                _doubleTapped = false;
              });
            },
          ),
        ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onTap: () {
                  _tapped = true;
                  _doubleTapped = false;
                },
                onDoubleTap: () {
                  if (_tapped) {
                    _doubleTapped = true;
                  }
                },
                onLongPress: () {
                  if (_tapped && _doubleTapped) {
                    setState(() {
                      if (!useTest) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          duration: Duration(hours: 10),
                          content: Text(
                            'Test Mode',
                            style: Theme.of(context).textTheme.button,
                          ),
                          action: SnackBarAction(
                            label: 'Back to Normal Mode',
                            textColor: Theme.of(context).textTheme.button.color,
                            onPressed: () {
                              setState(() {
                                useTest = !useTest;
                                _tapped = false;
                                _doubleTapped = false;
                              });
                            },
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      }
                      clearAllCache();
                      useTest = !useTest;
                      _tapped = false;
                      _doubleTapped = false;
                    });
                  }
                },
                child: Image(
                  image: AssetImage('assets/dodo_color_glow3.png'),
                  height: MediaQuery.of(context).size.width / 3,
                ),
              ),
            ),
            Center(
              child: Text(
                'title'.tr().toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
                child: Text(
              'subtitle'.tr().toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            )),
            Flexible(
              child: SizedBox(
                height: 50,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(
                                  inviteURL: widget.inviteURL,
                                )));
                  },
                  child: Text(
                    'login'.tr(),
                    style: Theme.of(context).textTheme.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegisterPage(inviteURL: widget.inviteURL)));
                  },
                  child: Text('register'.tr(),
                      style: Theme.of(context).textTheme.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
