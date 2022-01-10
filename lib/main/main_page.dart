import 'dart:convert';

import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class MainPage extends StatefulWidget {
  const MainPage();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<List<Group>> _groups;
  Future<dynamic> _sum;

  void initState() {
    super.initState();
    _groups = null;
    _groups = _getGroups();
    _sum = null;
    _sum = _getSumBalance();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [Container()],
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))),
        ),
        title: Text(
          'Lender',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              letterSpacing: 0.25,
              fontSize: 24),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {});
          return;
        },
        child: ListView(
          children: [
            FutureBuilder(
              future: _sum,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double balance = snapshot.data['balance'] * 1.0;
                  String currency = snapshot.data['currency'];
                  if (snapshot.hasData) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'hi'.tr() + ' ' + currentUsername + '!',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'sum_balance'
                                  .tr(args: [balance.printMoney(currency)]),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'num_groups'
                                  .tr(args: [7.toString(), 3.toString()]),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'num_friends'.tr(
                                  args: ['5', balance.printMoney(currency)]),
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ErrorMessage(
                      error: snapshot.error.toString(),
                      locationOfError: 'sum',
                      callback: () {
                        setState(() {
                          _sum = null;
                          _sum = _getSumBalance();
                        });
                      },
                    );
                  }
                }
                return LinearProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            FutureBuilder(
              future: _groups,
              builder: (context, AsyncSnapshot<List<Group>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    print(snapshot.data[0].groupName);
                    return AspectRatio(
                      aspectRatio: 2,
                      child: PageView(
                        allowImplicitScrolling: true,
                        padEnds: false,
                        pageSnapping: false,
                        controller: PageController(viewportFraction: 1 / 2),
                        children: snapshot.data
                            .map((e) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          e.groupName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  } else {
                    return ErrorMessage(
                      error: snapshot.error.toString(),
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
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
