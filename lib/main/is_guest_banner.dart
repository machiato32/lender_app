import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class IsGuestBanner extends StatefulWidget {
  final Function callback;
  IsGuestBanner({Key key, this.callback}) : super(key: key);
  @override
  _IsGuestBannerState createState() => _IsGuestBannerState();
}

class _IsGuestBannerState extends State<IsGuestBanner> {
  ExpandableController _controller = ExpandableController();
  @override
  Widget build(BuildContext context) {
    _controller.expanded=guestNickname!=null && guestGroupId==currentGroupId;
    return Expandable(
      controller: _controller,
      collapsed: Container(),
      expanded: MaterialBanner(
        backgroundColor: Theme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.white,

        actions: [
          FlatButton(
            onPressed: (){
              setState(() {
                deleteGuestUserId();
                deleteGuestNickname();
                deleteGuestApiToken();
                deleteGuestGroupId();
              });
              widget.callback();
            },
            child: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary,),
          )
        ],
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary,),
                  Text('acting as'.tr(), style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),),
                  SizedBox(width: 5,),
                  Text(guestNickname??currentUsername, style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),),
                ],
              )
            ],
          )
      ),
    );
  }
}
