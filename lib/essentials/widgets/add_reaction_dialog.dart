import 'dart:math';

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
  void _onSendReaction(String reaction) {
    Navigator.pop(context);
    widget.callback(reaction);
  }

  Future<bool> _sendReaction(String reaction) async {
    try {
      Map<String, dynamic> body = {
        widget.type.substring(0, widget.type.length - 1) + "_id":
            widget.reactToId,
        "reaction": reaction
      };
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      await httpPost(
          context: context,
          uri: '/' + widget.type + '/reaction',
          body: body,
          useGuest: useGuest);
      // Future.delayed(delayTime()).then((value) => _onSendReaction(reaction));
      return true;
    } catch (_) {
      throw _;
    }
  }

  List<Widget> _generateReactions() {
    return widget.reactions.map((e) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
        decoration: BoxDecoration(
          gradient: e.userId == idToUse()
              ? AppTheme.gradientFromTheme(currentThemeName, useSecondary: true)
              : LinearGradient(
                  colors: [Colors.transparent, Colors.transparent]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(
              e.nickname,
              style: e.userId == idToUse()
                  ? Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary)
                  : Theme.of(context).textTheme.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            )),
            Text(e.reaction)
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reactions'.tr(),
              style: Theme.of(context).textTheme.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(300)),
                      ),
                      // color: Colors.grey,
                      child: Row(
                          children: Reaction.possibleReactions
                              .map((e) => Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        _sendReaction(e);
                                        _onSendReaction(e);
                                      },
                                      child: Ink(
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            color: widget.reactions.firstWhere(
                                                        (el) =>
                                                            el.userId ==
                                                                idToUse() &&
                                                            el.reaction == e,
                                                        orElse: () => null) !=
                                                    null
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Colors.transparent,
                                          ),
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                                fontSize: min(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        13,
                                                    50)),
                                          )),
                                    ),
                                  ))
                              .toList())),
                ],
              ),
            ),
            Visibility(
              visible: widget.reactions.length != 0,
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
