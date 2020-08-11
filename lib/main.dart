import 'package:flutter/material.dart';
import 'add_payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_transaction_page.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'history.dart';
import 'balances.dart';
import 'package:provider/provider.dart';
import 'app_state_notifier.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'config.dart';
import 'person.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/groups/create_group.dart';
import 'package:csocsort_szamla/groups/group_settings.dart';
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
  if(preferences.containsKey('current_user')){
    currentUser=preferences.getString('current_user');
    apiToken=preferences.getString('api_token');
  }
  if(preferences.containsKey('current_group_name')){
    currentGroupName=preferences.getString('current_group_name');
    currentGroupId=preferences.getInt('current_group_id');
  }
  runApp(ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(), child: LenderApp(themeName: themeName,)));
}


class LenderApp extends StatefulWidget {
  final String themeName;

  const LenderApp({@required this.themeName});

  @override
  State<StatefulWidget> createState() => _LenderAppState();
}

class _LenderAppState extends State<LenderApp>{
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
          title: 'Lender',
          theme: appState.theme,
          home: currentUser==null?//TODO: if group does not exist
            LoginOrRegisterRoute():
            (currentGroupId==null)?
              JoinGroup():
              MainPage(),
        );

      },
    );
  }

}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);


  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  SharedPreferences prefs;
  Future<List<Group>> groups;

  TabController _tabController;
  int _selectedIndex=0;

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

      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        List<Group> groups=[];
        for(var group in decoded['data']){
          groups.add(Group(groupName: group['group_name'], groupId: group['group_id']));
        }
        return groups;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('Sajnos újra be kell jelentkezned!'), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<String> _getCurrentGroup() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString(), headers: header);

      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        currentGroupName=decoded['data']['group_name'];
        SharedPreferences.getInstance().then((_prefs){
          _prefs.setString('current_group_name', currentGroupName);
        });
        return currentGroupName;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('Sajnos újra be kell jelentkezned!'), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future _logout() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      await http.get(APPURL+'/logout', headers: header);

    }catch(_){
      throw _;
    }
  }

  List<Widget> _generateListTiles(List<Group> groups){
    return groups.map((group){
      return ListTile(
        title: Text(group.groupName, style: (group.groupName==currentGroupName)?Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.secondary):Theme.of(context).textTheme.bodyText1,),
        onTap: (){
          currentGroupName=group.groupName;
          currentGroupId=group.groupId;
          SharedPreferences.getInstance().then((_prefs){
            _prefs.setString('current_group_name', group.groupName);
            _prefs.setInt('current_group_id', group.groupId);
          });
          setState(() {
            _selectedIndex=0;
            _tabController.animateTo(_selectedIndex);
          });
        },
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    groups=null;
    groups=_getGroups();
  }

  void callback(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
        FutureBuilder(
          future: _getCurrentGroup(),
          builder: (context, snapshot){
            if(snapshot.connectionState==ConnectionState.done){
              if(snapshot.hasData){
                return Text(
                  snapshot.data,
                  style: TextStyle(letterSpacing: 0.25, fontSize: 24),
                );
              }
            }
            return Text(
              currentGroupName??'asd',
              style: TextStyle(letterSpacing: 0.25, fontSize: 24),
            );
          },
        )

      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (_index){
          setState(() {
            _selectedIndex=_index;
            _tabController.animateTo(_index);
          });
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Főoldal')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            title: Text('Bevásárlólista')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Csoport beállítások')
          )
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: ListView(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'LENDER',
                    style: Theme.of(context).textTheme.headline6.copyWith(letterSpacing: 2.5),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    currentUser,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
//                  SizedBox(height: 20,)
                ],
              ),
            ),

            FutureBuilder(
              future: groups,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasData){
                    return ExpansionTile(
                      title: Text('Csoportok', style: Theme.of(context).textTheme.bodyText1),
                      leading: Icon(Icons.group, color: Theme.of(context).textTheme.bodyText1.color),
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
                Icons.arrow_forward,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              title: Text(
                'Csatlakozás csoporthoz',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JoinGroup()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.create,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              title: Text(
                'Csoport létrehozása',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateGroup()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              title: Text(
                'Beállítások',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              title: Text(
                'Kijelentkezés',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                _logout();
                currentUser=null;
                currentGroupId=null;
                currentGroupName=null;
                apiToken=null;
                SharedPreferences.getInstance().then((_prefs) {
                  _prefs.remove('current_group_name');
                  _prefs.remove('current_group_id');
                  _prefs.remove('current_user');
                  _prefs.remove('api_token');
                });

                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
              },
            ),
//            Divider(),
//            ListTile(
//              leading: Icon(
//                Icons.bug_report,
//                color: Colors.red,
//              ),
//              title: Text(
//                'Probléma jelentése',
//                style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
//              ),
//              onTap: () {},
//              enabled: false,
//            ),

          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: _selectedIndex==0,
        child: SpeedDial(
          child: Icon(Icons.add),
          overlayColor: (Theme.of(context).brightness==Brightness.dark)?Colors.black:Colors.white,
//        animatedIcon: AnimatedIcons.menu_close,
          curve: Curves.bounceIn,

          children: [
            SpeedDialChild(
              label: 'Bevásárlás',
              labelBackgroundColor: Theme.of(context).colorScheme.secondary,
              labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).textTheme.button.color),
              child: Icon(Icons.shopping_cart),
              onTap: (){
                if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionRoute(type: ExpenseType.newExpense,))).then((value){ setState(() {

                });});
              }
            ),
            SpeedDialChild(
              label: 'Fizetés',
              labelBackgroundColor: Theme.of(context).colorScheme.secondary,
              labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).textTheme.button.color),
              child: Icon(Icons.attach_money),
              onTap: (){
                if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => AddPaymentRoute())).then((value){ setState(() {

                });
                });
              }
            ),
//          SpeedDialChild(
//            label: 'Bevásárlólista',
//            labelBackgroundColor: Theme.of(context).colorScheme.secondary,
//            labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).textTheme.button.color),
//            child: Icon(Icons.add_shopping_cart),
//            onTap: (){
//              if(currentUser!="") Navigator.push(context, MaterialPageRoute(builder: (context) => AddShoppingRoute()));
//            }
//          ),
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          RefreshIndicator(
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
                History(callback: callback,)
              ],
            ),
          ),
          ShoppingList(),
          GroupSettings(),
        ]
      ),

    );
  }
}