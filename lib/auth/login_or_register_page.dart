import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class LoginOrRegisterRoute extends StatefulWidget {
  @override
  _LoginOrRegisterRouteState createState() => _LoginOrRegisterRouteState();
}

class _LoginOrRegisterRouteState extends State<LoginOrRegisterRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/dodo_color.png'),
              height: MediaQuery.of(context).size.width/3,
            ),
            Text(
              'LENDER',
              style: Theme.of(context).textTheme.title.copyWith(letterSpacing: 2.5),
            ),
            SizedBox(height: 10,),
            Text('Money and debt management app designed for groups'.toUpperCase(), style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12 ),),
            SizedBox(height: 100,),
            RaisedButton(
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute()));},
              child: Text('Bejelentkezés', style: Theme.of(context).textTheme.button,),
              color: Theme.of(context).colorScheme.secondary,
            ),
            RaisedButton(
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute()));},
              child: Text('Regisztráció', style: Theme.of(context).textTheme.button),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
