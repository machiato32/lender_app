import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../config.dart';
import '../essentials/http_handler.dart';
import '../essentials/models.dart';

class AddModifyPurchase {
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<Member>> members;
  Map<Member, bool> membersMap = Map<Member, bool>();
  Map<Member, double> customAmountMap = Map<Member, double>();
  String selectedCurrency = currentGroupCurrency;
  FocusNode focusNode = FocusNode();
  BuildContext context;

  Future<List<Member>> getMembers(BuildContext context, {bool overwriteCache = false}) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupCurrent),
          context: context,
          overwriteCache: overwriteCache,
          useGuest: useGuest);

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
}
