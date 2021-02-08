import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FutureSuccessDialog extends StatefulWidget {
  final Widget dataTrue;
  final Widget dataFalse;
  final Widget noData;

  final Future<bool> future;

  final Function onDataTrue;
  final Function onDataFalse;
  final Function onNoData;

  final String dataTrueText;
  final String dataFalseText;

  ///Dialog for http requests. Translates all text given.
  ///[onDataFalse], [dataFalseText] and [onNoData] have default values.
  ///Fully customizable with [dataTrue], [dataFalse] and [noData]
  FutureSuccessDialog(
      {this.dataTrue,
      this.dataFalse,
      this.noData,
      @required this.future,
      this.onDataFalse,
      this.onDataTrue,
      this.onNoData,
      this.dataTrueText,
      this.dataFalseText = 'error'});

  @override
  _FutureSuccessDialogState createState() => _FutureSuccessDialogState();
}

class _FutureSuccessDialogState extends State<FutureSuccessDialog> {
  Widget dataTrue, dataFalse, noData;
  Function onDataFalse;
  Function onNoData;

  @override
  void initState() {
    onDataFalse = widget.onDataFalse;
    onNoData = widget.onNoData;

    if (onDataFalse == null) {
      onDataFalse = () {
        Navigator.pop(context);
      };
    }
    if (onNoData == null) {
      onNoData = () {
        Navigator.pop(context);
      };
    }
    super.initState();
  }

  Widget _buildDataTrue() {
    if (widget.dataTrue == null) {
      // if(true){
      //   return Container();
      // }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 50,),
          // Flexible(
          //     child: Text(
          //   widget.dataTrueText.tr(),
          //   style: Theme.of(context)
          //       .textTheme
          //       .bodyText1
          //       .copyWith(color: Colors.white),
          //   textAlign: TextAlign.center,
          // )),
          // SizedBox(
          //   height: 15,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     GradientButton(
          //       child: Row(
          //         children: [
          //           Icon(Icons.check,
          //               color: Theme.of(context).colorScheme.onSecondary),
          //           SizedBox(width: 3,),
          //           Text('okay'.tr(),
          //             style: Theme.of(context).textTheme.button,
          //           ),
          //         ],
          //       ),
          //       onPressed: () {
          //         widget.onDataTrue();
          //       },
          //       useShadow: false,
          //     ),
          //   ],
          // )
        ],
      );
    }
    return widget.dataTrue;
  }

  Widget _buildDataFalse() {
    if (widget.dataFalse == null) {
      return Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Text(
              widget.dataFalseText.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 15,
            ),
            FlatButton.icon(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                onDataFalse();
              },
              label: Text(
                'back'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white),
              ),
              color: Colors.red,
            )
          ],
        ),
      );
    }
    return widget.dataFalse;
  }

  Widget _buildNoData(AsyncSnapshot snapshot) {
    if (widget.noData == null) {
      return Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Text(
              snapshot.error.toString().tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 15,
            ),
            FlatButton.icon(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                onNoData();
              },
              label: Text(
                'back'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white),
              ),
              color: Colors.red,
            )
          ],
        ),
      );
    }
    return widget.noData;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FutureBuilder(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return _buildDataTrue();
              } else {
                return _buildDataFalse();
              }
            } else {
              return _buildNoData(snapshot);
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
