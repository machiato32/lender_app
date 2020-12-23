import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/gradient_button.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginOrRegisterPage extends StatefulWidget {

  LoginOrRegisterPage();

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool _doubleTapped=false;
  bool _tapped=false;
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
            GestureDetector(
              onTap: (){
                _tapped=true;
                _doubleTapped=false;
              },
              onDoubleTap: (){
                if(_tapped){
                  _doubleTapped=true;
                }
              },
              onLongPress: (){
                if(_tapped && _doubleTapped){
                  clearAllCache();
                  useTest=!useTest;
                  _tapped=false;
                  _doubleTapped=false;
                  FlutterToast ft = FlutterToast(context);
                  // ft.removeQueuedCustomToasts();
                  ft.showToast(child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.grey[700],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Text(useTest?'Test Mode':'Normal Mode',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.white))),
                      ],
                    ),
                  ));
                }
              },
              child: Image(
                image: AssetImage('assets/dodo_color.png'),
                height: MediaQuery.of(context).size.width / 3,
              ),
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
