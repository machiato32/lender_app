import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

import 'auth/login_or_register_page.dart';
import 'config.dart';

Map<String, String> header = {
  "Content-Type": "application/json",
  "Authorization": "Bearer " + apiToken
};

Future<http.Response> httpGet({@required BuildContext context, @required String uri}) async {
  try {
    http.Response response = await http.get(APPURL + uri, headers: header);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: Text('login_required'.tr()),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
            (r) => false);
      }
      throw error['error'];
    }
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPost({@required BuildContext context, @required String uri, @required Map<String, dynamic> body}) async {
  try {
    String bodyEncoded = json.encode(body);
    http.Response response = await http.post(APPURL + uri, headers: header, body: bodyEncoded);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: Text('login_required'.tr()),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }
      throw error['error'];
    }
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPut({@required BuildContext context, @required String uri, @required Map<String, dynamic> body}) async {
  try {
    String bodyEncoded = json.encode(body);
    http.Response response = await http.put(APPURL + uri, headers: header, body: bodyEncoded);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: Text('login_required'.tr()),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }
      throw error['error'];
    }
  } catch (_) {
    throw _;
  }
}