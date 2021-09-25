import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share/share.dart';

import '../../essentials/widgets/gradient_button.dart';

class ShareGroupDialog extends StatefulWidget {
  final String inviteCode;
  ShareGroupDialog({@required this.inviteCode});

  @override
  _ShareGroupDialogState createState() => _ShareGroupDialogState();
}

class _ShareGroupDialogState extends State<ShareGroupDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'share'.tr(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            PrettyQr(
              data: widget.inviteCode,
              roundEdges: true,
              size: MediaQuery.of(context).size.width > 300 ? 250 : 120,
              elementColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              image: AssetImage('assets/dodo_color_glow3.png'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'share_url'.tr(),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                    onPressed: () {
                      Share.share(
                          'https://www.lenderapp.net/join/' + widget.inviteCode,
                          subject: 'invitation_to_lender'.tr());
                    },
                    child: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.onSecondary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
