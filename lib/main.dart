import 'package:flutter/material.dart';
import 'payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_expense.dart';
import 'user_settings.dart';
import 'history.dart';
import 'balances.dart';
import 'package:provider/provider.dart';
import 'app_state_notifier.dart';
import 'shopping.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String themeName='';
  if(!preferences.containsKey('theme')){
    preferences.setString('theme', 'greenLightTheme');
    themeName='greenLightTheme';
  }else{
    themeName=preferences.getString('theme');
  }
  runApp(ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(), child: CsocsortApp(themeName: themeName,)));
}
  String name='';


class CsocsortApp extends StatefulWidget {
  final String themeName;

  const CsocsortApp({@required this.themeName});

  @override
  State<StatefulWidget> createState() => _CsocsortAppState();
}

class _CsocsortAppState extends State<CsocsortApp>{
  bool first=true;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (context, appState, child){
        if(first) {
          appState.updateThemeNoNotify(widget.themeName);
          first=false;
        }
        return MaterialApp(
          title: 'Flutter Demo',
          theme: appState.theme,
          home: MainPage(
            title: 'Flutter Demo Home Page',
          ),
        );

      },
    );
  }

}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences prefs;

  Future<SharedPreferences> getPrefs() async{
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    getPrefs().then((_prefs){
      if(!_prefs.containsKey('name')){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
      }else{
        setState(() {
          name=_prefs.get('name');
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Csocsort számla',
          style: TextStyle(letterSpacing: 0.25, fontSize: 24),
        ),

      ),
      drawer: Drawer(
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            DrawerHeader(
              child: SizedBox(height: 10),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,

              )
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Theme.of(context).textTheme.body1.color,
              ),
              title: Text(
                'Felhasználó',
                style: Theme.of(context).textTheme.body1.copyWith(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.wb_sunny,
                color: Theme.of(context).textTheme.body1.color,
              ),
              title: Text(
                'Még sok dolog',
                style: Theme.of(context).textTheme.body1.copyWith(fontWeight: FontWeight.bold),
              ),
              onTap: () {
//                Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => Print()));
              },
            ),

            Divider(),
            ListTile(
              leading: Icon(
                Icons.bug_report,
                color: Colors.red,
              ),
              title: Text(
                'Probléma jelentése',
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
              enabled: false,
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: (){
          return getPrefs().then((_money) {
            setState(() {

            });
          });
        },
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[

            Card(

              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.account_circle, color: Theme.of(context).textTheme.body1.color,),
                          SizedBox(width: 5,),
                          Text('Szia $name!'),
                        ],
                      ),
                      alignment: Alignment.topRight),
                    Text('Mi újság?', style: Theme.of(context).textTheme.title),
                    SizedBox(height: 10,),
                    RaisedButton.icon(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icon(Icons.shopping_basket, color: Theme.of(context).colorScheme.onSecondary),
                      label: Text('Vettem valamit', style: Theme.of(context).textTheme.button),

                      onPressed: () {if(name!="") Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense()));},
                    ),
                    RaisedButton.icon(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.onSecondary),
                      label: Text('Fizettem valakinek', style: Theme.of(context).textTheme.button),
                      onPressed: ()  {if(name!="") Navigator.push(context, MaterialPageRoute(builder: (context) => Payment()));},
                    ),
                    RaisedButton.icon(
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icon(Icons.add_shopping_cart, color: Theme.of(context).colorScheme.onSecondary),
                      label: Text('Szeretnék valamit a boltból', style: Theme.of(context).textTheme.button),
                      onPressed: ()  {/*if(name!="")*/ Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingRoute()));},
                    ),
                  ],
                ),
              ),
            ),
            Balances(),
            ShoppingList(),
            History()
          ],
        ),
      ),

    );
  }
}
