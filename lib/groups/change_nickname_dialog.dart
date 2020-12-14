import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../future_success_dialog.dart';
import '../gradient_button.dart';
import '../http_handler.dart';

class ChangeNicknameDialog extends StatefulWidget {
  final String username;
  final int memberId;
  ChangeNicknameDialog({@required this.username, @required this.memberId});

  @override
  _ChangeNicknameDialogState createState() => _ChangeNicknameDialogState();
}

class _ChangeNicknameDialogState extends State<ChangeNicknameDialog> {
  Future<bool> _updateNickname(String nickname, int memberId) async {
    try {
      Map<String, dynamic> body = {
        "member_id": memberId,
        "nickname": nickname
      };
      await httpPut(
          uri: '/groups/' + currentGroupId.toString() + '/members',
          context: context,
          body: body);
      return true;

    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _nicknameController = TextEditingController();
    var _nicknameFormKey = GlobalKey<FormState>();
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'edit_nickname'.tr(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Form(
              key: _nicknameFormKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'field_empty'.tr();
                    }
                    if (value.length < 1) {
                      return 'minimal_length'.tr(args: ['1']);
                    }
                    return null;
                  },
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: widget.username
                        .split('#')[0][0]
                        .toUpperCase() +
                            widget.username
                            .split('#')[0]
                            .substring(1),
                    labelText: 'nickname'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                          Theme.of(context).colorScheme.onSurface,
                          width: 1),
                      //  when the TextFormField in unfocused
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                          Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color),
                  cursorColor:
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'back'.tr(),
                    style: Theme.of(context).textTheme.button.copyWith(color:Colors.white),
                  ),
                  color: Colors.grey[700],
                ),
                GradientButton(
                  onPressed: () {
                    if (_nicknameFormKey.currentState.validate()) {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                      String nickname =
                          _nicknameController.text[0].toUpperCase() +
                              _nicknameController.text.substring(1);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          child: FutureSuccessDialog(
                            future: _updateNickname(
                                nickname, widget.memberId),
                            onDataTrue: () {
                              _nicknameController.text = '';
                              Navigator.pop(context);
                              Navigator.pop(context, 'madeAdmin');
                            },
                            dataTrueText: 'nickname_scf',
                          ));
                    }
                  },
                  child: Text(
                    'modify'.tr(),
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
