import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:get_it/get_it.dart';

import 'balances.dart';
import 'config.dart';
import 'essentials/widgets/error_message.dart';
import 'essentials/group_objects.dart';
import 'essentials/http_handler.dart';
import 'essentials/app_state_notifier.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:csocsort_szamla/history/history.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/groups/create_group.dart';
import 'package:csocsort_szamla/groups/group_settings.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'main/report_a_bug_page.dart';
import 'main/tutorial_dialog.dart';
import 'main/speed_dial.dart';
import 'essentials/app_theme.dart';
import 'essentials/currencies.dart';
import 'essentials/navigator_service.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';

final getIt = GetIt.instance;

void setup(){
  getIt.registerSingleton<NavigationService>(NavigationService());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {

  }

  print("background: "+message.toString());

  if (message.containsKey('notification')) {
  }

  // Or do other work.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String themeName = '';
  if (!preferences.containsKey('theme')) {
    preferences.setString('theme', 'greenLightTheme');
    themeName = 'greenLightTheme';
  } else {
    themeName = preferences.getString('theme');
  }
  await loadAllPrefs();

  String initURL;
  try {
    initURL = await getInitialLink();
  } catch (_) {}

  runApp(
    EasyLocalization(
      child: ChangeNotifierProvider<AppStateNotifier>(
          create: (context) => AppStateNotifier(),
          child: LenderApp(
            themeName: themeName,
            initURL: initURL,
          )
      ),
      supportedLocales: [Locale('en'), Locale('de'), Locale('it'), Locale('hu')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      useOnlyLangCode: true,
      saveLocale: true,
      preloaderColor: (themeName.contains('Light')) ? Colors.white : Colors.black,
      preloaderWidget: MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: Center(
            child: Text(
              'LENDER',
              style: TextStyle(
                  color:
                  (themeName.contains('Light')) ? Colors.black : Colors.white,
                  letterSpacing: 2.5,
                  fontSize: 35),
            ),
          ),
        ),
      ),
    )
  );
}

class LenderApp extends StatefulWidget {
  final String themeName;
  final String initURL;

  const LenderApp({@required this.themeName, this.initURL});

  @override
  State<StatefulWidget> createState() => _LenderAppState();
}

class _LenderAppState extends State<LenderApp> {
  bool _first = true;

  StreamSubscription _sub;
  String _link;


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  void initUniLinks() {
    _sub = getLinksStream().listen((String link) {
      _link = link;
      print(context);
      setState(() {
        getIt.get<NavigationService>().navigateToAnyad(MaterialPageRoute(builder: (context) => JoinGroup(inviteURL: _link,)));
      });
    }, onError: (err) {
      log(err);
    });
  }

  // initPlatformState() async {
  //   await initUniLinks();
  // }

