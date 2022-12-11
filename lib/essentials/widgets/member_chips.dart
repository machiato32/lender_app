import 'package:csocsort_szamla/essentials/widgets/custom_choice_chip.dart';
import 'package:csocsort_szamla/essentials/widgets/custom_amount_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

import '../group_objects.dart';

class MemberChips extends StatefulWidget {
  final bool allowMultiple;
  final List<Member> allMembers;
  final List<Member> membersChosen;
  final ValueChanged<List<Member>> membersChanged;
  final bool showDivisionDialog;
  final Function getMaxAmount;
  final Function percentagesChanged;
  const MemberChips({
    @required this.allowMultiple,
    @required this.allMembers,
    @required this.membersChanged,
    @required this.membersChosen,
    this.showDivisionDialog = false,
    this.getMaxAmount,
    this.percentagesChanged,
  });

  @override
  State<MemberChips> createState() => _MemberChipsState();
}

class _MemberChipsState extends State<MemberChips> {
  List<Member> membersChosen = [];
  Map<Member, double> customValues = {};
  Map<Member, double> percentages = {};

  double getInitialValue(Member member, double maxMoney) {
    if (customValues.containsKey(member)) {
      return customValues[member];
    } else {
      double sumCustom = 0;
      customValues.values.forEach((element) => sumCustom += element);
      return (maxMoney - sumCustom) / (membersChosen.length - customValues.length);
    }
  }

  double maxWithoutCustom(Member member, double maxMoney) {
    double sumCustom = 0;
    customValues.values.forEach((element) => sumCustom += element);
    if (customValues.containsKey(member)) {
      return maxMoney - sumCustom + customValues[member];
    }
    return maxMoney - sumCustom;
  }

  void calculatePercentages() {
    double maxAmount = widget.getMaxAmount();
    if (maxAmount == 0 || membersChosen.length == 0) {
      percentages.clear();
    } else {
      int nonCustom = membersChosen.length - customValues.length;
      double sumCustom = 0;
      customValues.values.forEach((element) => sumCustom += element);
      double amountWithoutCustom = maxAmount - sumCustom;
      percentages.clear();
      for (Member member in membersChosen) {
        if (customValues.containsKey(member)) {
          percentages[member] = customValues[member] / maxAmount;
        } else {
          percentages[member] = amountWithoutCustom / nonCustom / maxAmount;
        }
      }
    }
    if (widget.percentagesChanged != null) {
      widget.percentagesChanged(percentages);
    }
  }

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
    if (widget.showDivisionDialog) {
      if (membersChosen.length == 0) {
        customValues.clear();
      }
      calculatePercentages();
      double maxMoney = widget.getMaxAmount() * 1.0;
      bool someoneReset = false;
      for (Member member in membersChosen) {
        if (customValues.containsKey(member) && customValues[member] > maxMoney) {
          customValues.remove(member);
          someoneReset = true;
        }
      }
      if (someoneReset) {
        Fluttertoast.showToast(msg: 'custom_above_amount_toast'.tr());
      }
      double sumCustom = 0;
      customValues.values.forEach((element) => sumCustom += element);
      if (sumCustom > maxMoney) {
        customValues.clear();
        Fluttertoast.showToast(msg: 'sum_above_amount_toast'.tr());
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: widget.allMembers.map<Widget>(
        (Member member) {
          double fillRatio;
          Color selectedColor = Theme.of(context).colorScheme.secondaryContainer;
          Color selectedFontColor = Theme.of(context).colorScheme.onSecondaryContainer;
          if (widget.showDivisionDialog) {
            double maxMoney = widget.getMaxAmount();
            fillRatio = getInitialValue(member, maxMoney);
            if (maxMoney == 0) {
              fillRatio = 1 / (membersChosen.length == 0 ? 1 : membersChosen.length);
            } else {
              fillRatio /= maxMoney;
            }
            if (fillRatio > 1) {
              fillRatio = 1;
            }
            if (!membersChosen.contains(member)) {
              fillRatio = 0;
            }
            if (customValues.containsKey(member)) {
              selectedColor = Theme.of(context).colorScheme.tertiaryContainer;
              selectedFontColor = Theme.of(context).colorScheme.onTertiaryContainer;
            }
          } else {
            fillRatio = membersChosen.contains(member) ? 1 : 0;
          }

          return CustomChoiceChip(
            member: member,
            selected: membersChosen.contains(member),
            selectedColor: selectedColor,
            selectedFontColor: selectedFontColor,
            notSelectedColor: Theme.of(context).colorScheme.surface,
            notSelectedFontColor: Theme.of(context).colorScheme.onSurface,
            fillRatio: fillRatio * 1.0,
            onMemberChosen: (selected) {
              setState(() {
                if (widget.allowMultiple) {
                  if (selected) {
                    membersChosen.add(member);
                  } else {
                    membersChosen.remove(member);
                    customValues.remove(member);
                  }
                } else {
                  if (selected) {
                    membersChosen.clear();
                    membersChosen.add(member);
                  } else {
                    membersChosen.clear();
                    customValues.clear();
                  }
                }
                widget.membersChanged(membersChosen);
              });
            },
            onLongPress: !widget.showDivisionDialog
                ? null
                : () {
                    if (!membersChosen.contains(member)) {
                      setState(() {
                        membersChosen.add(member);
                        widget.membersChanged(membersChosen);
                      });
                    }
                    double maxMoney = widget.getMaxAmount() * 1.0;
                    if (maxMoney == 0) {
                      Fluttertoast.showToast(msg: 'first_give_amount_toast'.tr());
                      return;
                    }
                    if (!customValues.containsKey(member) &&
                        membersChosen.length - customValues.length == 1) {
                      Fluttertoast.showToast(msg: 'cant_add_custom_amount_toast'.tr());
                      return;
                    }
                    double initialValue = getInitialValue(member, maxMoney);
                    double maxValue = maxWithoutCustom(member, maxMoney);
                    if (maxValue == 0) {
                      Fluttertoast.showToast(msg: 'no_money_left_toast'.tr());
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomAmountDialog(
                          alreadyCustom: customValues.containsKey(member),
                          maxMoney: maxMoney,
                          initialValue: initialValue,
                          maxValue: maxValue,
                        );
                      },
                    ).then((value) {
                      setState(() {
                        if (value != null) {
                          if (value == -1) {
                            customValues.remove(member);
                            return;
                          }
                          customValues[member] = value;
                        }
                      });
                    });
                  },
          );
        },
      ).toList(),
    );
  }
}
