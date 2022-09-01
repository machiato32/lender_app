import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config.dart';
import '../../essentials/http_handler.dart';
import '../../essentials/widgets/future_success_dialog.dart';
import '../../essentials/widgets/gradient_button.dart';
import '../main_group_page.dart';

class AddGuestDialog extends StatefulWidget {
  AddGuestDialog();

  @override
  _AddGuestDialogState createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<AddGuestDialog> {
  TextEditingController _nicknameController = TextEditingController();
  Future<bool> _addGuest(String username) async {
    try {
      Map<String, dynamic> body = {
        "language": context.locale.languageCode,
        "username": username
      };
      await httpPost(
          uri: '/groups/' + currentGroupId.toString() + '/add_guest',
          context: context,
          body: body);
      Future.delayed(delayTime()).then((value) => _onAddGuest());
      return true;
    } catch (_) {
      throw _;
    }
  }

  Future<void> _onAddGuest() async {
    await clearGroupCache();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var _nicknameFormKey = GlobalKey<FormState>();
    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'add_guest'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            SizedBox(
              height: 10,
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
                    hintText: 'nickname'.tr(),
                    // fillColor: Theme.of(context).colorScheme.onSurface,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  // style: TextStyle(
                  //     fontSize: 20,
                  //     color: Theme.of(context).textTheme.bodyText1.color),
                  // cursorColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                    onPressed: () {
                      if (_nicknameFormKey.currentState.validate()) {
                        // Navigator.pop(context);
                        FocusScope.of(context).requestFocus(FocusNode());
                        showDialog(
                            builder: (context) => FutureSuccessDialog(
                                  future: _addGuest(_nicknameController.text),
                                  onDataTrue: () async {
                                    _onAddGuest();
                                  },
                                  dataTrueText: 'add_guest_scf',
                                ),
                            barrierDismissible: false,
                            context: context);
                      }
                    },
                    child: Icon(
                      Icons.check,
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