  Future onSelectNotification(String payload) async {
    print("Payload: "+payload);
    try{
      Map<String, dynamic> decoded = jsonDecode(payload);
      int groupId = decoded['group_id'];
      String groupName = decoded['group_name'];
      String page = decoded['screen'];
      String details = decoded['details'];
      if(usersGroupIds.contains(groupId)){
        currentGroupId=groupId;
        currentGroupName=groupName;
      }
      clearAllCache();
      if(currentUserId!=null){
        if(page=='home'){
          int selectedIndex=0;
          if(details=='payment'){
            selectedIndex=1;
          }
          getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => MainPage(selectedHistoryIndex:selectedIndex)));
        }else if(page=='shopping'){
          int selectedTab=1;
          getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => MainPage(selectedIndex:selectedTab)));
        }else{
          // getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => MainPage()));
        }
      }
    }
    catch(e)
    {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@drawable/dodo_white');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    initUniLinks();
    _link = widget.initURL;

    Future.delayed(Duration(seconds: 1)).then((value){
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
              '1234',
              'Lender',
              'Lender',
              playSound: false,
              importance: Importance.High,
              priority: Priority.Default,
              styleInformation: BigTextStyleInformation('')
          );
          var iOSPlatformChannelSpecifics =
          new IOSNotificationDetails(presentSound: false);
          var platformChannelSpecifics = new NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(
              int.parse(message['data']['id'])??0,
              message['notification']['title'],
              message['notification']['body'],
              platformChannelSpecifics,
              payload: message['data']['payload']
          );
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          // print(message);
          print("onLaunch: $message");
          onSelectNotification(message['data']['payload']);
        },
        onResume: (Map<String, dynamic> message) async {
          // print(message);
          print("onResume: $message");
          onSelectNotification(message['data']['payload']);
        },
      );
    });
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (context, appState, child) {
        if (_first) {
          appState.updateThemeNoNotify(widget.themeName);
          _first = false;
        }
        return FeatureDiscovery(
          child: MaterialApp(
            title: 'Lender',
            theme: appState.theme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: getIt.get<NavigationService>().navigatorKey,
            home: currentUserId == null
                ? LoginOrRegisterPage()
                : (_link != null)
                ? JoinGroup(
                  inviteURL: _link,
                  fromAuth: (currentGroupId == null) ? true : false,
                )
                : (currentGroupId == null)
                ? JoinGroup(
                  fromAuth: true,
                )
                : MainPage(),
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int selectedHistoryIndex;
  final int selectedIndex;
  MainPage({this.selectedHistoryIndex=0, this.selectedIndex=0});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  SharedPreferences prefs;
  Future<List<Group>> _groups;

  TabController _tabController;
  int _selectedIndex = 0;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<Group>> _getGroups() async {
    http.Response response = await httpGet(context: context, uri: '/groups');
    Map<String, dynamic> decoded = jsonDecode(response.body);
    List<Group> groups = [];
    for (var group in decoded['data']) {
      groups.add(Group(
          groupName: group['group_name'], groupId: group['group_id'], groupCurrency: group['currency']));
    }
    return groups;
  }

  Future<String> _getCurrentGroup() async {
    http.Response response = await httpGet(context: context, uri: '/groups/' + currentGroupId.toString());
    Map<String, dynamic> decoded = jsonDecode(response.body);
    currentGroupName = decoded['data']['group_name'];
    SharedPreferences.getInstance().then((_prefs) {
      _prefs.setString('current_group_name', currentGroupName);
    });
    return currentGroupName;
  }

  Future<dynamic> _getSumBalance() async {
    try{
      http.Response response = await httpGet(context: context, uri: '/user');
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data'];
    }catch(_){
      throw _;
    }
  }

  Future _logout() async {
    try {
      await httpPost(uri: '/logout', context: context, body: {});
      currentUserId = null;
      currentGroupId = null;
      currentGroupName = null;
      currentGroupCurrency=null;
      apiToken = null;
      usersGroups=null;
      usersGroupIds=null;
      SharedPreferences.getInstance().then((_prefs) {
        _prefs.remove('current_user_id');
        _prefs.remove('current_group_name');
        _prefs.remove('current_group_id');
        _prefs.remove('api_token');
        _prefs.remove('current_group_currency');
        _prefs.remove('users_groups');
        _prefs.remove('users_group_ids');
      });
    } catch (_) {
      throw _;
    }
  }

  List<Widget> _generateListTiles(List<Group> groups) {
    return groups.map((group) {
      return ListTile(
        title: Text(
          group.groupName,
          style: (group.groupName == currentGroupName)
              ? Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).colorScheme.secondary)
              : Theme.of(context).textTheme.bodyText1,
        ),
        onTap: () {
          currentGroupName = group.groupName;
          currentGroupId = group.groupId;
          currentGroupCurrency = group.groupCurrency;
          SharedPreferences.getInstance().then((_prefs) {
            _prefs.setString('current_group_name', group.groupName);
            _prefs.setInt('current_group_id', group.groupId);
            _prefs.setString('current_group_currency', group.groupCurrency);
          });
          setState(() {
            _selectedIndex = 0;
            _tabController.animateTo(_selectedIndex);
          });
        },
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex=widget.selectedIndex;
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.selectedIndex);
    _groups = null;
    _groups = _getGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool showTutorial=true;
      await SharedPreferences.getInstance().then((prefs) {
        if(prefs.containsKey('show_tutorial')){
          showTutorial=prefs.getBool('show_tutorial');
        }
      });
      if(showTutorial){
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('show_tutorial', false);
        });
        await showDialog(
          context: context,
          builder: (context){
            return TutorialDialog();
          },
        );
      }

    });
  }

  void _handleDrawer() {
    FeatureDiscovery.discoverFeatures(context, <String>['drawer', 'settings']);
    _scaffoldKey.currentState.openDrawer();
    _groups = null;
    _groups = _getGroups();
  }

  void callback() async {
    await clearCache();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientFromTheme(Theme.of(context))
          ),
        ),
        title: FutureBuilder(
          future: _getCurrentGroup(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24),
                );
              }
            }
            return Text(
              currentGroupName ?? 'asd',
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24),
            );
          },
        ),
        leading: DescribedFeatureOverlay(
          tapTarget: Icon(Icons.menu, color: Colors.black),
          featureId: 'drawer',
          backgroundColor: Theme.of(context).colorScheme.primary,
          overflowMode: OverflowMode.extendBackground,
          title: Text('discovery_drawer_title'.tr()),
          description: Text('discovery_drawer_description'.tr()),
          barrierDismissible: false,
          child: IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSecondary,),
            onPressed: _handleDrawer,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (_index) {
          setState(() {
            _selectedIndex = _index;
            _tabController.animateTo(_index);
          });
          if(_selectedIndex==1){
            FeatureDiscovery.discoverFeatures(context, ['shopping_list']);
          }else if(_selectedIndex==2){
            FeatureDiscovery.discoverFeatures(context, ['group_settings']);
          }
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), title: Text('home'.tr())),
          BottomNavigationBarItem(
              icon: DescribedFeatureOverlay(
                  featureId: 'shopping_list',
                  tapTarget: Icon(Icons.add_shopping_cart, color: Colors.black),
                  title: Text('discover_shopping_title'.tr()),
                  description: Text('discover_shopping_description'.tr()),
                  overflowMode: OverflowMode.extendBackground,
                  child: Icon(Icons.add_shopping_cart)
              ),
              title: Text('shopping_list'.tr())
          ),
          BottomNavigationBarItem( //TODO: change user currency
              icon: DescribedFeatureOverlay(
                  featureId: 'group_settings',
                  tapTarget: Icon(Icons.supervisor_account, color: Colors.black),
                  title: Text('discover_group_settings_title'.tr()),
                  description: Text('discover_group_settings_description'.tr()),
                  overflowMode: OverflowMode.extendBackground,
                  child: Icon(Icons.supervisor_account)),
              title: Text('group'.tr())
          )
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: Container(
          color: Theme.of(context).brightness==Brightness.dark?Color.fromARGB(255, 50, 50, 50):Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Image(
                              image: AssetImage('assets/dodo_color.png'),
                            ),
                          ),
                          Text(
                            'LENDER',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(letterSpacing: 2.5),
                          ),
                          Text(
                            'hi'.tr()+' '+currentUsername+'!',
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: _groups,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Text('groups'.tr(),
                                    style: Theme.of(context).textTheme.bodyText1),
                                leading: Icon(Icons.group,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                children: _generateListTiles(snapshot.data),
                              ),
                            );
                          } else {
                            return ErrorMessage(
                              error: snapshot.error.toString(),
                              locationOfError: 'balances',
                              callback: (){
                                setState(() {
                                  _groups = null;
                                  _groups = _getGroups();
                                });
                              },
                            );
                          }
                        }
                        return LinearProgressIndicator();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.group_add,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      title: Text(
                        'join_group'.tr(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => JoinGroup()));
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.create,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      title: Text(
                        'create_group'.tr(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateGroup()));
                      },
                    ),
                  ],
                ),
              ),

              FutureBuilder(
                future: _getSumBalance(),
                builder: (context, snapshot){
                  if(snapshot.connectionState==ConnectionState.done){
                    if(snapshot.hasData){
                      String currency = snapshot.data['default_currency'];
                      double balance = snapshot.data['total_balance']*1.0;
                      return Text(
                          'Σ: '+ balance.printMoney(currency),
                          style: Theme.of(context).textTheme.bodyText1
                      );
                    }
                  }
                  return Text('Σ: ...',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: DescribedFeatureOverlay(
                  tapTarget: Icon(Icons.settings, color: Colors.black),
                  featureId: 'settings',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  overflowMode: OverflowMode.extendBackground,
                  allowShowingDuplicate: true,
                  contentLocation: ContentLocation.above,
                  title: Text('discovery_settings_title'.tr()),
                  description: Text('discovery_settings_description'.tr()),
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
                ),
                title: Text(
                  'settings'.tr(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                title: Text(
                  'logout'.tr(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () {
                  _logout();
                  clearCache();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginOrRegisterPage()),
                          (r) => false);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.bug_report,
                  color: Colors.red,
                ),
                title: Text(
                  'report_a_bug'.tr(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportABugPage()));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex==2?
        FloatingActionButton(
          onPressed: (){},
          child: Icon(Icons.assessment),
        )
        :
        Visibility(
          visible: _selectedIndex == 0,
          child: MainPageSpeedDial(callback: this.callback,),
        ),
      body: ConnectivityWidget(
        offlineBanner: Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            color: Colors.red,
            child: Text(
              'no_connection'.tr(),
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
        ),
        builder: (context, isOnline){
          GlobalKey<State> key = GlobalKey<State>();
          return Column(
            children: [
              IsGuestBanner(key: key, callback: callback,),
              Expanded(
                child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          await clearCache();
                          setState(() {

                          });
                        },
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Balances(
                              callback: callback,
                            ),//TODO: remove guest, merge guest, switch guest, shopping list
                            History(
                              selectedIndex: widget.selectedHistoryIndex,
                              callback: callback,
                            )
                          ],
                        ),
                      ),
                      ShoppingList(),
                      GroupSettings(bannerKey: key),
                    ]
                ),
              ),
            ],
          );
        }
      ),
    );
  }
  Future clearCache() async {
    await deleteCache(uri: '/groups/' + currentGroupId.toString());
    await deleteCache(uri: '/groups');
    await deleteCache(uri: '/user');
    await deleteCache(uri: '/payments?group=' + currentGroupId.toString());
    await deleteCache(uri: '/transactions?group=' + currentGroupId.toString());
  }
}
