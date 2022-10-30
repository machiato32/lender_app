import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/groups/create_group.dart';
import 'package:csocsort_szamla/groups/group_settings_page.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/history/history.dart';
import 'package:csocsort_szamla/main/group_settings_speed_dial.dart';
import 'package:csocsort_szamla/main/in_app_purchase_page.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../balances.dart';
import '../config.dart';
import '../essentials/ad_management.dart';
import '../essentials/currencies.dart';
import '../essentials/group_objects.dart';
import '../essentials/http_handler.dart';
import '../essentials/widgets/error_message.dart';
import '../main/iapp_not_supported_dialog.dart';
import '../main/main_speed_dial.dart';
import '../main/report_a_bug_page.dart';
import '../main/trial_version_dialog.dart';
import '../main/tutorial_dialog.dart';

class MainPage extends StatefulWidget {
  final int selectedHistoryIndex;
  final int selectedIndex;
  final String scrollTo;
  MainPage(
      {this.selectedHistoryIndex = 0, this.selectedIndex = 0, this.scrollTo});

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

  String scrollTo;

  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<Group>> _getGroups() async {
    http.Response response =
        await httpGet(context: context, uri: generateUri(GetUriKeys.groups));
    Map<String, dynamic> decoded = jsonDecode(response.body);
    List<Group> groups = [];
    for (var group in decoded['data']) {
      groups.add(Group(
        groupName: group['group_name'],
        groupId: group['group_id'],
        groupCurrency: group['currency'],
      ));
    }
    usersGroups = groups.map<String>((group) => group.groupName).toList();
    usersGroupIds = groups.map<int>((group) => group.groupId).toList();
    saveUsersGroups();
    saveUsersGroupIds();
    //The group ID cannot change, but the group name and currency can change
    if (groups.any((element) => element.groupId == currentGroupId)) {
      var group =
          groups.firstWhere((element) => element.groupId == currentGroupId);
      saveGroupName(group.groupName);
      saveGroupCurrency(group.groupCurrency);
    }
    return groups;
  }

  Future<String> _getCurrentGroup() async {
    http.Response response = await httpGet(
      context: context,
      uri: generateUri(GetUriKeys.groupCurrent,
          args: [currentGroupId.toString()]),
    );
    Map<String, dynamic> decoded = jsonDecode(response.body);
    saveGroupName(decoded['data']['group_name']);
    return currentGroupName;
  }

