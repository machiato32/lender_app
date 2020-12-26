import 'package:shared_preferences/shared_preferences.dart';

import 'package:csocsort_szamla/config.dart';

Future<SharedPreferences> _getPrefs() async {
  return await SharedPreferences.getInstance();
}

Future _saveString(String key, String value) async {
  return await _getPrefs().then((prefs){
    prefs.setString(key, value);
  });
}
Future _saveInt(String key, int value) async {
  return await _getPrefs().then((prefs){
    prefs.setInt(key, value);
  });
}
Future _saveBool(String key, bool value) async {
  return await _getPrefs().then((prefs){
    prefs.setBool(key, value);
  });
}

Future _delete(String key) async {
  return await _getPrefs().then((prefs){
    prefs.remove(key);
  });
}

void saveApiToken(String newApiToken) async {
  apiToken=newApiToken;
  await _saveString('api_token', newApiToken);
}

void saveUsername(String newUsername) async {
  currentUsername=newUsername;
  await _saveString('current_username', newUsername);
}

void saveUserId(int newUserId) async {
  currentUserId=newUserId;
  await _saveInt('current_user_id', newUserId);
}

void saveGroupName(String groupName) async {
  currentGroupName=groupName;
  await _saveString('current_group_name', groupName);
}

void saveGroupId(int groupId) async {
  currentGroupId=groupId;
  await _saveInt('current_group_id', groupId);
}

void saveGroupCurrency(String groupCurrency) async {
  currentGroupCurrency=groupCurrency;
  await _saveString('current_group_currency', groupCurrency);
}

void saveGuestApiToken(String newGuestApiToken) async {
  guestApiToken=newGuestApiToken;
  await _saveString('guest_api_token', newGuestApiToken);
}

void saveGuestGroupId(int newGuestGroupId) async {
  guestGroupId=newGuestGroupId;
  await _saveInt('guest_group_id', newGuestGroupId);
}

void saveGuestUserId(int newUserId) async {
  guestUserId=newUserId;
  await _saveInt('guest_user_id', newUserId);
}

void saveGuestNickname(String newGuestNickname) async {
  guestNickname=newGuestNickname;
  await _saveString('guest_nickname', newGuestNickname);
}
//-------------------------------------------------------//
void deleteApiToken() async {
  apiToken=null;
  await _delete('api_token');
}

void deleteUsername() async {
  currentUsername=null;
  await _delete('current_username');
}

void deleteUserId() async {
  currentUserId=null;
  await _delete('current_user_id');
}

void deleteGroupName() async {
  currentGroupName=null;
  await _delete('current_group_name');
}

void deleteGroupId() async {
  currentGroupId=null;
  await _delete('current_group_id');
}

void deleteGroupCurrency() async {
  currentGroupCurrency=null;
  await _delete('current_group_currency');
}

void deleteGuestApiToken() async {
  guestApiToken=null;
  await _delete('guest_api_token');
}

void deleteGuestGroupId() async {
  guestGroupId=null;
  await _delete('guest_group_id');
}

void deleteGuestUserId() async {
  guestUserId=null;
  await _delete('guest_user_id');
}

void deleteGuestNickname() async {
  guestNickname=null;
  await _delete('guest_nickname');
}

Future loadAllPrefs() async {
  await _getPrefs().then((preferences){
    if (preferences.containsKey('current_username')) {
      currentUsername = preferences.getString('current_username');
      currentUserId = preferences.getInt('current_user_id');
      apiToken = preferences.getString('api_token');
    }
    if(preferences.containsKey('current_user')){
      currentUsername=preferences.getString('current_user');
    }
    if (preferences.containsKey('current_group_name')) {
      currentGroupName = preferences.getString('current_group_name');
      currentGroupId = preferences.getInt('current_group_id');
      currentGroupCurrency = preferences.getString('current_group_currency');
    }
    if(preferences.containsKey('users_groups')){
      usersGroups=preferences.getStringList('users_groups');
      usersGroupIds=preferences.getStringList('users_group_ids').map((e) => int.parse(e)).toList();
    }
    if(preferences.containsKey('guest_nickname')){
      guestNickname=preferences.getString('guest_nickname');
      guestGroupId=preferences.getInt('guest_group_id');
      guestApiToken=preferences.getString('guest_api_token');
      guestUserId=preferences.getInt('guest_user_id');
    }
  });
}

//TODO: save lists, change everywhere
