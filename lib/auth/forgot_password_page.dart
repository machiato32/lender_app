import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:csocsort_szamla/http_handler.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String username;
  ForgotPasswordPage({@required this.username});
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  Future<String> _getPasswordReminder(String username) async {
    http.Response response = await httpGet(context: context, uri: '/password_reminder?id='+username);
    Map<String, dynamic> decoded = jsonDecode(response.body);
    return decoded['password_reminder'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('forgot_password'.tr()),),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          FutureBuilder(
            future: _getPasswordReminder(widget.username),
            builder: (context, snapshot){
              if(snapshot.connectionState==ConnectionState.done){
                if(snapshot.hasData){
                  return Text(snapshot.data);
                }else{
                  return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(snapshot.error.toString()),
                      ),
                      onTap: () {
                        setState(() {});
                      });
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          )
        ],
      ),
    );
  }
}