  Future<dynamic> _getSumBalance() async {
    try {
      http.Response response = await httpGet(
          context: context, uri: generateUri(GetUriKeys.userBalanceSum));
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data'];
    } catch (_) {
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
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            tileColor: (group.groupName == currentGroupName)
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            title: Text(
              group.groupName,
              style: (group.groupName == currentGroupName)
                  ? Theme.of(context).textTheme.labelLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Theme.of(context).textTheme.labelLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () async {
              saveGroupName(group.groupName);
              saveGroupId(group.groupId);
              saveGroupCurrency(group.groupCurrency);
              setState(() {
                _selectedIndex = 0;
                _tabController.animateTo(_selectedIndex);
              });
            },
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.selectedIndex);
    _groups = null;
    _groups = _getGroups();
    scrollTo = widget.scrollTo;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(Duration(seconds: 1)).then((value) => scrollTo = null);
      bool showTutorial = true;
      await SharedPreferences.getInstance().then((prefs) {
        if (prefs.containsKey('show_tutorial')) {
          showTutorial = prefs.getBool('show_tutorial');
        }
      });
      if (showTutorial) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('show_tutorial', false);
        });
        await showDialog(
          context: context,
          builder: (context) {
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

  void _handleDrawer(bool bigScreen) {
    if (!bigScreen) {
      _scaffoldKey.currentState.openEndDrawer();
    } else {
      _scaffoldKey.currentState.openDrawer();
    }
    FeatureDiscovery.discoverFeatures(context, <String>['drawer', 'settings']);
    _groups = null;
    _groups = _getGroups();
  }

  Future<void> callback() async {
    await clearGroupCache();
    await deleteCache(uri: generateUri(GetUriKeys.groups));
    await deleteCache(uri: generateUri(GetUriKeys.userBalanceSum));
    setState(() {
      _groups = null;
      _groups = _getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool bigScreen = width > tabletViewWidth;
    if (bigScreen && _selectedIndex > 1) {
      _selectedIndex = 0;
      _tabController.animateTo(_selectedIndex);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: bigScreen
            ? IconButton(
                onPressed: () {
                  _handleDrawer(bigScreen);
                },
                icon: DescribedFeatureOverlay(
                  tapTarget: Icon(Icons.menu, color: Colors.black),
                  featureId: 'drawer',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  overflowMode: OverflowMode.extendBackground,
                  title: Text(
                    'discovery_drawer_title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary),
                  ),
                  description: Text(
                    'discovery_drawer_description'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary),
                  ),
                  barrierDismissible: false,
                  child: Icon(Icons.menu),
                ),
              )
            : null,
        actions: [Container()],
        centerTitle: true,
        title: FutureBuilder(
          future: _getCurrentGroup(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data,
                  style: TextStyle(letterSpacing: 0.25, fontSize: 24),
                );
              }
            }
            return Text(
              currentGroupName ?? 'error'.tr(),
              style: TextStyle(letterSpacing: 0.25, fontSize: 24),
            );
          },
        ),
      ),
      bottomNavigationBar: bigScreen
          ? null
          : NavigationBar(
              onDestinationSelected: (_index) {
                if (_index != 3) {
                  setState(() {
                    _selectedIndex = _index;
                    _tabController.animateTo(_index);
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  });
                } else {
                  _handleDrawer(bigScreen);
                }
                if (_selectedIndex == 1) {
                  FeatureDiscovery.discoverFeatures(context, ['shopping_list']);
                } else if (_selectedIndex == 2) {
                  FeatureDiscovery.discoverFeatures(
                      context, ['group_settings']);
                }
              },
              selectedIndex: _selectedIndex,
              destinations: _bottomNavbarItems(),
            ),
      drawer: bigScreen
          ? Drawer(
              child: _drawer(),
            )
          : null,
      endDrawer: !bigScreen
          ? Drawer(
              child: _drawer(),
            )
          : null,
      floatingActionButton: _selectedIndex == (bigScreen ? 1 : 2)
          ? GroupSettingsSpeedDial()
          : Visibility(
              visible: _selectedIndex == 0,
              child: MainPageSpeedDial(
                callback: this.callback,
              ),
            ),
      body: kIsWeb || Platform.isWindows
          ? _body(true, bigScreen)
          : ConnectivityWidget(
              offlineBanner: kIsWeb
                  ? Container()
                  : Container(
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      color: Colors.red,
                      child: Text(
                        'no_connection'.tr(),
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
              builder: (context, isOnline) {
                isOnline = isOnline || kIsWeb; //TODO: index html dolgok
                return _body(isOnline, bigScreen);
              },
            ),
    );
  }

  Widget _body(bool isOnline, bool bigScreen) {
    double width = MediaQuery.of(context).size.width - (bigScreen ? 80 : 0);
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        (kIsWeb || Platform.isWindows ? 64 : 0) - //appbar
        (idToUse() == guestUserId ? 60 : 0) - // guestBanner
        (bigScreen ? 0 : 56) - //bottomNavbar
        adHeight();
    List<Widget> tabWidgets = _tabWidgets(isOnline, bigScreen, height);
    return Row(
      children: [
        bigScreen
            ? NavigationRail(
                labelType: NavigationRailLabelType.all,
                destinations: _navigationRailItems(),
                onDestinationSelected: (_index) {
                  // print(_selectedIndex);
                  setState(() {
                    _selectedIndex = _index;
                    _tabController.animateTo(_index);
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  });
                  if (_selectedIndex == 1) {
                    FeatureDiscovery.discoverFeatures(
                        context, ['group_settings']);
                  }
                },
                selectedIndex: _selectedIndex)
            : Container(),
        Expanded(
          child: Column(
            children: [
              IsGuestBanner(
                key: _isGuestBannerKey,
                callback: callback,
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: !bigScreen
                      ? tabWidgets
                      : [
                          Table(
                            columnWidths: {
                              0: FractionColumnWidth(1 / 2),
                              1: FractionColumnWidth(1 / 2),
                            },
                            children: [
                              TableRow(
                                children: tabWidgets
                                    .take(2)
                                    .map(
                                      (e) => AspectRatio(
                                        aspectRatio: width / 2 / height,
                                        child: e,
                                      ),
                                    )
                                    .toList(),
                              )
                            ],
                          ),
                          tabWidgets.reversed.first,
                          Container(),
                        ],
                ),
              ),
              adUnitForSite('home_screen'),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _tabWidgets(bool isOnline, bool bigScreen, double height) {
    return [
      RefreshIndicator(
        onRefresh: () async {
          if (isOnline) await callback();
          setState(() {});
        },
        child: ListView(
          controller: ScrollController(),
          shrinkWrap: true,
          children: [
            Balances(
              callback: callback,
              bigScreen: bigScreen,
            ),
            History(
              selectedIndex: widget.selectedHistoryIndex,
              callback: callback,
            ),
          ],
        ),
      ),
      ShoppingList(
        isOnline: isOnline,
        bigScreen: bigScreen,
      ),
      GroupSettings(
        bannerKey: _isGuestBannerKey,
        scrollTo: scrollTo,
        bigScreen: bigScreen,
        height: height,
      ),
    ];
  }

  Widget _drawer() {
    return Ink(
      decoration: BoxDecoration(
        color: ElevationOverlay.applyOverlay(
            context, Theme.of(context).colorScheme.surface, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: ScrollController(),
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
                        'Lender',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                      ),
                      Text(
                        'hi'.tr() + ' ' + currentUsername + '!',
                        style: Theme.of(context).textTheme.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.primary),
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
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            cardTheme: CardTheme(
                              elevation: 0,
                              color: Colors.transparent,
                              margin: EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(28)),
                              ),
                            ),
                          ),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: ExpansionTile(
                              title: Text('groups'.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                              leading: Icon(Icons.group,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              children: _generateListTiles(snapshot.data),
                            ),
                          ),
                        );
                      } else {
                        return ErrorMessage(
                          error: snapshot.error.toString(),
                          locationOfError: 'home_groups',
                          callback: () {
                            setState(() {
                              _groups = null;
                              _groups = _getGroups();
                            });
                          },
                        );
                      }
                    }
                    return LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    leading: Icon(
                      Icons.group_add,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'join_group'.tr(),
                      style: Theme.of(context).textTheme.labelLarge.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => JoinGroup()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    leading: Icon(
                      Icons.create,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'create_group'.tr(),
                      style: Theme.of(context).textTheme.labelLarge.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroup(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _getSumBalance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  String currency = snapshot.data['currency'];
                  double balance = snapshot.data['balance'] * 1.0;
                  return Text('Σ: ' + balance.printMoney(currency),
                      style: Theme.of(context).textTheme.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.secondary));
                }
              }
              return Text(
                'Σ: ...',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              );
            },
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              dense: true,
              onTap: () {
                if (trialVersion) {
                  showDialog(
                      builder: (context) => TrialVersionDialog(),
                      context: context);
                } else if (!isIAPPlatformEnabled) {
                  showDialog(
                      builder: (context) => IAPPNotSupportedDialog(),
                      context: context);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InAppPurchasePage()));
                }
              },
              leading: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    BlendMode.srcIn),
                child: Image.asset(
                  'assets/dodo_color.png',
                  width: 25,
                ),
              ),
              subtitle: trialVersion
                  ? Text(
                      'trial_version'.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    )
                  : Text(
                      'in_app_purchase_description'.tr(),
                      style: Theme.of(context).textTheme.labelLarge.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
              title: Text(
                'in_app_purchase'.tr(),
                style: Theme.of(context).textTheme.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              dense: true,
              leading: DescribedFeatureOverlay(
                tapTarget: Icon(Icons.settings, color: Colors.black),
                featureId: 'settings',
                backgroundColor: Theme.of(context).colorScheme.primary,
                overflowMode: OverflowMode.extendBackground,
                allowShowingDuplicate: true,
                contentLocation: ContentLocation.above,
                title: Text(
                  'discovery_settings_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
                description: Text(
                  'discovery_settings_description'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                'settings'.tr(),
                style: Theme.of(context).textTheme.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              leading: Icon(
                Icons.bug_report,
                color: Theme.of(context).colorScheme.error,
              ),
              dense: true,
              title: Text(
                'report_a_bug'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReportABugPage()));
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              dense: true,
              title: Text(
                'logout'.tr(),
                style: Theme.of(context).textTheme.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          ),
        ],
      ),
    );
  }

  List<NavigationRailDestination> _navigationRailItems() {
    return [
      NavigationRailDestination(
        icon: Icon(
          Icons.home,
        ),
        label: Text('home'.tr()),
      ),
      NavigationRailDestination(
        icon: DescribedFeatureOverlay(
          featureId: 'group_settings',
          tapTarget: Icon(Icons.supervisor_account, color: Colors.black),
          targetColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'discover_group_settings_title'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                .copyWith(color: Theme.of(context).colorScheme.onTertiary),
          ),
          description: Text(
            'discover_group_settings_description'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                .copyWith(color: Theme.of(context).colorScheme.onTertiary),
          ),
          overflowMode: OverflowMode.extendBackground,
          child: Icon(Icons.supervisor_account),
        ),
        label: Text('group'.tr()),
      ),
    ];
  }

  List<Widget> _bottomNavbarItems() {
    return [
      NavigationDestination(
        icon: Icon(
          Icons.home,
        ),
        label: 'home'.tr(),
      ),
      NavigationDestination(
          icon: DescribedFeatureOverlay(
              featureId: 'shopping_list',
              tapTarget: Icon(Icons.receipt_long, color: Colors.black),
              targetColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                'discover_shopping_title'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    .copyWith(color: Theme.of(context).colorScheme.onTertiary),
              ),
              description: Text(
                'discover_shopping_description'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    .copyWith(color: Theme.of(context).colorScheme.onTertiary),
              ),
              overflowMode: OverflowMode.extendBackground,
              child: Icon(Icons.receipt_long)),
          label: 'shopping_list'.tr()),
      NavigationDestination(
          //TODO: change user currency
          icon: DescribedFeatureOverlay(
            featureId: 'group_settings',
            tapTarget: Icon(Icons.supervisor_account, color: Colors.black),
            targetColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              'discover_group_settings_title'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  .copyWith(color: Theme.of(context).colorScheme.onTertiary),
            ),
            description: Text(
              'discover_group_settings_description'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  .copyWith(color: Theme.of(context).colorScheme.onTertiary),
            ),
            overflowMode: OverflowMode.extendBackground,
            child: Icon(Icons.supervisor_account),
          ),
          label: 'group'.tr()), //TODO: bettername
      NavigationDestination(
        icon: DescribedFeatureOverlay(
          tapTarget: Icon(Icons.menu, color: Colors.black),
          featureId: 'drawer',
          backgroundColor: Theme.of(context).colorScheme.primary,
          overflowMode: OverflowMode.extendBackground,
          title: Text(
            'discovery_drawer_title'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                .copyWith(color: Theme.of(context).colorScheme.onTertiary),
          ),
          description: Text(
            'discovery_drawer_description'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                .copyWith(color: Theme.of(context).colorScheme.onTertiary),
          ),
          barrierDismissible: false,
          child: Icon(Icons.menu),
        ),
        label: 'more'.tr(),
      )
    ];
  }
}
