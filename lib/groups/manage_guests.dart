import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/groups/add_guest_dialog.dart';
import 'package:csocsort_szamla/groups/confirm_leave_dialog.dart';
import 'package:csocsort_szamla/groups/select_member_to_merge_dialog.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../essentials/widgets/gradient_button.dart';
import '../main.dart';
import 'guest_switcher.dart';

class ManageGuests extends StatelessWidget {
  final bool showRemove;
  final GlobalKey<State> bannerKey;
  ManageGuests({this.showRemove, this.bannerKey});
  Future<bool> _removeGuest(BuildContext context) async {
    Map<String, dynamic> body ={
      "member_id":guestUserId
    };
    return (await httpPost(context: context, uri: '/groups/'+currentGroupId.toString()+'/members/delete', body: body)).statusCode==204;
  }

  @override
  Widget build(BuildContext context) {
    Widget toastMessage = Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text('needs_choose_guest'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white))),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'manage_guests'.tr(),
                style:
                Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'manage_guests_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            GuestSwitcher(bannerKey: bannerKey),
            Center(
                child: Text(
                  'add_guest'.tr(),
                  style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'add_guest_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.person_add, color: Theme.of(context).colorScheme.onSecondary,),
                  onPressed: (){
                    showDialog(context: context, child: AddGuestDialog());
                  },
                ),
              ],
            ),
            Visibility(
              visible: showRemove,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                        'remove_guest'.tr(),
                        style:
                        Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                        'remove_guest_explanation'.tr(),
                        style:
                        Theme.of(context).textTheme.subtitle2,
                        textAlign: TextAlign.center,
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSecondary,),
                        onPressed: (){
                          if(guestApiToken!=null){
                            showDialog(
                                context: context,
                                child: ConfirmLeaveDialog(
                                  title: 'remove_guest',
                                  choice: 'sure_remove_guest',
                                )
                            ).then((value){
                              if(value??false){
                                showDialog(
                                    context: context,
                                    child: FutureSuccessDialog(
                                      future: _removeGuest(context),
                                      dataTrueText: 'remove_guest_scf',
                                      onDataTrue: (){
                                        clearAllCache();
                                        deleteGuestApiToken();
                                        deleteGuestGroupId();
                                        deleteGuestNickname();
                                        deleteGuestUserId();
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => MainPage()),
                                                (r) => false);
                                      },
                                    )
                                );
                              }
                            });
                          }else{
                            FlutterToast ft = FlutterToast(context);
                            ft.showToast(
                                child: toastMessage
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                        'merge_guest'.tr(),
                        style:
                        Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                        'merge_guest_explanation'.tr(),
                        style:
                        Theme.of(context).textTheme.subtitle2,
                        textAlign: TextAlign.center,
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        child: Icon(Icons.call_merge, color: Theme.of(context).colorScheme.onSecondary,),
                        onPressed: (){
                          if(guestApiToken!=null){
                            showDialog(
                                context: context,
                                child: MemberToMergeDialog()
                            );
                          }else{
                            FlutterToast ft = FlutterToast(context);
                            ft.showToast(
                                child: toastMessage
                            );
                          }
                        },
                      ),
                    ],
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
