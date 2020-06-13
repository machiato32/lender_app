import 'package:flutter/material.dart';
import 'switch_user.dart';
import 'change_pin.dart';
import 'main.dart';
import 'color_picker.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beállítások'),),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            SwitchUser(),
            Visibility(
              visible: (name!=''),
              child: ChangePin()
            ),
            ColorPicker(),
          ],
        ),
      ),

    );
  }
}
