import 'dart:async';
import 'dart:convert';

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
import 'package:csocsort_szamla/main/main_page.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../balances.dart';
import '../config.dart';
import '../essentials/ad_management.dart';
import '../essentials/app_theme.dart';
import '../essentials/currencies.dart';
import '../essentials/group_objects.dart';
import '../essentials/http_handler.dart';
import '../essentials/widgets/error_message.dart';
import '../main/main_speed_dial.dart';
import '../main/report_a_bug_page.dart';
import '../main/trial_version_dialog.dart';
import '../main/tutorial_dialog.dart';

class MainGroupPage extends StatefulWidget {
  final int selectedHistoryIndex;
  final int selectedIndex;
  final String scrollTo;
  MainGroupPage(
      {this.selectedHistoryIndex = 0, this.selectedIndex = 0, this.scrollTo});

  @override
  _MainGroupPageState createState() => _MainGroupPageState();
}

class _MainGroupPageState extends State<MainGroupPage>
    with TickerProviderStateMixin {
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

  void _handleDrawer() {
    FeatureDiscovery.discoverFeatures(context, <String>['drawer', 'settings']);
    _scaffoldKey.currentState.openEndDrawer();
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
    return Scaffold(
      // backgroundColor: _selectedIndex != 1
      //     ? Theme.of(context).scaffoldBackgroundColor
      //     : Theme.of(context).cardTheme.color,
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [Container()],
        // elevation: _selectedIndex == 1 ? 0 : 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))),
        ),
        title: FutureBuilder(
          future: _getCurrentGroup(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      letterSpacing: 0.25,
                      fontSize: 24),
                );
              }
            }
            return Text(
              currentGroupName ?? 'error'.tr(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  letterSpacing: 0.25,
                  fontSize: 24),
            );
          },
        ),
        leading: null,
        // leading: DescribedFeatureOverlay(
        //   tapTarget: Icon(Icons.menu, color: Colors.black),
        //   featureId: 'drawer',
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   overflowMode: OverflowMode.extendBackground,
        //   title: Text('discovery_drawer_title'.tr()),
        //   description: Text('discovery_drawer_description'.tr()),
        //   barrierDismissible: false,
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.menu,
        //       color: Theme.of(context).colorScheme.onSecondary,
        //     ),
        //     onPressed: _handleDrawer,
        //   ),
        // ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        type: BottomNavigationBarType.fixed,
        onTap: (_index) {
          if (_index != 3) {
            setState(() {
              _selectedIndex = _index;
              _tabController.animateTo(_index);
              _scaffoldKey.currentState.removeCurrentSnackBar();
            });
          } else {
            _handleDrawer();
          }

          if (_selectedIndex == 1) {
            FeatureDiscovery.discoverFeatures(context, ['shopping_list']);
          } else if (_selectedIndex == 2) {
            FeatureDiscovery.discoverFeatures(context, ['group_settings']);
          }
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr()),
          BottomNavigationBarItem(
              icon: DescribedFeatureOverlay(
                  featureId: 'shopping_list',
                  tapTarget: Icon(Icons.receipt_long, color: Colors.black),
                  title: Text('discover_shopping_title'.tr()),
                  description: Text('discover_shopping_description'.tr()),
                  overflowMode: OverflowMode.extendBackground,
                  child: Icon(Icons.receipt_long)),
              label: 'shopping_list'.tr()),
          BottomNavigationBarItem(
              //TODO: change user currency
              icon: DescribedFeatureOverlay(
                featureId: 'group_settings',
                tapTarget: Icon(Icons.supervisor_account, color: Colors.black),
                title: Text('discover_group_settings_title'.tr()),
                description: Text('discover_group_settings_description'.tr()),
                overflowMode: OverflowMode.extendBackground,
                child: Icon(Icons.supervisor_account),
              ),
              label: 'group'.tr()),
          BottomNavigationBarItem(
            icon: DescribedFeatureOverlay(
              tapTarget: Icon(Icons.menu, color: Colors.black),
              featureId: 'drawer',
              // backgroundColor: Theme.of(context).colorScheme.primary,
              overflowMode: OverflowMode.extendBackground,
              title: Text('discovery_drawer_title'.tr()),
              description: Text('discovery_drawer_description'.tr()),
              barrierDismissible: false,
              child: Icon(Icons.menu),
            ),
            label: 'more'.tr(),
          )
        ],
      ),
      endDrawer: Drawer(
        elevation: 16,
        child: Ink(
          color:
              // ? Color.fromARGB(255, 50, 50, 50)
              Theme.of(context).cardTheme.color,
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
                              image: AssetImage('assets/dodo_color_glow.png'),
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
                            'hi'.tr() + ' ' + currentUsername + '!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
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
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Text('groups'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        );
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinGroup()));
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
                    ListTile(
                      title: Text('asd'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPage()));
                      },
                    )
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
                          style: Theme.of(context).textTheme.bodyText1);
                    }
                  }
                  return Text(
                    'Σ: ...',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16),
                  );
                },
              ),
              Divider(),
              ListTile(
                dense: true,
                onTap: () {
                  if (trialVersion) {
                    showDialog(
                        builder: (context) => TrialVersionDialog(),
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
                        Theme.of(context).textTheme.bodyText1.color,
                        BlendMode.srcIn),
                    child: Image.asset(
                      'assets/dodo_color.png',
                      width: 25,
                    )),
                subtitle: trialVersion
                    ? Text(
                        'trial_version'.tr().toUpperCase(),
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      )
                    : null,
                title: Text(
                  'in_app_purchase'.tr(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReportABugPage()));
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
      floatingActionButton: _selectedIndex == 2
          ? GroupSettingsSpeedDial()
          : Visibility(
              visible: _selectedIndex == 0,
              child: MainPageSpeedDial(
                callback: this.callback,
              ),
            ),
      body: ConnectivityWidget(
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
                  )),
          builder: (context, isOnline) {
            isOnline = isOnline || kIsWeb; //TODO: index html dolgok
            return Column(
              children: [
                IsGuestBanner(
                  key: _isGuestBannerKey,
                  callback: callback,
                ),
                Expanded(
                  child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            if (isOnline) await callback();
                            setState(() {});
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
                        ShoppingList(
                          isOnline: isOnline,
                        ),
                        GroupSettings(
                          bannerKey: _isGuestBannerKey,
                          scrollTo: scrollTo,
                        ),
                      ]),
                ),
                adUnitForSite('home_screen'),
              ],
            );
          }),
    );
  }
}
