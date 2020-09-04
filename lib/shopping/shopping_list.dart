import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:csocsort_szamla/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping/shopping_all_info.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class ShoppingRequestData {
  int requestId;
  String name;
  String requesterId, requesterNickname;
  DateTime updatedAt;

  ShoppingRequestData(
      {this.updatedAt,
      this.requesterId,
      this.name,
      this.requestId,
      this.requesterNickname});

  factory ShoppingRequestData.fromJson(Map<String, dynamic> json) {
    return ShoppingRequestData(
      requestId: json['request_id'],
      requesterId: json['requester_id'],
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

  Future<List<ShoppingRequestData>> _getShoppingList() async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };
      http.Response response = await http.get(
          APPURL + '/requests?group=' + currentGroupId.toString(),
          headers: header);
      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = jsonDecode(response.body);

        List<ShoppingRequestData> shopping = new List<ShoppingRequestData>();
        decoded['data']['active'].forEach((element) {
          shopping.add(ShoppingRequestData.fromJson(element));
        });
        shopping = shopping.reversed.toList();
        return shopping;
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

  Future<bool> _postShoppingRequest(String name) async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };
      Map<String, dynamic> body = {'group': currentGroupId, 'name': name};
      String encodedBody = jsonEncode(body);
      http.Response response = await http.post(APPURL + '/requests',
          headers: header, body: encodedBody);
      if (response.statusCode == 201) {
        return true;
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

  void callback() {
    setState(() {
      _shoppingList = null;
      _shoppingList = _getShoppingList();
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
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
                            if (value.isEmpty) {
                              return 'field_empty'.tr();
                            }
                            if (value.length < 3) {
                              return 'minimal_length'.tr(args: ['3']);
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
                            LengthLimitingTextInputFormatter(20)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      RaisedButton(
                        color: Theme.of(context).colorScheme.secondary,
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
                                      _shoppingList = _getShoppingList();
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
                  SizedBox(
                    height: 20,
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
                      return ListView(
                          padding: EdgeInsets.all(15),
                          children: _generateShoppingList(snapshot.data));
                    } else {
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(snapshot.error.toString()),
                          ),
                          onTap: () {
                            setState(() {
                              _shoppingList = null;
                              _shoppingList = _getShoppingList();
                            });
                          });
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
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
    user = widget.data.requesterId;
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    if (widget.data.requesterId == currentUser) {
      style = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).textTheme.bodyText1
          : Theme.of(context).textTheme.button;
      dateColor = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).textTheme.button.color;
      icon = Icon(Icons.receipt, color: style.color);
      boxDecoration = BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.transparent
            : Theme.of(context).colorScheme.secondary,
        border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 1.5),
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
    return Container(
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
    );
  }
}
