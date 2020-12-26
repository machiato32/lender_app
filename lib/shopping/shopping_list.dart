import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/transaction/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping/shopping_all_info.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';

import '../essentials/widgets/error_message.dart';

class ShoppingRequestData {
  int requestId;
  String name;
  String requesterUsername, requesterNickname;
  int requesterId;
  DateTime updatedAt;

  ShoppingRequestData(
      {this.updatedAt,
      this.requesterId,
      this.requesterUsername,
      this.name,
      this.requestId,
      this.requesterNickname});

  factory ShoppingRequestData.fromJson(Map<String, dynamic> json) {
    return ShoppingRequestData(
      requestId: json['request_id'],
      requesterId: json['requester_id'],
      requesterUsername: json['requester_username'],
      requesterNickname: json['requester_nickname'],
      name: json['name'],
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }
}

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<List<ShoppingRequestData>> _shoppingList;

  TextEditingController _addRequestController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  Future<List<ShoppingRequestData>> _getShoppingList({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: '/requests?group=' + currentGroupId.toString(),
        context: context,
        overwriteCache: overwriteCache,
        useGuest: useGuest
      );
      Map<String, dynamic> decoded = jsonDecode(response.body);

      List<ShoppingRequestData> shopping = new List<ShoppingRequestData>();
      decoded['data'].forEach((element) {
        shopping.add(ShoppingRequestData.fromJson(element));
      });
      shopping = shopping.reversed.toList();
      return shopping;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postShoppingRequest(String name) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {'group': currentGroupId, 'name': name};
      await httpPost(uri: '/requests', context: context, body: body, useGuest: useGuest);
      return true;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postImShopping(String store) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {'store':store};
      await httpPost(context: context, body: body, uri: '/groups/'+currentGroupId.toString()+'/send_shopping_notification', useGuest: useGuest);
      return true;

    } catch (_) {
      throw _;
    }
  }

  void callback() {
    setState(() {
      _shoppingList = null;
      _shoppingList = _getShoppingList(overwriteCache: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _shoppingList = null;
    _shoppingList = _getShoppingList();
  }

  @override
  void didUpdateWidget(ShoppingList oldWidget) {
    _shoppingList = null;
    _shoppingList = _getShoppingList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await deleteCache(uri: '/groups');
        setState(() {
          _shoppingList = null;
          _shoppingList = _getShoppingList(overwriteCache: true);
        });

      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Form(
          key: _formKey,
          child: Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Center(
                          child: Text(
                        'shopping_list'.tr(),
                        style: Theme.of(context).textTheme.headline6,
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'shopping_list_explanation'.tr(),
                          style: Theme.of(context).textTheme.subtitle2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              validator: (value) {
                                value=value.trim();
                                if (value.isEmpty) {
                                  return 'field_empty'.tr();
                                }
                                if (value.length < 2) {
                                  return 'minimal_length'.tr(args: ['2']);
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'wish'.tr(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.onSurface),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2),
                                ),
                              ),
                              controller: _addRequestController,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).textTheme.bodyText1.color),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GradientButton(
                            // color: Theme.of(context).colorScheme.secondary,
                            child: Icon(Icons.add,
                                color: Theme.of(context).colorScheme.onSecondary),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState.validate()) {
                                String name = _addRequestController.text;
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    child: FutureSuccessDialog(
                                      future: _postShoppingRequest(name),
                                      dataTrueText: 'add_scf',
                                      onDataTrue: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _shoppingList = null;
                                          _shoppingList = _getShoppingList(overwriteCache: true);
                                          _addRequestController.text = '';
                                        });
                                      },
                                      onDataFalse: () {
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                    ));
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientButton(
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController controller = TextEditingController();
                                  GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                  return Form(
                                    key: formKey,
                                    child: AlertDialog(
                                      title: Text('where'.tr()),
                                      content: TextFormField(
                                        validator: (value){
                                          value=value.trim();
                                          if (value.isEmpty) {
                                            return 'field_empty'.tr();
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'store'.tr(),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                Theme.of(context).colorScheme.onSurface),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.primary,
                                                width: 2),
                                          ),
                                        ),
                                        controller: controller,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color:
                                            Theme.of(context).textTheme.bodyText1.color),
                                        cursorColor: Theme.of(context).colorScheme.secondary,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20)
                                        ],
                                      ),
                                      actions: [
                                        RaisedButton(
                                          onPressed: (){
                                            if(formKey.currentState.validate()){
                                              String store = controller.text;
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                child: FutureSuccessDialog(
                                                  future: _postImShopping(store),
                                                  dataTrueText: 'store_scf',
                                                  onDataTrue: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                )

                                              );

                                            }

                                          },
                                          child: Text('send'.tr(), style: Theme.of(context).textTheme.button),
                                          color: Theme.of(context).colorScheme.secondary,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text('i_m_shopping'.tr(), style: Theme.of(context).textTheme.button),
                            // color: Theme.of(context).colorScheme.secondary,

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _shoppingList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          if(snapshot.data.length==0){
                            return ListView(
                              padding: EdgeInsets.all(15),
                              children: [
                                Text('nothing_to_show'.tr(), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                              ],
                            );
                          }
                          return ListView(
                              padding: EdgeInsets.all(15),
                              children: _generateShoppingList(snapshot.data));
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'balances',
                            callback: (){
                              setState(() {
                                _shoppingList = null;
                                _shoppingList = _getShoppingList();
                              });
                            },
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _generateShoppingList(List<ShoppingRequestData> data) {
    return data.map((element) {
      return ShoppingListEntry(
        data: element,
        callback: this.callback,
      );
    }).toList();
  }
}

class ShoppingListEntry extends StatefulWidget {
  final ShoppingRequestData data;
  final Function callback;

  const ShoppingListEntry({this.data, this.callback});

  @override
  _ShoppingListEntryState createState() => _ShoppingListEntryState();
}

class _ShoppingListEntryState extends State<ShoppingListEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;

  String date;
  String name;
  String user;


  @override
  Widget build(BuildContext context) {
    name = widget.data.name;
    user = widget.data.requesterUsername;
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    if (widget.data.requesterId == idToUse) {
      style = Theme.of(context).textTheme.button;
      dateColor = Theme.of(context).textTheme.button.color;
      icon = Icon(Icons.receipt, color: style.color);
      boxDecoration = BoxDecoration(
        gradient: AppTheme.gradientFromTheme(Theme.of(context)),
        borderRadius: BorderRadius.circular(15),
      );
    } else {
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      icon = Icon(
        Icons.receipt,
        color: style.color,
      );
      boxDecoration = BoxDecoration();
    }
    return Dismissible(
      key: UniqueKey(),
      secondaryBackground: Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(widget.data.requesterId != idToUse?Icons.done:Icons.delete,
            size: 30, color: Theme.of(context).textTheme.bodyText1.color,
          )
        ),
      ),
      dismissThresholds: {DismissDirection.startToEnd: 0.6, DismissDirection.endToStart: 0.6},
      background: Align(
          alignment: Alignment.centerLeft,
          child: Icon(widget.data.requesterId != idToUse?Icons.attach_money:Icons.delete,
            size: 30, color: Theme.of(context).textTheme.bodyText1.color,
          )
      ),
      onDismissed: (direction){
        if(widget.data.requesterId != idToUse){
          showDialog(
              barrierDismissible: false,
              context: context,
              child: FutureSuccessDialog(
                future: _fulfillShoppingRequest(widget.data.requestId),
                dataTrueText: 'fulfill_scf',
                onDataTrue: () {
                  Navigator.pop(context);
                },
              )
          ).then((value) {
            widget.callback();
            if(direction==DismissDirection.startToEnd){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionRoute(
                            type: TransactionType
                                .fromShopping,
                            shoppingData:
                            widget
                                .data,
                          )
                  )
              );
            }
          });

        }else{
          showDialog(
              barrierDismissible: false,
              context: context,
              child: FutureSuccessDialog(
                future:
                _deleteShoppingRequest(
                    widget
                        .data.requestId),
                dataTrueText: 'delete_scf',
                onDataTrue: () {
                  Navigator.pop(context);
                },
              )
          ).then((value) => widget.callback());
        }
      },
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width,
        decoration: boxDecoration,
        margin: EdgeInsets.only(
          bottom: 4,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () async {
              showModalBottomSheetCustom(
                  context: context,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  builder: (context) => SingleChildScrollView(
                      child: ShoppingAllInfo(widget.data))).then((val) {
                if (val == 'deleted') widget.callback();
              });
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Flexible(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            icon,
                            SizedBox(
                              width: 20,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                      child: Text(
                                    name,
                                    style: style.copyWith(fontSize: 22),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  Flexible(
                                      child: Text(
                                    widget.data.requesterNickname,
                                    style:
                                        TextStyle(color: dateColor, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _fulfillShoppingRequest(int id) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpPut(uri: '/requests/' + id.toString(), context: context, body: {}, useGuest: useGuest);
      return true;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _deleteShoppingRequest(int id) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpDelete(uri: '/requests/' + id.toString(), context: context, useGuest: useGuest);
      return true;

    } catch (_) {
      throw _;
    }
  }
}
