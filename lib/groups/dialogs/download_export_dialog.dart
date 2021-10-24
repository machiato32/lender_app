import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DownloadExportDialog extends StatefulWidget {
  @override
  _DownloadExportDialogState createState() => _DownloadExportDialogState();
}

class _DownloadExportDialogState extends State<DownloadExportDialog> {
  Future<bool> _downloadXls() async {
    try {
      http.Response response = await httpGet(
          context: context, uri: generateUri(GetUriKeys.groupExportXls));
      String url = response.body;
      Future.delayed(delayTime()).then((value) => _onDownloadXls(url));
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onDownloadXls(String url) {
    Navigator.pop(context);
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Theme.of(context),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'download_export'.tr(),
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text('download_export_explanation'.tr(),
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center),
            Divider(),
            SizedBox(height: 15),
            Text(
              'download_xls'.tr(),
              style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text('download_xls_explanation'.tr(),
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.table_chart,
                      color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return FutureSuccessDialog(
                            future: _downloadXls(),
                          );
                        });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            Column(
              children: [
                Text(
                  'download_pdf'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text('download_pdf_explanation'.tr(),
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Icon(Icons.picture_as_pdf,
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  ],
                ),
                Text(
                  'coming_soon'.tr(),
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
