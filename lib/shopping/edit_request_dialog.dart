import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import '../config.dart';

class EditRequestDialog extends StatefulWidget {
  final String textBefore;
  final int requestId;
  EditRequestDialog({this.textBefore, this.requestId});

  @override
  _EditRequestDialogState createState() => _EditRequestDialogState();
}

class _EditRequestDialogState extends State<EditRequestDialog> {
  var _requestFormKey = GlobalKey<FormState>();

  TextEditingController _requestController = TextEditingController();

  Future<bool> _updateRequest(String newRequest) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {
        'name':newRequest
      };
      await httpPut(uri: '/requests/' + widget.requestId.toString(), context: context, body: body, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    _requestController.text=widget.textBefore;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Text('edit_request'.tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6,),
            ),
            SizedBox(height: 10,),
            Form(
              key: _requestFormKey,
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
                  controller: _requestController,
                  decoration: InputDecoration(
                    hintText: 'edited_request'.tr(),
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
                    LengthLimitingTextInputFormatter(255),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                    onPressed: () {
                      if (_requestFormKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        String newRequest = _requestController.text;
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            child: FutureSuccessDialog(
                              future: _updateRequest(newRequest),
                              onDataTrue: () {
                                clearAllCache();
                                Navigator.pop(context);
                                Navigator.pop(context, true);
                              },
                              dataTrueText: 'request_edit_scf',
                            ));
                      }
                    },
                    child: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary,)

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
