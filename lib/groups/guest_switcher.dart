import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/essentials/group_objects.dart';

import '../essentials/widgets/error_message.dart';
import '../essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';

class GuestSwitcher extends StatefulWidget {
  final GlobalKey<State> bannerKey;
  GuestSwitcher({this.bannerKey});
  @override
  _GuestSwitcherState createState() => _GuestSwitcherState();
}

class _GuestSwitcherState extends State<GuestSwitcher> {

  Member _selectedGuest;
  Future<List<Member>> _guests;
  bool _first=true;

  Future<List<Member>> _getGuests() async {
    try {

      http.Response response = await httpGet(
        uri: '/groups/' + currentGroupId.toString(),
        context: context,
        useCache: false
      );
      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['guests']) {
        members.add(
          Member(
            apiToken: member['api_token'],
            nickname: member['username'],
            memberId: member['user_id']
          )
        );

      }
      return members;

    } catch (_) {
      throw _;
    }
  }
  @override
  void initState() {
    super.initState();
    _guests=null;
    _guests=_getGuests();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'guest_switcher'.tr(),
                style:
                Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'guest_switcher_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            Center(
              child: FutureBuilder(
                future: _guests,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if(_first==true){
                        _selectedGuest = (snapshot.data as List<Member>).firstWhere((element) => element.nickname==guestNickname && guestGroupId==currentGroupId, orElse: () => null);
                        _first=false;
                      }
                       return Wrap(
                        spacing: 10,
                        children: snapshot.data
                            .map<ChoiceChip>((Member member) =>
                            ChoiceChip(
                              label: Text(member.nickname),
                              pressElevation: 30,
                              selected: _selectedGuest == member,
                              onSelected: (bool newValue) {
                                FocusScope.of(context).unfocus();
                                clearAllCache();
                                if(_selectedGuest!=member){
                                  _selectedGuest = member;
                                  saveGuestGroupId(currentGroupId);
                                  saveGuestApiToken(member.apiToken);
                                  saveGuestNickname(member.nickname);
                                  saveGuestUserId(member.memberId);
                                }else{
                                  _selectedGuest = null;
                                  deleteGuestGroupId();
                                  deleteGuestApiToken();
                                  deleteGuestNickname();
                                  deleteGuestUserId();
                                }
                                setState(() {
                                  widget.bannerKey.currentState.setState(() {

                                  });
                                });
                              },
                              labelStyle: _selectedGuest ==
                                  member
                                  ? Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary)
                                  : Theme.of(context)
                                  .textTheme
                                  .bodyText1,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .secondary,
                            ))
                            .toList(),
                      );
                    } else {
                      return ErrorMessage(
                        error: snapshot.error.toString(),
                        locationOfError: 'guest_switcher',
                        callback: (){
                          setState(() {
                            _guests = null;
                            _guests = _getGuests();
                          });
                        },
                      );
                    }
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
