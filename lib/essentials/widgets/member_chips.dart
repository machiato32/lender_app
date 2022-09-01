import 'package:flutter/material.dart';

import '../group_objects.dart';

class MemberChips extends StatefulWidget {
  final bool allowMultiple;
  final List<Member> allMembers;
  final List<Member> membersChosen;
  final ValueChanged<List<Member>> membersChanged;
  const MemberChips({
    @required this.allowMultiple,
    @required this.allMembers,
    @required this.membersChanged,
    @required this.membersChosen,
  });

  @override
  State<MemberChips> createState() => _MemberChipsState();
}

class _MemberChipsState extends State<MemberChips> {
  List<Member> membersChosen = [];
  @override
  void initState() {
    super.initState();
    membersChosen = widget.membersChosen;
  }

  @override
  void didUpdateWidget(covariant MemberChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    membersChosen = widget.membersChosen;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: widget.allMembers
          .map<ChoiceChip>(
            (Member member) => ChoiceChip(
              label: Text(member.nickname),
              pressElevation: 30,
              selected: membersChosen.contains(member),
              onSelected: (bool selected) {
                FocusScope.of(context).unfocus();
                setState(() {
                  if (widget.allowMultiple) {
                    if (selected) {
                      membersChosen.add(member);
                    } else {
                      membersChosen.remove(member);
                    }
                  } else {
                    if (selected) {
                      membersChosen.clear();
                      membersChosen.add(member);
                    } else {
                      membersChosen.clear();
                    }
                  }
                  widget.membersChanged(membersChosen);
                });
              },
              labelStyle: membersChosen.contains(member)
                  ? Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary)
                  : Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
              selectedColor: Theme.of(context).colorScheme.primary,
            ),
          )
          .toList(),
    );
  }
}
