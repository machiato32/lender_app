
import 'dart:io';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';


import '../auth/login_or_register_page.dart';
import '../config.dart';
import '../groups/join_group.dart';
import '../main.dart';

enum GetUriKeys {
  groupHasGuests, groupCurrent, groupMember, groups, userBalanceSum, passwordReminder,
  groupBoost, groupGuests, groupUnapprovedMembers, groupExportXls, purchasesAll, paymentsAll,
  purchasesFirst6, paymentsFirst6, statisticsPayments, statisticsPurchases, statisticsAll,
  requestsAll, purchasesDate, paymentsDate
}
List<String> getUris = [
  '/groups/{}/has_guests',
  '/groups/{}',
  '/groups/{}/member',
  '/groups',
  '/balance',
  '/password_reminder?username={}',
  '/groups/{}/boost',
  '/groups/{}/guests',
  '/groups/{}/members/unapproved',
  '/groups/{}/export/get_link',
  '/purchases?group={}',
  '/payments?group={}',
  '/purchases?group={}&limit=6',
  '/payments?group={}&limit=6',
  '/groups/{}/statistics/payments?from_date={}&until_date={}',
  '/groups/{}/statistics/purchases?from_date={}&until_date={}',
  '/groups/{}/statistics/all?from_date={}&until_date={}',
  '/requests?group={}',
  '/purchases?group={}&from_date={}&until_date={}',
  '/payments?group={}&from_date={}&until_date={}'
];//TODO: same for other types

enum HttpType {get, post, put, delete}

///Generates URI-s from enum values. The default value of [args] is [currentGroupId].
String generateUri(GetUriKeys key, {HttpType type=HttpType.get, List<String> args}){
  if(type==HttpType.get){
    if(args==null){
      args=[currentGroupId.toString()];
    }
    String uri=getUris[key.index];
    if(args!=null){
      for(String arg in args){
        if(uri.contains('{}')) {
          uri = uri.replaceFirst('{}', arg);
        }else {
          break;
        }
      }
    }
    return uri;
  }
  return '';
}


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
                    .copyWith(color: Colors.white)
            )
        ),
      ],
    ),
  );
}


void memberNotInGroup(BuildContext context){
  usersGroupIds.remove(currentGroupId);
  usersGroups.remove(currentGroupName);
  saveUsersGroupIds();
  saveUsersGroups();
  //TODO:currency DOMINIK MEG TUDJA OLDANI, nem tudni, hogy hova kellene mennie, csak currency nelkul
  clearAllCache();
  FlutterToast ft = FlutterToast(context);
  ft.removeQueuedCustomToasts();
  ft.showToast(
      child: errorToast('not_in_group'.tr(), context),
      toastDuration: Duration(seconds: 2),
      gravity: ToastGravity.BOTTOM
  );
  if(usersGroups.length>0){
    currentGroupName=usersGroups[0];
    currentGroupId=usersGroupIds[0];
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage()
        ),
        (r) => false
    );
  }else{
    currentGroupName=null;
    currentGroupId=null;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => JoinGroup(fromAuth: true,)
        ),
        (r) => false
    );
  }

}
Future<http.Response> fromCache({@required String uri, @required bool overwriteCache, bool alwaysReturnCache=false}) async {
  try{
    String fileName = uri.replaceAll('/', '-');
    var cacheDir = await getTemporaryDirectory();
    if(!cacheDir.existsSync()){
      return null;
    }
    // print(cacheDir.listSync());
    File file = File(cacheDir.path+'/'+fileName);
    if(alwaysReturnCache || (!overwriteCache && (file.existsSync() && DateTime.now().difference(await file.lastModified()).inMinutes<5))){
      // print('from cache');
      return http.Response(file.readAsStringSync(), 200);
    }
    // print('from API');
    return null;
  }catch(e){
    //TODO: this is wrong, shouldn't be this way
    print(e.toString());
    return null;
  }

}
Future toCache({@required String uri, @required http.Response response}) async {
  // print('to cache');
  String fileName = uri.replaceAll('/', '-');
  var cacheDir = await getTemporaryDirectory();
  File file = File(cacheDir.path+'/'+fileName);
  file.writeAsString(response.body, flush: true, mode: FileMode.write);
}

