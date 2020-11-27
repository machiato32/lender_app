import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'app_theme.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  GradientButton({this.child, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      constraints: BoxConstraints(
          minWidth: 88.0, minHeight: 36.0
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientFromTheme(Theme.of(context)),
          borderRadius: BorderRadius.circular(15),
          // boxShadow: [ BoxShadow(
          //   color: Colors.grey[500],
          //   offset: Offset(0.0, 1.5),
          //   blurRadius: 1.5,
          // )]
        ),
        child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: this.onPressed,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Align(
                alignment: Alignment.center,
                child: this.child
              ),
            )
        ),
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
