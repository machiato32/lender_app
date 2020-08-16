import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/transaction/add_transaction_page.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/custom_dialog.dart';

class ShoppingAllInfo extends StatefulWidget {
  final ShoppingRequestData data;
  ShoppingAllInfo(this.data);
  @override
  _ShoppingAllInfoState createState() => _ShoppingAllInfoState();
}

class _ShoppingAllInfoState extends State<ShoppingAllInfo> {
  Future<bool> _fulfillShoppingRequest(int id) async {
    try{

      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      http.Response response = await http.put(APPURL+'/requests/'+id.toString(), headers: header);
      if(response.statusCode==200){
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('login_required'.tr()), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<bool> _deleteShoppingRequest(int id) async {
    try{

      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      http.Response response = await http.delete(APPURL+'/requests/'+id.toString(), headers: header);
      if(response.statusCode==204){
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('login_required'.tr()), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.requesterNickname, style: Theme.of(context).textTheme.bodyText1,)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.data.name, style: Theme.of(context).textTheme.bodyText1)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary,),
                  Text(' - '),
                  Flexible(child: Text(DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt), style: Theme.of(context).textTheme.bodyText1)),
                ],
              ),
              SizedBox(height: 10,),
              Visibility(
                visible: widget.data.requesterId==currentUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(
                        onPressed: (){
                          showDialog(
                              context: context,
                              child: Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text('want_delete'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                      SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    child: FutureSuccessDialog(
                                                      future: _deleteShoppingRequest(widget.data.requestId),
                                                      dataTrueText: 'delete_scf',
                                                      onDataTrue: (){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context, 'deleted');
                                                      },
                                                    )
                                                );
                                              },
                                              child: Text('yes'.tr(), style: Theme.of(context).textTheme.button)
                                          ),
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: (){ Navigator.pop(context);},
                                              child: Text('no'.tr(), style: Theme.of(context).textTheme.button)
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          );
                        },
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('delete'.tr(), style: Theme.of(context).textTheme.button,),
                        icon: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.data.requesterId!=currentUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: (){
                        Future<bool> _success = _fulfillShoppingRequest(widget.data.requestId);
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            child: Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: FutureBuilder(
                                future: _success,
                                builder: (context, snapshot){
                                  if(snapshot.connectionState==ConnectionState.done){
                                    if(snapshot.hasData){
                                      if(snapshot.data){
                                        return Container(
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('want_expense'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white), textAlign: TextAlign.center,),
                                              SizedBox(height: 15,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  RaisedButton(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context, 'deleted');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionRoute(
                                                          type: ExpenseType.fromShopping, shoppingData: widget.data,
                                                        )));
                                                      },
                                                      child: Text('yes'.tr(), style: Theme.of(context).textTheme.button)
                                                  ),
                                                  RaisedButton(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context, 'deleted');
                                                      },
                                                      child: Text('no'.tr(), style: Theme.of(context).textTheme.button)
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }else{
                                        return Container(
                                          color: Colors.transparent ,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(child: Text("error".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                              SizedBox(height: 15,),
                                              FlatButton.icon(
                                                icon: Icon(Icons.clear, color: Colors.white,),
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                },
                                                label: Text('back'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    }else{
                                      return Container(
                                        color: Colors.transparent ,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(child: Text(snapshot.error.toString(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                            SizedBox(height: 15,),
                                            FlatButton.icon(
                                              icon: Icon(Icons.clear, color: Colors.white,),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              label: Text('back'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                              color: Colors.red,
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  }else{
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            )
                        );
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      label: Text('bought'.tr(), style: Theme.of(context).textTheme.button),
                      icon: Icon(Icons.check, color: Theme.of(context).textTheme.button.color),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}

