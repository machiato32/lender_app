import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

import 'auth/login_or_register_page.dart';
import 'config.dart';

bool needsLogin = false;

String errorHandler(String error){
  switch(error){
    case '0':
      return 'input_error'.tr();
    case '1':
      return 'user_not_member'.tr();
    case '2':
      return 'guest_cannot_be_added'.tr();
    case '3':
      return 'group_limit_reached'.tr();
    case '4':
      return 'user_already_member'.tr();
    case '5':
      return 'nickname_taken'.tr();
    case '6':
      return 'guests_cannot_be_admins'.tr();
    case '7':
      return 'cannot_leave_until_payed'.tr();
    case '8':
      return 'choose_guest'.tr();
    case '9':
      return 'request_already_fulfilled'.tr();
    case '10':
      return 'request_cannot_fulfilled_requester'.tr();
    case '11':
      return 'check_old_password'.tr();
    case '12':
      return 'new_password_cannot_same'.tr();
    case '13':
      return 'not_buyer_of_transaction'.tr();
    case '14':
      return 'not_payer_of_transaction'.tr();
    case '15':
      return 'did_not_request_this'.tr();
    default:
      return error;
  }
}

Future<http.Response> httpGet({@required BuildContext context, @required String uri}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiToken
    };
    http.Response response = await http.get(APPURL + uri, headers: header);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        if(!needsLogin){
          needsLogin=true;
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
      }
      throw errorHandler(error['error']);
    }
  } on FormatException {
    throw 'format_exception'.tr()+' F01';
  } on SocketException {
    throw 'cannot_connect'.tr()+ ' F02';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPost({@required BuildContext context, @required String uri, Map<String, dynamic> body}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiToken
    };
    http.Response response;
    if(body!=null){

      String bodyEncoded = json.encode(body);
      response = await http.post(APPURL + uri, headers: header, body: bodyEncoded);
    }else{
      response = await http.post(APPURL + uri, headers: header);
    }

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        if(!needsLogin){
          needsLogin=true;
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
      }
      throw errorHandler(error['error']);
    }
  } on FormatException {
    throw 'format_exception'.tr()+' F01';
  } on SocketException {
    throw 'cannot_connect'.tr()+ ' F02';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPut({@required BuildContext context, @required String uri,  Map<String, dynamic> body}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiToken
    };
    http.Response response;
    if(body!=null){
      String bodyEncoded = json.encode(body);
      response = await http.put(APPURL + uri, headers: header, body: bodyEncoded);
    }else{
      response = await http.put(APPURL + uri, headers: header);
    }

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        if(!needsLogin){
          needsLogin=true;
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
      }
      throw errorHandler(error['error']);
    }
  } on FormatException {
    throw 'format_exception'.tr()+' F01';
  } on SocketException {
    throw 'cannot_connect'.tr()+ ' F02';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpDelete({@required BuildContext context, @required String uri}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiToken
    };
    http.Response response = await http.delete(APPURL + uri, headers: header);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        if(!needsLogin){
          needsLogin=true;
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
      }
      throw errorHandler(error['error']);
    }
  } on FormatException {
    throw 'format_exception'.tr()+' F01';
  } on SocketException {
    throw 'cannot_connect'.tr()+ ' F02';
  } catch (_) {
    throw _;
  }
}