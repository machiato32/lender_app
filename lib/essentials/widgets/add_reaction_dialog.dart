import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../config.dart';
import '../app_theme.dart';
import '../group_objects.dart';
import '../http_handler.dart';

class AddReactionDialog extends StatefulWidget {
  final String type;
  final List<Reaction> reactions;
  final int reactToId;
  final Function(String reaction) callback;
  AddReactionDialog({this.type, this.reactions, this.reactToId, this.callback});
  @override
  _AddReactionDialogState createState() => _AddReactionDialogState();
}

class _AddReactionDialogState extends State<AddReactionDialog> {


  void _onSendReaction(String reaction){
    Navigator.pop(context);
    widget.callback(reaction);
  }
  Future<bool> _sendReaction (String reaction) async {
    try{
      Map<String, dynamic> body = {
        widget.type.substring(0, widget.type.length-1)+"_id":widget.reactToId,
        "reaction":reaction
      };
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpPost(context: context, uri: '/'+widget.type+'/reaction', body: body, useGuest: useGuest);
      // Future.delayed(delayTime()).then((value) => _onSendReaction(reaction));
      return true;
    }catch(_){
      throw _;
    }
  }

  List<Widget> _generateReactions(){
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    return widget.reactions.map((e){
        TextStyle style = e.userId==idToUse?
        Theme.of(context).textTheme.button
        :Theme.of(context).textTheme.bodyText1;
      return Container(

        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        margin: EdgeInsets.fromLTRB(4,0,4,4),
        decoration: BoxDecoration(
          gradient: e.userId==idToUse?AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true):LinearGradient(colors: [Colors.transparent, Colors.transparent]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(e.nickname, style: style, overflow: TextOverflow.ellipsis,)),
            Text(e.reaction)
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reactions'.tr(),
              style:
              Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.only(top:10, bottom: 10, left: 5, right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(300)),

                      ),
                      // color: Colors.grey,
                      child: Row(
                          children: Reaction.possibleReactions.map((e) => Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: (){
                                _sendReaction(e);
                                _onSendReaction(e);
                                // showDialog(
                                //     context: context,
                                //     barrierDismissible: false,
                                //     child: FutureSuccessDialog(
                                //       future: _sendReaction(e),
                                //       dataTrueText: 'reaction_scf',
                                //       onDataTrue: (){
                                //         _onSendReaction(e);
                                //       },
                                //     )
                                // );
                              },
                              child: Ink(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color: widget.reactions.firstWhere((el) => el.userId==idToUse && el.reaction==e, orElse: ()=>null)!=null?
                                    (Theme.of(context).brightness==Brightness.light)?Colors.grey[300]:Colors.grey[700]:
                                    (Theme.of(context).brightness==Brightness.light)?Colors.white:Colors.transparent,

                                  ),
                                  child: Text(e, style: TextStyle(fontSize: MediaQuery.of(context).size.width/13),)
                              ),
                            ),
                          )).toList()
                      )
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.reactions.length!=0,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,

                      children: _generateReactions(),
                    ),
                  )
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
