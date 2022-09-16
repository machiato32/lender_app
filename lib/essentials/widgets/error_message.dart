import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../main/report_a_bug_page.dart';

class ErrorMessage extends StatelessWidget {
  final String error;
  final Function callback;
  final String locationOfError;

  ///Displays an error message with the given [error].
  ///When tapped on, the [callback] method is called.
  ///If the error isn't 'no internet', the user can decide to report the error.
  ///Then the 'report a bug' is navigated to with the given [locationOfError] as the location.
  ErrorMessage(
      {@required this.error, @required this.callback, this.locationOfError});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(error.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      .copyWith(color: Theme.of(context).colorScheme.error)),
              Visibility(
                visible: error != 'cannot_connect',
                child: Column(
                  children: [
                    Divider(),
                    Text('if_not_working'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface)),
                    SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReportABugPage(
                                      error: error,
                                      date: now,
                                      location: locationOfError,
                                    )));
                      },
                      child: Text('report_this_error'.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                      // color: Theme.of(context).textTheme.bodyText1.color,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          callback();
        });
  }
}
