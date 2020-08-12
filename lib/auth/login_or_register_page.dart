import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginOrRegisterRoute extends StatefulWidget {
  final bool showDialog;
  LoginOrRegisterRoute({this.showDialog=false});
  @override
  _LoginOrRegisterRouteState createState() => _LoginOrRegisterRouteState();
}

class _LoginOrRegisterRouteState extends State<LoginOrRegisterRoute> {

  @override
  void initState() {
    super.initState();
    if(widget.showDialog){
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
            context: context,
            child: AlertDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text('Légyszi olvasd el!'),
              content: SingleChildScrollView(
                child:
                Text('Szia! Először is köszi, hogy teszteled az appunkat. Tartsd fejben, hogy ez egy béta, így nem biztos hogy minden helyzetben hiba nélkül tud futni (bár elég sokat teszteltük). Ezen kívül sok funkció még nincs benne, ami már tervben van. \n\nEzért is szeretnénk arra kérni Téged, hogy ha bármilyen ötleted van, bármilyen hibát találsz, fura dolgot ír ki az app, feltétlenül írjál nekünk. Ezt legegyszerűbben a Play Áruház visszajelző felületén teheted meg, vagy írhatsz nekünk egy emailt a developer@lenderapp.net címre is.\n\n'
                    'Röviden az alkalmazás használatáról.\n\nElőször regisztrálj! Itt fontos tudni, hogy a felhasználóneved és azonosítószámod nem megváltoztatható, a bejelentkezéshez mindkettő szükséges. Ezeket feltétlenül jegyezd meg!\nTipp: ha mégis elfelejtenéd, de már tagja vagy egy csoportnak, barátaid meg tudják neked mondani, ha a csoport beállításaira mennek.\nAmennyiben te vagy az első letöltő a csoportodban, hozz létre egy új csoportot! Ez után a csoport beállításainál találsz egy meghívót, amit elküldve barátaidnak, ők be tudnak lépni a csoportba.\n\n'
                    'Amennyiben már más létrehozta a csoportot, akkor a meghívót a regisztráció után bemásolva tudsz belépni a csoportba.\nA csoport létrehozásakor, illetve oda belépéskor megadhatod becenevedet, ami csak abban a csoportban lesz látható a barátaid számára. Ezt a csoport beállításainál megváltoztathatod.\n\n'
                    'Innentől az alkalmazás felfedezését rád bízzuk, reméljük minden működni fog.\n\n'
                    'Remélem hasznodra válik az alkalmazás!\nA fejlesztők.\n\n'
                    'U.I.: Ez később nem ilyen bénán fog megjelenni.',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                ),

              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Tényleg elolvastam', style: Theme.of(context).textTheme.button,), color: Theme.of(context).colorScheme.secondary,)
              ],
            )
        );
      });
    }

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
              height: MediaQuery.of(context).size.width/3,
            ),
            Center(
              child: Text(
                'title'.tr().toUpperCase(),
                style: Theme.of(context).textTheme.headline6.copyWith(letterSpacing: 2.5),
              ),
            ),
            SizedBox(height: 10,),
            Flexible(child: Text('subtitle'.tr().toUpperCase(), style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12 ),)),
            SizedBox(height: 100,),
            RaisedButton(
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute()));},
              child: Text('login'.tr(), style: Theme.of(context).textTheme.button, textAlign: TextAlign.center,),
              color: Theme.of(context).colorScheme.secondary,
            ),
            RaisedButton(
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterRoute()));},
              child: Text('register'.tr(), style: Theme.of(context).textTheme.button),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