///Deletes file at the given [uri] from the cache directory.
///The [multipleArgs] bool is used for [uri]-s where not all of the [args]
///are known at the time of the removal. (See [generateUri] function)
///In this case the [uri] becomes a search word
Future deleteCache({@required String uri, bool multipleArgs=false}) async {
  uri = uri.substring(1);
  String fileName = uri.replaceAll('/', '-');
  var cacheDir = await getTemporaryDirectory();
  if(multipleArgs){
    if(cacheDir.existsSync()){
      List<FileSystemEntity> files = cacheDir.listSync();
      for(var file in files){
        if(file is File){
          String fileName=file.path.split('/').last;
          if(fileName.contains(uri)){
            file.deleteSync();
          }
        }
      }
    }
  }else{
    File file = File(cacheDir.path+'/'+fileName);
    if(file.existsSync()){
      // print('delete cache'+fileName);
      await file.delete();
    }
  }

}


Future clearGroupCache() async {
  var cacheDir = await getTemporaryDirectory();
  if(cacheDir.existsSync()){
    List<FileSystemEntity> files = cacheDir.listSync();
    for(var file in files){
      if(file is File){
        String fileName=file.path.split('/').last;
        if(fileName.contains('groups-'+currentGroupId.toString()) || fileName.contains('group='+currentGroupId.toString())){
          // print('deleting '+fileName);
          file.deleteSync();
        }
      }
    }
  }
}

Future clearAllCache() async {
  // print('all cache');
  var cacheDir = await getTemporaryDirectory();
  if(cacheDir.existsSync()){
    cacheDir.delete(recursive: true);
  }
}

Duration delayTime(){
  return Duration(milliseconds: 700);
}

Future<http.Response> httpGet({@required BuildContext context, @required String uri, bool overwriteCache=false, bool useCache=true, bool useGuest=false}) async {
  try {
    if(useCache){
      http.Response responseFromCache = await fromCache(uri: uri.substring(1), overwriteCache: overwriteCache);
      if(responseFromCache!=null){
        return responseFromCache;
      }
    }
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + (useGuest?guestApiToken:(apiToken==null?'':apiToken))
    };
    http.Response response = await http.get((useTest?TEST_URL:APP_URL) + uri, headers: header);
    if (response.statusCode<300 && response.statusCode>=200) {
      if(useCache) toCache(uri: uri.substring(1), response: response);
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        //TODO: lehet itt dobja a random hibat
        clearAllCache();
        FlutterToast ft = FlutterToast(context);
        ft.removeQueuedCustomToasts();
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);

      }else if(error['error']=='user_not_member'){
        memberNotInGroup(context);
      }
      throw error['error'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    http.Response response = await fromCache(uri: uri.substring(1), overwriteCache: false, alwaysReturnCache: true);
    if(response!=null){
      return response;
    }
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPost({@required BuildContext context, @required String uri, Map<String, dynamic> body, bool useGuest=false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + (useGuest?guestApiToken:(apiToken==null?'':apiToken))
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
        clearAllCache();
        FlutterToast ft = FlutterToast(context);
        ft.removeQueuedCustomToasts();
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='user_not_member'){
        memberNotInGroup(context);
      }
      throw error['error'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPut({@required BuildContext context, @required String uri,  Map<String, dynamic> body, bool useGuest=false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + (useGuest?guestApiToken:(apiToken==null?'':apiToken))
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
        clearAllCache();
        FlutterToast ft = FlutterToast(context);
        ft.removeQueuedCustomToasts();
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='user_not_member'){
        memberNotInGroup(context);
      }
      throw error['error'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpDelete({@required BuildContext context, @required String uri, bool useGuest=false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + (useGuest?guestApiToken:(apiToken==null?'':apiToken))
    };
    http.Response response = await http.delete((useTest?TEST_URL:APP_URL) + uri, headers: header);

    if (response.statusCode<300 && response.statusCode>=200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      if (error['error'] == 'Unauthenticated.') {
        clearAllCache();
        FlutterToast ft = FlutterToast(context);
        ft.showToast(
            child: errorToast('login_required', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
                (r) => false);
      }else if(error['error']=='user_not_member'){
        memberNotInGroup(context);
      }
      throw error['error'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}