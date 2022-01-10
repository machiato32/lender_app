import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/version_not_supported_page.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/main/in_app_purchase_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'config.dart';
import 'essentials/app_state_notifier.dart';
import 'essentials/http_handler.dart';
import 'essentials/navigator_service.dart';
import 'groups/main_group_page.dart';

final getIt = GetIt.instance;

// Needed for HTTPS
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void setup() {
  getIt.registerSingleton<NavigationService>(NavigationService());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  onSelectNotification(message.data['payload']);
}

Future onSelectNotification(String payload) async {
  print("Payload: " + payload);
  try {
    Map<String, dynamic> decoded = jsonDecode(payload);
    int groupId = decoded['group_id'];
    String groupName = decoded['group_name'];
    String currency = decoded['group_currency'];
    String page = decoded['screen'];
    String details = decoded['details'];

    //If this notification is about a user who just got accepted to a group
    if (details == 'added_to_group') {
      saveGroupId(groupId);
      saveGroupName(groupName);
      //If he doesn't have a group yet -> create the necessary lists
      if (usersGroups == null) {
        usersGroups = List<String>();
        usersGroupIds = List<int>();
      }
      //Add the group to the list and save them to the cache
      usersGroups.add(groupName);
      usersGroupIds.add(groupId);
      saveUsersGroups();
      saveUsersGroupIds();
      //If the group is one of the user's groups
    } else if (usersGroupIds != null && usersGroupIds.contains(groupId)) {
      saveGroupId(groupId);
      saveGroupName(groupName);
      if (currency != null) saveGroupCurrency(currency);
    }
    clearAllCache();
    if (currentUserId != null) {
      if (page == 'home') {
        int selectedIndex = 0;
        if (details == 'payment') {
          selectedIndex = 1;
        }
        getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(
            builder: (context) =>
                MainGroupPage(selectedHistoryIndex: selectedIndex)));
      } else if (page == 'shopping') {
        int selectedTab = 1;
        getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(
            builder: (context) => MainGroupPage(selectedIndex: selectedTab)));
      } else if (page == 'store') {
        getIt.get<NavigationService>().navigateToAnyadForce(
            MaterialPageRoute(builder: (context) => InAppPurchasePage()));
      } else if (page == 'group_settings') {
        int selectedTab = 2;
        getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(
            builder: (context) => MainGroupPage(selectedIndex: selectedTab)));
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getToken();
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
  }

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
  print(usersGroupIds);
  print(usersGroups);

  String initURL;
  try {
    initURL = await getInitialLink();
  } catch (_) {}
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  runApp(EasyLocalization(
    child: ChangeNotifierProvider<AppStateNotifier>(
        create: (context) => AppStateNotifier(),
        child: LenderApp(
          themeName: themeName,
          initURL: initURL,
        )),
    supportedLocales: [Locale('en'), Locale('de'), Locale('it'), Locale('hu')],
    path: 'assets/translations',
    fallbackLocale: Locale('en'),
    useOnlyLangCode: true,
    saveLocale: true,
  ));
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

  void initUniLinks() {
    _sub = linkStream.listen((String link) {
      _link = link;
      setState(() {
        if (currentUserId != null) {
          getIt.get<NavigationService>().navigateToAnyad(MaterialPageRoute(
              builder: (context) => JoinGroup(
                  inviteURL: _link,
                  fromAuth: (currentGroupId == null) ? true : false)));
        } else {
          getIt.get<NavigationService>().navigateToAnyad(MaterialPageRoute(
              builder: (context) => LoginOrRegisterPage(
                    inviteURL: _link,
                  )));
        }
      });
    }, onError: (err) {
      log(err);
    });
  }

  void _createNotificationChannels(
      String groupId, List<String> channels) async {
    AndroidNotificationChannelGroup androidNotificationChannelGroup =
        AndroidNotificationChannelGroup(
            groupId, (groupId + '_notification').tr());
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        .createNotificationChannelGroup(androidNotificationChannelGroup);

    for (String channel in channels) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(AndroidNotificationChannel(
            channel,
            (channel + '_notification').tr(),
            (channel + '_notification_explanation').tr(),
            groupId: groupId,
          ));
    }
  }

  Future<void> setupInitialMessage() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      onSelectNotification(initialMessage.data['payload']);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isAndroid) {
        final Stream purchaseUpdates = InAppPurchase.instance.purchaseStream;
        _subscription = purchaseUpdates.listen((purchases) {
          // List<PurchaseDetails> purchasesList = purchases as List<PurchaseDetails>;
          for (PurchaseDetails details in purchases) {
            if (details.status == PurchaseStatus.purchased) {
              String url = (!useTest ? APP_URL : TEST_URL) + '/user';
              Map<String, String> header = {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + (apiToken == null ? '' : apiToken)
              };
              Map<String, dynamic> body = {};
              switch (details.productID) {
                case 'remove_ads':
                  showAds = false;
                  body['ad_free'] = 1;
                  break;
                case 'gradients':
                  useGradients = true;
                  body['gradients_enabled'] = 1;
                  break;
                case 'ad_gradient_bundle':
                  showAds = false;
                  body['ad_free'] = 1;
                  useGradients = true;
                  body['gradients_enabled'] = 1;
                  break;
                case 'group_boost':
                  body['boosts'] = 2;
                  break;
                case 'big_lender_bundle':
                  showAds = false;
                  body['ad_free'] = 1;
                  useGradients = true;
                  body['gradients_enabled'] = 1;
                  body['boosts'] = 1;
                  break;
              }
              try {
                http.put(Uri.parse(url),
                    headers: header, body: jsonEncode(body));
              } catch (_) {
                throw _;
              }
              InAppPurchase.instance.completePurchase(details);
            }
          }
          // _handlePurchaseUpdates(purchases);
        });
        var initializationSettingsAndroid =
            new AndroidInitializationSettings('@drawable/dodo_white');
        var initializationSettingsIOS = new IOSInitializationSettings();
        var initializationSettings = new InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

        flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
        flutterLocalNotificationsPlugin.initialize(initializationSettings,
            onSelectNotification: onSelectNotification);

        initUniLinks();
        _link = widget.initURL;
        Future.delayed(Duration(seconds: 1)).then((value) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            _createNotificationChannels(
                'group_system', ['other', 'group_update']);
            _createNotificationChannels('purchase',
                ['purchase_created', 'purchase_modified', 'purchase_deleted']);
            _createNotificationChannels('payment',
                ['payment_created', 'payment_modified', 'payment_deleted']);
            _createNotificationChannels('shopping',
                ['shopping_created', 'shopping_fulfilled', 'shopping_shop']);
          });

          setupInitialMessage();
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            print("onMessage: $message");
            Map<String, dynamic> decoded = jsonDecode(message.data['payload']);
            print(decoded);
            var androidPlatformChannelSpecifics =
                new AndroidNotificationDetails(
                    decoded['channel_id'], //only this is needed
                    (decoded['channel_id'] +
                        '_notification'), // these don't do anything
                    (decoded['channel_id'] + '_notification_explanation'),
                    styleInformation: BigTextStyleInformation(''));
            var iOSPlatformChannelSpecifics =
                new IOSNotificationDetails(presentSound: false);
            var platformChannelSpecifics = new NotificationDetails(
                android: androidPlatformChannelSpecifics,
                iOS: iOSPlatformChannelSpecifics);
            flutterLocalNotificationsPlugin.show(
                int.parse(message.data['id']) ?? 0,
                message.notification.title,
                message.notification.body,
                platformChannelSpecifics,
                payload: message.data['payload']);
          });
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            onSelectNotification(message.data['payload']);
          });
          if (currentUserId != null) {
            _getUserData();
          }
          _supportedVersion().then((value) {
            if (!(value ?? true)) {
              getIt
                  .get<NavigationService>()
                  .navigateToAnyadForce(MaterialPageRoute(
                    builder: (context) => VersionNotSupportedPage(),
                  ));
            }
          });
        });
      }
    }
  }

  Future<bool> _supportedVersion() async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
      };
      http.Response response = await http.get(
          Uri.parse((useTest ? TEST_URL : APP_URL) +
              '/supported?version=' +
              currentVersion.toString()),
          headers: header);
      bool decoded = jsonDecode(response.body);
      return decoded;
    } catch (_) {
      throw _;
    }
  }

  Future<void> _getUserData() async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + (apiToken == null ? '' : apiToken)
      };
      http.Response response = await http.get(
          Uri.parse((useTest ? TEST_URL : APP_URL) + '/user'),
          headers: header);
      var decoded = jsonDecode(response.body);
      showAds = decoded['data']['ad_free'] == 0;
      useGradients = decoded['data']['gradients_enabled'] == 1;
      personalisedAds = decoded['data']['personalised_ads'] == 1;
      trialVersion = decoded['data']['trial'] == 1;
      if (currentGroupId == null &&
          decoded['data']['last_active_group'] != null) {
        currentGroupId = decoded['data']['last_active_group'];
        getIt.get<NavigationService>().navigateToAnyadForce(MaterialPageRoute(
              builder: (context) => MainGroupPage(),
            ));
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (!useGradients &&
          preferences.getString('theme').contains('Gradient')) {
        preferences.setString('theme', 'greenLightTheme');
      }
    } catch (_) {
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
                ? LoginOrRegisterPage(
                    inviteURL: _link,
                  )
                : (_link != null)
                    ? JoinGroup(
                        inviteURL: _link,
                        fromAuth: (currentGroupId == null) ? true : false,
                      )
                    : (currentGroupId == null)
                        ? JoinGroup(
                            fromAuth: true,
                          )
                        : MainGroupPage(),
          ),
        );
      },
    );
  }
}
