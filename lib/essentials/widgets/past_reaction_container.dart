import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:flutter/material.dart';

import 'add_reaction_dialog.dart';

class PastReactionContainer extends StatelessWidget {
  final List<Reaction> reactions;
  final int reactedToId;
  final Function callback;
  final bool isSecondaryColor;
  PastReactionContainer({this.reactions, this.reactedToId, this.callback, this.isSecondaryColor});
  @override
  Widget build(BuildContext context) {
    Map<String, int> numberOfReaction ={
      '❤':0, '❓':0, '💸':0, '👍':0, '😥':0, '🐶':0
    };
    for(Reaction reaction in reactions){
      if(numberOfReaction.keys.contains(reaction.reaction))
        numberOfReaction[reaction.reaction]++;
    }
    var sortedKeys = numberOfReaction.keys.toList(growable:false)
      ..sort((k1, k2) => numberOfReaction[k2].compareTo(numberOfReaction[k1]));
    List<List<dynamic>> sortedReactions = [];
    for(String key in sortedKeys){
      sortedReactions.add([key,numberOfReaction[key]]);
    }
    int sum = 0;
    for(var list in sortedReactions){
      sum+=list[1];
    }

    List<String> orderedReactions = [];
    int index=0;
    if(sortedReactions[index][1]>0){
      orderedReactions.add(sortedReactions[index][0]);
      index++;
    }
    if(sortedReactions[index][1]>0){
      orderedReactions.add(sortedReactions[index][0]);
    }
    if(sum>1){
      orderedReactions.add(sum.toString());
    }
    return Visibility(
      visible: reactions.length!=0,
      child: Container(
        margin: EdgeInsets.only(right: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: (){
                showDialog(context: context, child: AddReactionDialog(type: 'purchases', reactions: reactions, reactToId: reactedToId, callback: callback,));
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                  padding: EdgeInsets.only(top:4, bottom: 4, left: 6, right: 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: (Theme.of(context).brightness==Brightness.light)?Colors.grey[300]:Colors.grey[800],
                      boxShadow:  (Theme.of(context).brightness==Brightness.light && !isSecondaryColor)
                          ?[
                            BoxShadow(
                              color: Colors.grey[500],
                              offset: Offset(0.0, 1.5),
                              blurRadius: 1.5,
                            )
                          ]
                          : []
                  ),
                  child: Row(
                      children: orderedReactions.map((e) {
                        if(e!=null && double.tryParse(e)!=null){
                          return Text(e, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 20));
                        }
                        return Text(e, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15),);
                      }).toList()
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
