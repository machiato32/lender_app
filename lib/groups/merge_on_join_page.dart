import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/member_chips.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../essentials/models.dart';

class MergeOnJoinPage extends StatefulWidget {
  final List<Member> guests;
  MergeOnJoinPage({@required this.guests});
  @override
  State<MergeOnJoinPage> createState() => _MergeOnJoinPageState();
}

class _MergeOnJoinPageState extends State<MergeOnJoinPage> {
  Member _selectedMember;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO: test
      appBar: AppBar(
        title: Text('merge_with_guest'.tr()),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(35),
          children: [
            Text(
              'merge_with_guest_explanation'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 15),
            Text(
              'guests_in_group'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 10),
            MemberChips(
              noAnimation: true,
              allowMultiple: false,
              allMembers: widget.guests,
              membersChanged: (newMembers) {
                setState(() {
                  _selectedMember = newMembers.isEmpty ? null : newMembers.first;
                });
              },
              membersChosen: [_selectedMember],
            ),
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GradientButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'skip'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                GradientButton(
                  disabled: _selectedMember == null,
                  onPressed: () {},
                  child: Text(
                    'merge'.tr(),
                    style: Theme.of(context).textTheme.labelLarge.copyWith(
                        color: _selectedMember == null
                            ? Colors.white
                            : Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
