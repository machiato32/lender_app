import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

import '../../config.dart';

class DownloadExportDialog extends StatefulWidget {

  @override
  _DownloadExportDialogState createState() => _DownloadExportDialogState();
}

class _DownloadExportDialogState extends State<DownloadExportDialog> {

  Future<void> _downloadXls() async {
    String path = Theme.of(context).platform == TargetPlatform.android
        ? '/storage/emulated/0/Download'
        : '';//TODO
    await FlutterDownloader.enqueue(
      headers: {
        // "Content-Type": "application/json",
        "Authorization": "Bearer " +(apiToken==null?'':apiToken)
      },
      url: (useTest?TEST_URL:APP_URL)+'/groups/'+currentGroupId.toString()+'/export',
      savedDir: path,
      showNotification: true,
      openFileFromNotification: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('download_export'.tr(), style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
            SizedBox(height: 10),
            Text('download_export_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center),
            Divider(),
            SizedBox(height: 15),
            Text('download_xls'.tr(), style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20), textAlign: TextAlign.center,),
            SizedBox(height: 10),
            Text('download_xls_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.table_chart, color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: (){
                    _downloadXls();
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            Stack(
              children: [
                Column(
                  children: [
                    Text('download_pdf'.tr(), style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20), textAlign: TextAlign.center,),
                    SizedBox(height: 10),
                    Text('download_pdf_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientButton(
                          child: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: (){

                          },
                        ),
                      ],
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.rotate(
                    angle: -math.pi / 8,
                    child: Text('coming_soon'.tr(), style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.red),),
                  ),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}
