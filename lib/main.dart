import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/version_not_supported_page.dart';
import 'package:csocsort_szamla/main/group_settings_speed_dial.dart';
import 'package:csocsort_szamla/main/in_app_purchase_page.dart';
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
import 'package:in_app_purchase/in_app_purchase.dart';

import 'balances.dart';
import 'config.dart';
import 'essentials/ad_management.dart';
import 'essentials/widgets/error_message.dart';
import 'essentials/group_objects.dart';
import 'essentials/http_handler.dart';
import 'essentials/app_state_notifier.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:csocsort_szamla/history/history.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/groups/create_group.dart';
import 'package:csocsort_szamla/groups/group_settings_page.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'main/report_a_bug_page.dart';
import 'main/trial_version_dialog.dart';
import 'main/tutorial_dialog.dart';
import 'main/main_speed_dial.dart';
import 'essentials/app_theme.dart';
import 'essentials/currencies.dart';
import 'essentials/navigator_service.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';

final getIt = GetIt.instance;



// Needed for HTTPS
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void setup(){
  getIt.registerSingleton<NavigationService>(NavigationService());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // if (message.containsKey('data')) {
  //
  // }
  //
  // print("background: "+message.toString());
  //
  // if (message.containsKey('notification')) {
  // }

  // Or do other work.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();
  Admob.initialize();
  setup();
  HttpOverrides.global = new MyHttpOverrides();
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
  //deeplink
  StreamSubscription _sub;
  String _link;
  //in-app purchase
  StreamSubscription<List<PurchaseDetails>> _subscription;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  void initUniLinks() {
    _sub = getLinksStream().listen((String link) {
      _link = link;
      setState(() {
        if(currentUserId!=null){
          getIt.get<NavigationService>().navigateToAnyad(MaterialPageRoute(builder: (context) => JoinGroup(inviteURL: _link, fromAuth: (currentGroupId == null) ? true : false)));
        }else{
          getIt.get<NavigationService>().navigateToAnyad(MaterialPageRoute(builder: (context) => LoginOrRegisterPage(inviteURL: _link,)));
        }
      });
    }, onError: (err) {
      log(err);
    });
  }

  Future onSelectNotification(String payload) async {
    print("Payload: "+payload);
    try{
      Map<String, dynamic> decoded = jsonDecode(payload);
      int groupId = decoded['group_id'];
      String groupName = decoded['group_name'];
      String currency = decoded['group_currency'];
      String page = decoded['screen'];
      String details = decoded['details'];

      if(details=='added_to_group'){//TODO: dominik
        saveGroupId(groupId);
        saveGroupName(groupName);
        if(usersGroups==null){
          usersGroups=List<String>();
          usersGroupIds=List<int>();
        }
        usersGroups.add(groupName);
        usersGroupIds.add(groupId);
        saveUsersGroups();
        saveUsersGroupIds();
      }else if(usersGroupIds!=null && usersGroupIds.contains(groupId)){
        saveGroupId(groupId);
        saveGroupName(groupName);
        if(currency!=null)
          saveGroupCurrency(currency);
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
        }else if(page=='store'){
          getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => InAppPurchasePage()));
        }
      }
    }
    catch(e)
    {
      print(e.toString());
    }
  }

  void _createNotificationChannels(String groupId, List<String> channels){
    AndroidNotificationChannelGroup androidNotificationChannelGroup =
    AndroidNotificationChannelGroup(groupId, (groupId+'_notification').tr());
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        .createNotificationChannelGroup(androidNotificationChannelGroup);

    for(String channel in channels){
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(
          AndroidNotificationChannel(
            channel,
            (channel+'_notification').tr(),
            (channel+'_notification_explanation').tr(),
            groupId: groupId,
          )
      );
    }

  }

  @override
  void initState() {
    super.initState();
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      // List<PurchaseDetails> purchasesList = purchases as List<PurchaseDetails>;
      for(PurchaseDetails details in purchases){
        if(details.status==PurchaseStatus.purchased){
          String url = (!useTest?APP_URL:TEST_URL)+'/user';
          Map<String, String> header = {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + (apiToken==null?'':apiToken)
          };
          Map<String,dynamic> body = {};
          switch(details.productID){
            case 'remove_ads':
              showAds=false;
              body['ad_free']=1;
              break;
            case 'gradients':
              useGradients=true;
              body['gradients_enabled']=1;
              break;
            case 'ad_gradient_bundle':
              showAds=false;
              body['ad_free']=1;
              useGradients=true;
              body['gradients_enabled']=1;
              break;
            case 'group_boost':
              body['boosts']=2;
              break;
            case 'big_lender_bundle':
              showAds=false;
              body['ad_free']=1;
              useGradients=true;
              body['gradients_enabled']=1;
              body['boosts']=1;
              break;

          }
          try{
            http.put(url, headers: header, body: jsonEncode(body));
          }catch(_){
            throw _;
          }
          InAppPurchaseConnection.instance.completePurchase(details);
        }
      }
      // _handlePurchaseUpdates(purchases);
    });
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@drawable/dodo_white');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    _createNotificationChannels('group_system', ['other', 'group_update']);
    _createNotificationChannels('purchase', ['purchase_created', 'purchase_modified', 'purchase_deleted']);
    _createNotificationChannels('payment', ['payment_created', 'payment_modified', 'payment_deleted']);
    _createNotificationChannels('shopping', ['shopping_created', 'shopping_fulfilled', 'shopping_shop']);

    initUniLinks();
    _link = widget.initURL;

    Future.delayed(Duration(seconds: 1)).then((value){
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          Map<String, dynamic> decoded = jsonDecode(message['data']['payload']);
          print(decoded);
          // var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          //     message['data']['payload']['channel_id'],
          //     (message['data']['payload']['channel_id']+'_notification').tr(),
          //     (message['data']['payload']['channel_id']+'_notification_explanation').tr()
          // );
          // var iOSPlatformChannelSpecifics =
          // new IOSNotificationDetails(presentSound: false);
          // var platformChannelSpecifics = new NotificationDetails(
          //     android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
          // flutterLocalNotificationsPlugin.show(
          //     int.parse(message['data']['id'])??0,
          //     message['notification']['title'],
          //     message['notification']['body'],
          //     platformChannelSpecifics,
          //     payload: message['data']['payload']
          // );
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
      if(currentUserId!=null){
        _getUserData();
      }
      _supportedVersion()
      .then((value){
        if(!(value??true)){
          getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => VersionNotSupportedPage(),));
        }
      });
    });
  }

  Future<bool> _supportedVersion() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
      };
      http.Response response = await http.get((useTest?TEST_URL:APP_URL)+'/supported?version='+currentVersion.toString(), headers: header);
      bool decoded = jsonDecode(response.body);
      return decoded;
    }catch(_){
      throw _;
    }
  }

  Future<void> _getUserData() async { //TODO: needs testing
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + (apiToken==null?'':apiToken)
      };
      http.Response response = await http.get((useTest?TEST_URL:APP_URL)+'/user', headers: header);
      var decoded = jsonDecode(response.body);
      showAds=decoded['data']['ad_free']==0;
      useGradients=decoded['data']['gradients_enabled']==1;
      personalisedAds=decoded['data']['personalised_ads']==1;
      trialVersion=decoded['data']['trial']==1;
      if(currentGroupId==null && decoded['data']['last_active_group']!=""){//TODO: itt valami nem jó
        currentGroupId=decoded['data']['last_active_group'];
        getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(builder: (context) => MainPage(),));
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if(!useGradients && preferences.getString('theme').contains('Gradient')){
        preferences.setString('theme', 'greenLightTheme');
      }
    }catch(_){
      throw _;
    }

  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    _subscription.cancel();
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
            debugShowCheckedModeBanner: false,
            title: 'Lender',
            theme: appState.theme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: getIt.get<NavigationService>().navigatorKey,
            home: currentUserId == null
                ? LoginOrRegisterPage(inviteURL: _link,)
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
  GlobalKey<State> _isGuestBannerKey = GlobalKey<State>();

  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<Group>> _getGroups() async {
    http.Response response = await httpGet(context: context, uri: '/groups');
    Map<String, dynamic> decoded = jsonDecode(response.body);
    List<Group> groups = [];
    usersGroups=groups.map<String>((group) => group.groupName).toList();
    usersGroupIds=groups.map<int>((group) => group.groupId).toList();
    saveUsersGroups();
    saveUsersGroupIds();
    for (var group in decoded['data']) {
      groups.add(
        Group(
          groupName: group['group_name'], groupId: group['group_id'], groupCurrency: group['currency'],
        )
      );
    }
    if(groups.any((element) => element.groupId==currentGroupId)){
      var group = groups.firstWhere((element) => element.groupId==currentGroupId);
      saveGroupName(group.groupName);
      saveGroupCurrency(group.groupCurrency);
    }
    return groups;
  }

  Future<String> _getCurrentGroup() async {
    http.Response response = await httpGet(context: context, uri: '/groups/' + currentGroupId.toString());
    Map<String, dynamic> decoded = jsonDecode(response.body);
    saveGroupName(decoded['data']['group_name']);
    return currentGroupName;
  }

  Future<dynamic> _getSumBalance() async {
    try{
      http.Response response = await httpGet(context: context, uri: '/balance');
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data'];
    }catch(_){
      throw _;
    }
  }

  Future _logout() async {
    try {
      await httpPost(uri: '/logout', context: context, body: {});
      await clearAllCache();
      deleteUserId();
      deleteGroupId();
      deleteGroupName();
      deleteGroupCurrency();
      deleteApiToken();
      deleteGuestUserId();
      deleteGuestNickname();
      deleteGuestGroupId();
      deleteGuestApiToken();
      deleteUsersGroups();
      deleteUsersGroupIds();
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
        onTap: () async {
          await clearAllCache();
          saveGroupName(group.groupName);
          saveGroupId(group.groupId);
          saveGroupCurrency(group.groupCurrency);
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
  @override
  void dispose() {
    super.dispose();

  }
  void _handleDrawer() {
    FeatureDiscovery.discoverFeatures(context, <String>['drawer', 'settings']);
    _scaffoldKey.currentState.openDrawer();
    _groups = null;
    _groups = _getGroups();
  }

  Future<void> callback() async {
    await clearAllCache();
    setState(() {
      _groups = null;
      _groups = _getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex!=1?Theme.of(context).scaffoldBackgroundColor:Theme.of(context).cardTheme.color,
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: _selectedIndex==1?0:4,
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
              currentGroupName ?? 'error'.tr(),
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
            _scaffoldKey.currentState.removeCurrentSnackBar();
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
              icon: Icon(Icons.home), label: 'home'.tr()
          ),
          BottomNavigationBarItem(
              icon: DescribedFeatureOverlay(
                  featureId: 'shopping_list',
                  tapTarget: Icon(Icons.receipt_long, color: Colors.black),
                  title: Text('discover_shopping_title'.tr()),
                  description: Text('discover_shopping_description'.tr()),
                  overflowMode: OverflowMode.extendBackground,
                  child: Icon(Icons.receipt_long)
              ),
              label: 'shopping_list'.tr()
          ),
          BottomNavigationBarItem( //TODO: change user currency
              icon: DescribedFeatureOverlay(
                  featureId: 'group_settings',
                  tapTarget: Icon(Icons.supervisor_account, color: Colors.black),
                  title: Text('discover_group_settings_title'.tr()),
                  description: Text('discover_group_settings_description'.tr()),
                  overflowMode: OverflowMode.extendBackground,
                  child: Icon(Icons.supervisor_account)
              ),
              label: 'group'.tr()
          )
        ],
      ),

      drawer: Drawer(
        elevation: 16,
        child: Ink(
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
                              image: AssetImage('assets/dodo_color_glow3.png'),
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
                              locationOfError: 'home_groups',
                              callback: (){
                                setState(() {
                                  _groups = null;
                                  _groups = _getGroups();
                                });
                              },
                            );
                          }
                        }
                        return LinearProgressIndicator(backgroundColor: Theme.of(context).colorScheme.primary,);
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
                      String currency = snapshot.data['currency'];
                      double balance = snapshot.data['balance']*1.0;
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
                dense: true,
                onTap: (){
                  if(trialVersion){
                    showDialog(context: context, child: TrialVersionDialog());
                  }else{
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InAppPurchasePage())
                    );
                  }
                },
                leading: Icon(Icons.shopping_basket, color: Theme.of(context).textTheme.bodyText1.color,),
                subtitle: trialVersion?
                  Text('trial_version'.tr().toUpperCase(),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).colorScheme.primary),
                  ):
                  null,
                title: Text('in_app_purchase'.tr(), style: Theme.of(context).textTheme.bodyText1,),
              ),
              ListTile(
                dense: true,
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
                  Icons.bug_report,
                  color: Colors.red,
                ),
                dense: true,
                title: Text(
                  'report_a_bug'.tr(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportABugPage()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                dense: true,
                title: Text(
                  'logout'.tr(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () async {
                  _logout();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginOrRegisterPage()),
                          (r) => false);
                },
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex==2?
        GroupSettingsSpeedDial()

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
          return Column(
            children: [
              IsGuestBanner(key: _isGuestBannerKey, callback: callback,),
              Expanded(
                child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          if(isOnline) await callback();
                          setState(() {

                          });
                        },
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Balances(
                              callback: callback,
                            ),
                            History(
                              selectedIndex: widget.selectedHistoryIndex,
                              callback: callback,
                            )
                          ],
                        ),
                      ),
                      ShoppingList(isOnline: isOnline,),
                      GroupSettings(bannerKey: _isGuestBannerKey),
                    ]
                ),
              ),
              adUnitForSite('home_screen'),
            ],
          );
        }
      ),
    );
  }
}
