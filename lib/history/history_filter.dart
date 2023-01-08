import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/models.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

import '../essentials/http_handler.dart';
import '../essentials/widgets/member_chips.dart';
import 'package:http/http.dart' as http;

class HistoryFilter extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Category selectedCategory;
  final int selectedMember;
  final Function(Member) onValuesChanged;
  const HistoryFilter({
    this.startDate,
    this.endDate,
    this.selectedCategory,
    this.selectedMember,
    this.onValuesChanged,
  });

  @override
  State<HistoryFilter> createState() => _HistoryFilterState();
}

class _HistoryFilterState extends State<HistoryFilter> {
  DateTime _startDate;
  DateTime _endDate;
  Category _selectedCategory;
  Future<List<Member>> _members;
  List<Member> _membersChosen;

  Future<List<Member>> _getMembers() async {
    try {
      http.Response response =
          await httpGet(uri: generateUri(GetUriKeys.groupCurrent), context: context);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['members']) {
        members.add(Member(
            nickname: member['nickname'],
            balance: (member['balance'] * 1.0),
            username: member['username'],
            memberId: member['user_id']));
      }
      return members;
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    super.initState();
    _members = _getMembers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedCategory = widget.selectedCategory;
    _startDate = widget.startDate ?? DateTime.now().subtract(Duration(days: 30));
    _endDate = widget.endDate ?? DateTime.now();
    print(_membersChosen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // widget.startDate == null
        //     ? Text('no_date_range'.tr())
        //     : Text(
        //         DateFormat.yMd(context.locale.languageCode).format(_startDate) +
        //             ' - ' +
        //             DateFormat.yMd(context.locale.languageCode).format(_endDate),
        //       ),
        // SizedBox(height: 10),
        // GradientButton(
        //   child: Icon(
        //     Icons.date_range,
        //     color: Theme.of(context).colorScheme.onPrimary,
        //   ),
        //   onPressed: () async {
        //     DateTimeRange range = await showDateRangePicker(
        //       context: context,
        //       firstDate: DateTime.parse('2020-01-17'),
        //       lastDate: DateTime.now(),
        //       currentDate: DateTime.now(),
        //       initialDateRange: DateTimeRange(
        //         start: _startDate,
        //         end: _endDate,
        //       ),
        //       builder: (context, child) => child,
        //     );
        //     if (range != null) {
        //       setState(() {
        //         _startDate = range.start;
        //         _endDate = range.end;
        //       });
        //     }
        //   },
        // ),
        FutureBuilder(
            future: _members,
            builder: (context, AsyncSnapshot<List<Member>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return ErrorMessage(
                  error: snapshot.error.toString(),
                  callback: () {
                    setState(() {
                      _members = null;
                      _members = _getMembers();
                    });
                  },
                  locationOfError: 'history_filter',
                );
              }
              if (_membersChosen == null) {
                _membersChosen = [];
                if (widget.selectedMember != null) {
                  _membersChosen.add(snapshot.data
                      .firstWhere((element) => element.memberId == widget.selectedMember));
                }
                if (_membersChosen.isEmpty) {
                  _membersChosen = [
                    snapshot.data.firstWhere((element) => element.memberId == currentUserId)
                  ];
                }
              }
              return MemberChips(
                allMembers: snapshot.data,
                membersChosen: _membersChosen,
                membersChanged: (newMembersChosen) {
                  setState(() {
                    if (newMembersChosen.isEmpty) {
                      _membersChosen = [
                        snapshot.data.firstWhere((element) => element.memberId == currentUserId)
                      ];
                    } else {
                      _membersChosen = newMembersChosen;
                    }
                  });
                },
                allowMultiple: false,
                noAnimation: true,
              );
            }),
        SizedBox(height: 10),
        GradientButton(
          child: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => widget.onValuesChanged(_membersChosen.first),
        ),
        SizedBox(height: 10),
        Divider(),
      ],
    );
  }
}
