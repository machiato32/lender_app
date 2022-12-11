import 'package:flutter/material.dart';

import '../group_objects.dart';

class CustomChoiceChip extends StatefulWidget {
  final Member member;
  final Color selectedColor;
  final Color notSelectedColor;
  final Color selectedFontColor;
  final Color notSelectedFontColor;
  final Function(bool) onMemberChosen;
  final bool selected;
  final Function onLongPress;
  final double fillRatio;
  const CustomChoiceChip({
    this.member,
    this.selected,
    this.selectedColor,
    this.notSelectedColor,
    this.selectedFontColor,
    this.notSelectedFontColor,
    this.onMemberChosen,
    this.onLongPress,
    this.fillRatio,
  });

  @override
  State<CustomChoiceChip> createState() => _CustomChoiceChipState();
}

class _CustomChoiceChipState extends State<CustomChoiceChip> with SingleTickerProviderStateMixin {
  Animation<double> ratioAnimation;
  AnimationController controller;

  Duration checkAnimationDuration = Duration(milliseconds: 300);

  void animateColor(bool forward) {
    if (forward) {
      controller.animateTo(widget.fillRatio, duration: Duration(milliseconds: 500));
    } else {
      controller.animateBack(widget.fillRatio, duration: Duration(milliseconds: 500));
    }
  }

  @override
  void didUpdateWidget(covariant CustomChoiceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    animateColor(widget.fillRatio > ratioAnimation.value);
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    ratioAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              width: 0.7,
              color: widget.selected ? Colors.transparent : Theme.of(context).colorScheme.outline),
          gradient: LinearGradient(
            colors: [widget.selectedColor, widget.notSelectedColor],
            stops: [ratioAnimation.value, ratioAnimation.value],
          )),
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedPadding(
          duration: checkAnimationDuration,
          padding: widget.selected
              ? EdgeInsets.fromLTRB(8, 7.5, 16, 7.5)
              : EdgeInsets.symmetric(horizontal: 16, vertical: 7.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.check,
                    color: widget.selectedFontColor,
                    size: 18,
                  ),
                ),
                duration: checkAnimationDuration,
                crossFadeState:
                    widget.selected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),
              Text(widget.member.nickname,
                  style: Theme.of(context).textTheme.labelLarge.copyWith(
                      color: widget.selected
                          ? widget.selectedFontColor
                          : widget.notSelectedFontColor)),
            ],
          ),
        ),
        onTap: () {
          FocusScope.of(context).unfocus();
          bool selected = !widget.selected;
          widget.onMemberChosen(selected);
          animateColor(selected);
        },
        onLongPress: widget.onLongPress,
      ),
    );
  }
}
