
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';


import 'auth/login_or_register_page.dart';
import 'config.dart';
import 'groups/join_group.dart';
import 'main.dart';


bool needsLogin = false;

Widget errorToast(String msg, BuildContext context){

  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.red,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.clear,
          color: Colors.white,
        ),
        SizedBox(
          width: 12.0,
        ),
        Flexible(
            child: Text(msg.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white))),
      ],
    ),
  );
}

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

void memberNotInGroup(BuildContext context){
  print('asd');
  usersGroupIds.remove(currentGroupId);
  usersGroups.remove(currentGroupName);
  SharedPreferences.getInstance().then((prefs) {
    prefs.setStringList('users_groups', usersGroups);
    prefs.setStringList('users_group_ids', usersGroupIds.map<String>((e) => e.toString()).toList());
  });
  clearAllCache();
  FlutterToast ft = FlutterToast(context);
  ft.showToast(
      child: errorToast('not_in_group'.tr(), context),
      toastDuration: Duration(seconds: 2),
      gravity: ToastGravity.BOTTOM);
  if(usersGroups.length>0){
    currentGroupName=usersGroups[0];
    currentGroupId=usersGroupIds[0];
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage()),
            (r) => false);
  }else{
    currentGroupName=null;
    currentGroupId=null;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => JoinGroup()),
            (r) => false);
  }

}
Future<http.Response> fromCache({@required String uri, @required bool overwriteCache}) async {
  String fileName = uri.replaceAll('/', '-');
  var cacheDir = await getTemporaryDirectory();
  File file = File(cacheDir.path+'/'+fileName);
  if(!overwriteCache && (await file.exists() &&  DateTime.now().difference(await file.lastModified()).inMinutes<5)){
    // print('from cache');
    return http.Response(file.readAsStringSync(), 200);
  }
  // print('from API');
  return null;
}
Future toCache({@required String uri, @required http.Response response}) async {
  // print('to cache');
  String fileName = uri.replaceAll('/', '-');
  var cacheDir = await getTemporaryDirectory();
  File file = File(cacheDir.path+'/'+fileName);
  file.writeAsString(response.body, flush: true, mode: FileMode.write);
}

Future deleteCache({@required String uri}) async {
  String fileName = uri.replaceAll('/', '-');
  var cacheDir = await getTemporaryDirectory();
  File file = File(cacheDir.path+'/'+fileName);
  if(await file.exists()){
    // print('delete cache');
    file.delete();
  }
}

Future clearAllCache() async {
  var cacheDir = await getTemporaryDirectory();
  cacheDir.delete(recursive: true);
}

Future<http.Response> httpGet({@required BuildContext context, @required String uri, bool overwriteCache=false, bool useCache=true}) async {
  try {
    if(useCache){
      http.Response responseFromCache = await fromCache(uri: uri, overwriteCache: overwriteCache);
      if(responseFromCache!=null){
        return responseFromCache;
      }
    }

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + (apiToken==null?'':apiToken)
    };
    http.Response response = await http.get((useTest?TEST_URL:APP_URL) + uri, headers: header);
    if (response.statusCode<300 && response.statusCode>=200) {
      if(useCache) toCache(uri: uri, response: response);
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);

      }else if(error['error']=='1'){
        memberNotInGroup(context);
      }
      throw errorHandler(error['error']);
    }
  } on FormatException {
    throw 'format_exception'.tr();
  } on SocketException {
    throw 'cannot_connect';
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
      response = await http.post((useTest?TEST_URL:APP_URL) + uri, headers: header, body: bodyEncoded);
    }else{
      response = await http.post((useTest?TEST_URL:APP_URL) + uri, headers: header);
    }

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='1'){
        memberNotInGroup(context);
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
      response = await http.put((useTest?TEST_URL:APP_URL) + uri, headers: header, body: bodyEncoded);
    }else{
      response = await http.put((useTest?TEST_URL:APP_URL) + uri, headers: header);
    }

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='1'){
        memberNotInGroup(context);
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
    http.Response response = await http.delete((useTest?TEST_URL:APP_URL) + uri, headers: header);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='1'){
        memberNotInGroup(context);
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