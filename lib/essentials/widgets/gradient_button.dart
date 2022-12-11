import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../config.dart';
import '../app_theme.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final Function() onPressed;
  final bool useSecondary;
  final double borderRadius;
  GradientButton({this.child, this.onPressed, this.useSecondary = false, this.borderRadius = 20});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 88.0, minHeight: 36.0),
      height: 40,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientFromTheme(currentThemeName, useSecondary: this.useSecondary),
          borderRadius: BorderRadius.circular(this.borderRadius),
        ),
        child: InkWell(
            borderRadius: BorderRadius.circular(this.borderRadius),
            onTap: this.onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: this.child,
                ),
              ],
            )),
      ),
    );
  }
}

// class GradientButton extends StatefulWidget {
//   final Widget child;
//   final Function onPressed;
//   GradientButton({this.child, this.onPressed});
//   @override
//   _GradientButtonState createState() => _GradientButtonState();
// }
//
// class _GradientButtonState extends State<GradientButton> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(5),
//       child: Ink(
//         decoration: BoxDecoration(
//           gradient: AppTheme.gradientFromTheme(Theme.of(context)),
//           borderRadius: BorderRadius.circular(15),
//           // boxShadow: [ BoxShadow(
//           //   color: Colors.grey[500],
//           //   offset: Offset(0.0, 1.5),
//           //   blurRadius: 1.5,
//           // )]
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: widget.onPressed,
//           child: Container(
//             padding: EdgeInsets.only(left: 16, right: 16),
//             child: widget.child,
//           )
//         ),
//       ),
//     );
//   }
// }
