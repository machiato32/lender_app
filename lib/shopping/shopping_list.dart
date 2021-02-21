import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/widgets/add_reaction_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/past_reaction_container.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping/shopping_all_info.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';

import '../essentials/widgets/error_message.dart';
import 'edit_request_dialog.dart';

class ShoppingList extends StatefulWidget {
  final bool isOnline;
  ShoppingList({this.isOnline});
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<List<ShoppingRequestData>> _shoppingList;

  TextEditingController _addRequestController = TextEditingController();

  ScrollController _scrollController;

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

  _onPostShoppingRequest(){
    Navigator.pop(context);
    setState(() {
      _shoppingList = null;
      _shoppingList = _getShoppingList(overwriteCache: true);
      _addRequestController.text = '';
    });
  }

  Future<bool> _postShoppingRequest(String name) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {'group': currentGroupId, 'name': name};
      await httpPost(uri: '/requests', context: context, body: body, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onPostShoppingRequest());
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
      Future.delayed(delayTime()).then((value) => _onPostImShopping());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostImShopping(){
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<bool> _undoDeleteRequest(int id) async {
    try{
      await httpPost(context: context, uri: '/requests/restore/'+id.toString());
      Future.delayed(delayTime()).then((value) => _onUndoDeleteRequest());
      return true;
    }catch(_){
      throw _;
    }
  }

  void _onUndoDeleteRequest(){
    Scaffold.of(context).removeCurrentSnackBar();
    Navigator.pop(context, true);
  }

  void callback({int restoreId}) {
    setState(() {
      _shoppingList = null;
      _shoppingList = _getShoppingList(overwriteCache: true);
    });
    if(restoreId!=null){
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
            duration: Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('request_deleted'.tr(), style: Theme.of(context).textTheme.button.copyWith(fontSize: 15),),
                InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        child: FutureSuccessDialog(
                          future: _undoDeleteRequest(restoreId),
                          dataTrueText: 'undo_scf',
                          onDataTrue: (){
                            _onUndoDeleteRequest();
                          },
                        )
                    ).then((value) {
                      if (value ?? false) callback();
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.all(3),
                      child: Row(
                        children: [
                          Icon(Icons.undo, color: Theme.of(context).textTheme.button.color,),
                          SizedBox(width: 3),
                          Text('undo'.tr(), style: Theme.of(context).textTheme.button.copyWith(fontSize: 15),),
                        ],
                      )
                  ),
                )
              ],
            ),
          )
      );
    }
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
        if(widget.isOnline) await deleteCache(uri: '/groups');
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
                                LengthLimitingTextInputFormatter(255)
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
                                        _onPostShoppingRequest();
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
                              TextEditingController controller = TextEditingController();
                              GlobalKey<FormState> formKey = GlobalKey<FormState>();
                              showDialog(
                                context: context,
                                child:
                                  Form(
                                    key: formKey,
                                    child: Dialog(
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('where'.tr()),
                                            TextFormField(
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
                                            SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                GradientButton(
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
                                                              _onPostImShopping();
                                                            },
                                                          )
                                                      );
                                                    }
                                                  },
                                                  child: Text('send'.tr(), style: Theme.of(context).textTheme.button),
                                                ),
                                              ],
                                            )
                                          ],

                                        ),
                                      ),


                                    ),
                                  )
                              );//TODO: dialog in own file
                            },
                            child: Text('i_m_shopping'.tr(), style: Theme.of(context).textTheme.button),
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
                              controller: _scrollController,
                              key: PageStorageKey('shoppingList'),
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
                            locationOfError: 'shopping_list',
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
    data.sort((e1, e2) {
      int e2Length=e2.reactions.where((reaction) => reaction.reaction=='❗').length;
      int e1Length=e1.reactions.where((reaction) => reaction.reaction=='❗').length;
      if(e2Length>e1Length) return 1;
      if(e2Length<e1Length) return -1;
      if(e1.updatedAt.isAfter(e2.updatedAt)) return -1;
      return 1;
    });
    return data.map((element) {
      return ShoppingListEntry(
        data: element,
        callback: this.callback,
      );
    }).toList();
  }
}

class ShoppingRequestData {
  int requestId;
  String name;
  String requesterUsername, requesterNickname;
  int requesterId;
  DateTime updatedAt;
  List<Reaction> reactions;

  ShoppingRequestData(
      {this.updatedAt,
        this.requesterId,
        this.requesterUsername,
        this.name,
        this.requestId,
        this.requesterNickname,
        this.reactions});

  factory ShoppingRequestData.fromJson(Map<String, dynamic> json) {
    return ShoppingRequestData(
        requestId: json['request_id'],
        requesterId: json['requester_id'],
        requesterUsername: json['requester_username'],
        requesterNickname: json['requester_nickname'],
        name: json['name'],
        updatedAt: DateTime.parse(json['updated_at']).toLocal(),
        reactions: json['reactions']
            .map<Reaction>((reaction) => Reaction.fromJson(reaction))
            .toList()
    );
  }

