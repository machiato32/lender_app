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
    _controller.expanded =
        guestNickname != null && guestGroupId == currentGroupId;
    return Expandable(
      controller: _controller,
      collapsed: Container(),
      expanded: MaterialBanner(
          elevation: 1,
          backgroundColor: ElevationOverlay.applyOverlay(
              context, Theme.of(context).colorScheme.surface, 1),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  deleteGuestUserId();
                  deleteGuestNickname();
                  deleteGuestApiToken();
                  deleteGuestGroupId();
                });
                widget.callback();
              },
              child: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          ],
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary,),
                  Text(
                    'acting_as'.tr(args: [guestNickname ?? currentUsername]),
                    style: Theme.of(context).textTheme.titleSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  // SizedBox(width: 5,),
                  // Text(, style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),),
                ],
              )
            ],
          )),
    );
  }
}
