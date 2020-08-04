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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'login_route.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'config.dart';
import 'person.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
  if(preferences.containsKey('current_user')){
    currentUser=preferences.getString('current_user');
    apiToken=preferences.getString('api_token');
  }
  if(preferences.containsKey('current_group_name')){
    currentGroupName=preferences.getString('current_group_name');
    currentGroupId=preferences.getInt('current_group_id');
  }
  runApp(ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(), child: CsocsortApp(themeName: themeName,)));
}


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
          title: 'Csocsort',
          theme: appState.theme,
          home: currentUser==null?LoginRoute():MainPage(
            title: 'Csocsort Main Page',
          ),
//          onGenerateRoute: Router.generateRoute,
//          initialRoute: '/',
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
  Future<List<Group>> groups;

  Future<SharedPreferences> getPrefs() async{
    return await SharedPreferences.getInstance();
  }

  Future<List<Group>> _getGroups() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups', headers: header);
      Map<String, dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        List<Group> groups=[];
        for(var group in response2['data']){
          groups.add(Group(groupName: group['group_name'], groupId: group['group_id']));
        }
        return groups;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('Sajnos újra be kell jelentkezned!'), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRoute()));
        }
        throw error['error'];
      }
    }catch(_){
      throw 'Hiba';
    }
  }

  List<Widget> _generateListTiles(List<Group> groups){
    return groups.map((group){
      return ListTile(
        title: Text(group.groupName),
        onTap: (){
          SharedPreferences.getInstance().then((_prefs){
            _prefs.setString('current_group_name', group.groupName);
            _prefs.setInt('current_group_id', group.groupId);
          });
          setState(() {
            currentGroupName=group.groupName;
            currentGroupId=group.groupId;
          });
        },
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    groups=null;
    groups=_getGroups();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          currentGroupName??'asd',
          style: TextStyle(letterSpacing: 0.25, fontSize: 24),
        ),

      ),
      drawer: Drawer(
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.only(top:23),
          children: <Widget>[
            DrawerHeader(
              child: SizedBox(height: 10),

              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/csocsort_logo.png'))

              )
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Szia '+currentUser+'!',
                style: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.body2.color,
              ),
              title: Text(
                'Beállítások',
                style: Theme.of(context).textTheme.body2,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.wb_sunny,
                color: Theme.of(context).textTheme.body2.color,
              ),
              title: Text(
                'Még sok dolog',
                style: Theme.of(context).textTheme.body2,
              ),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRoute())).then((val){
                  groups=null;
                  groups=_getGroups();
                });
              },
            ),
            FutureBuilder(
              future: groups,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasData){
                    return ExpansionTile(
                      title: Text('Csoportok'),
                      leading: Icon(Icons.group, color: Theme.of(context).textTheme.body2.color),
                      children: _generateListTiles(snapshot.data),
                    );
                  }else{
                    return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(snapshot.error.toString()),
                        ),
                        onTap: (){
                          setState(() {
                            groups=null;
                            groups=_getGroups();
                          });
                        }
                    );
                  }
                }
                return LinearProgressIndicator();
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
                style: Theme.of(context).textTheme.body2.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
              enabled: false,
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        overlayColor: (Theme.of(context).brightness==Brightness.dark)?Colors.black:Colors.white,
//        animatedIcon: AnimatedIcons.menu_close,
        curve: Curves.bounceIn,

        children: [
          SpeedDialChild(
            label: 'Bevásárlás',
            labelBackgroundColor: Theme.of(context).colorScheme.secondary,
            labelStyle: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).textTheme.button.color),
            child: Icon(Icons.shopping_cart),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.newExpense,)));
            }
          ),
          SpeedDialChild(
            label: 'Fizetés',
            labelBackgroundColor: Theme.of(context).colorScheme.secondary,
            labelStyle: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).textTheme.button.color),
            child: Icon(Icons.attach_money),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => Payment()));
            }
          ),
          SpeedDialChild(
            label: 'Bevásárlólista',
            labelBackgroundColor: Theme.of(context).colorScheme.secondary,
            labelStyle: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).textTheme.button.color),
            child: Icon(Icons.add_shopping_cart),
            onTap: (){
              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => AddShoppingRoute()));
            }
          ),
        ],
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


            Balances(),
            History()
          ],
        ),
      ),

    );
  }
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}