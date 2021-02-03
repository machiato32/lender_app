import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/confirm_choice_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/main/in_app_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class BoostGroup extends StatefulWidget {
  @override
  _BoostGroupState createState() => _BoostGroupState();
}

class _BoostGroupState extends State<BoostGroup> {

  Future<Map<String, dynamic>> _getBoostNumber() async {
    try{
      http.Response response = await httpGet(context: context, uri: '/groups/'+currentGroupId.toString()+'/boost', useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data'];
    }catch(_){
      throw _;
    }
  }

  Future<bool> _postBoost() async {
    try{
      await httpPost(context: context, uri: '/groups/'+currentGroupId.toString()+'/boost');
      Future.delayed(delayTime()).then((value) => _onPostBoost());
      return true;
    }catch(_){
      throw _;
    }
  }

  Future<void> _onPostBoost() async {
    await clearAllCache();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainPage()
        ),
        (r) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('boost_group'.tr(), style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
            SizedBox(height: 10),
            Text('boost_group_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,),
            SizedBox(height: 10),
            FutureBuilder(
              future: _getBoostNumber(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasData){
                    return Column(
                      children: [
                        Text('available'.tr(args:[snapshot.data['available_boosts'].toString()]), style: Theme.of(context).textTheme.subtitle2,),
                        SizedBox(height: 10),
                        Visibility(
                          visible: snapshot.data['is_boosted']==1,
                          child: Text('already_boosted'.tr(), style: Theme.of(context).textTheme.subtitle2,),
                        ),
                        Visibility(
                          visible: snapshot.data['is_boosted']==0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientButton(
                                child: Icon(Icons.insights, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  if(snapshot.data['available_boosts']==0){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => InAppPurchasePage())
                                    ).then((value){
                                      setState(() {

                                      });
                                    });
                                  }else{
                                    showDialog(
                                      context: context,
                                      child: ConfirmChoiceDialog(
                                        choice: 'sure_boost',
                                      )
                                    )
                                    .then((value){
                                      if(value??false){
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          child: FutureSuccessDialog(
                                            future: _postBoost(),
                                            dataTrueText: 'boost_scf',
                                            onDataTrue: (){
                                              _onPostBoost();
                                            },
                                          )
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }else{
                    return ErrorMessage(error: snapshot.error.toString(), callback: (){setState(() { });});
                  }
                }
                return CircularProgressIndicator();
              },
            ),

          ],
        ),
      ),
    );
  }
}