  @override
  String toString() {
    return name+'; '+updatedAt.toString()+'; '+reactions.join(', ');
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

  String name;
  String user;

  void callbackForReaction(String reaction){//TODO: currentNickname
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    Reaction oldReaction=widget.data.reactions.firstWhere((element) => element.userId==idToUse, orElse: () => null);
    bool alreadyReacted = oldReaction!=null;
    bool sameReaction = alreadyReacted?oldReaction.reaction==reaction:false;
    if(sameReaction){
      widget.data.reactions.remove(oldReaction);
      setState(() {

      });
    }else if(!alreadyReacted){
      widget.data.reactions.add(Reaction(nickname: idToUse==currentUserId?currentUsername:guestNickname, reaction: reaction, userId: idToUse));
      setState(() {

      });
    }else{
      widget.data.reactions.add(Reaction(nickname: oldReaction.nickname, reaction: reaction, userId: idToUse));
      widget.data.reactions.remove(oldReaction);
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    name = widget.data.name;
    user = widget.data.requesterUsername;
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    if (widget.data.requesterId == idToUse) {
      style = Theme.of(context).textTheme.button;
      dateColor = Theme.of(context).textTheme.button.color;
      icon = Icon(Icons.receipt_long, color: style.color, size: 30,);
      boxDecoration = BoxDecoration(
        boxShadow: (Theme.of(context).brightness==Brightness.light)
            ?[ BoxShadow(
                color: Colors.grey[500],
                offset: Offset(0.0, 1.5),
                blurRadius: 1.5,
              )]
            : [],
        gradient: AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true),
        borderRadius: BorderRadius.circular(15),
      );
    } else {
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      icon = Icon(
        Icons.receipt_long_outlined,
        color: style.color,
        size: 30
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
          child: Icon(widget.data.requesterId != idToUse?Icons.attach_money:Icons.edit,
            size: 30, color: Theme.of(context).textTheme.bodyText1.color,
          )
      ),
      onDismissed: (direction){
        if(widget.data.requesterId != idToUse){
          showDialog(
              barrierDismissible: false,
              context: context,
              child: FutureSuccessDialog(
                future: _deleteFulfillShoppingRequest(widget.data.requestId, context),
                dataTrueText: 'fulfill_scf',
                onDataTrue: () {
                  _onDeleteFulfillShoppingRequest();
                },
              )
          ).then((value) {
            widget.callback(restoreId: widget.data.requestId);
            if(direction==DismissDirection.startToEnd && value==true){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddPurchaseRoute(
                            type: PurchaseType.fromShopping,
                            shoppingData:widget.data,
                          )
                  )
              );
            }
          });

        }else{
          if(direction == DismissDirection.endToStart){
            showDialog(
                barrierDismissible: false,
                context: context,
                child: FutureSuccessDialog(
                  future: _deleteFulfillShoppingRequest(widget.data.requestId, context),
                  dataTrueText: 'delete_scf',
                  onDataTrue: () {
                    _onDeleteFulfillShoppingRequest();
                  },
                )
            ).then((value) {
              if (value ?? false)
                widget.callback(restoreId: widget.data.requestId);
            });
          }else if(direction==DismissDirection.startToEnd){
            showDialog(
                context: context,
                child: EditRequestDialog(textBefore: widget.data.name, requestId: widget.data.requestId,),
            ).then((value){
              if(value??false){
                widget.callback();
              }
            });
          }

        }
      },
      child: Stack(
        children: [
          Container(
            height: 65,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecoration,
            margin: EdgeInsets.only(top: widget.data.reactions.length==0?0:14,bottom: 4,),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onLongPress: (){
                  showDialog(
                    context: context,
                    child: AddReactionDialog(
                      type: 'requests',
                      reactions: widget.data.reactions,
                      reactToId: widget.data.requestId,
                      callback: this.callbackForReaction,
                    )
                  );
                },
                onTap: () async {
                  showModalBottomSheetCustom(
                      context: context,
                      backgroundColor: Theme.of(context).cardTheme.color,
                      builder: (context) => SingleChildScrollView(
                          child: ShoppingAllInfo(widget.data)
                      )
                  ).then((val) {
                    if (val == 'deleted') widget.callback(restoreId: widget.data.requestId);
                    if(val=='edited') widget.callback();
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
          PastReactionContainer(
            reactions: widget.data.reactions,
            reactedToId: widget.data.requestId,
            isSecondaryColor:widget.data.requesterId == idToUse,
            type: 'requests',
            callback: this.callbackForReaction,
          ),
        ],
      ),
    );
  }





  Future<bool> _deleteFulfillShoppingRequest(int id, var buildContext) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpDelete(uri: '/requests/' + id.toString(), context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onDeleteFulfillShoppingRequest());
      return true;

    } catch (_) {
      throw _;
    }
  }

  void _onDeleteFulfillShoppingRequest(){
    Navigator.pop(context, true);
  }
}
