import 'dart:convert';

import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/groups/dialogs/download_export_dialog.dart';
import 'package:csocsort_szamla/main/statistics_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

import '../essentials/app_theme.dart';
import 'in_app_purchase_page.dart';

class GroupSettingsSpeedDial extends StatefulWidget {
  final Function callback;
  GroupSettingsSpeedDial({this.callback});
  @override
  _GroupSettingsSpeedDialState createState() => _GroupSettingsSpeedDialState();
}

class _GroupSettingsSpeedDialState extends State<GroupSettingsSpeedDial> {
  Future<dynamic> _isGroupBoosted() async {
    try {
      http.Response response = await httpGet(
          context: context,
          uri: generateUri(GetUriKeys.groupBoost),
          useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data'];
    } catch (_) {
      throw _;
    }
  }

  void showNoStatisticsDialog() {
    showDialog(
        builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'statistics_not_available'.tr(),
                      style: Theme.of(context).textTheme.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text('statistics_not_available_explanation'.tr(),
                        style: Theme.of(context).textTheme.titleSmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                        textAlign: TextAlign.center),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientButton(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.onPrimary,
                                  BlendMode.srcIn),
                              child: Image.asset(
                                'assets/dodo_color.png',
                                width: 25,
                              )),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InAppPurchasePage()));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        context: context);
  }

  Widget _generateSpeedDial(bool boosted, {DateTime created}) {
    return SpeedDial(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      child: Icon(Icons.show_chart,
          color: Theme.of(context).colorScheme.onTertiary),
      overlayColor: (Theme.of(context).brightness == Brightness.dark)
          ? Colors.black
          : Colors.white,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
            foregroundColor: boosted
                ? Theme.of(context).colorScheme.onTertiaryContainer
                : Theme.of(context).colorScheme.onError,
            backgroundColor: boosted
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.error,
            labelWidget: GestureDetector(
              onTap: () {
                //TODO
                // if (boosted) {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => StatisticsPage(
                //                 groupCreation: created == null
                //                     ? DateTime.parse('2020-01-17')
                //                     : created,
                //               )));
                // } else {
                //   showNoStatisticsDialog();
                // }
              },
              child: Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                      decoration: BoxDecoration(
                        // gradient: boosted
                        //     ? AppTheme.gradientFromTheme(Theme.of(context))
                        //     : LinearGradient(
                        //         colors: [Colors.grey[400], Colors.grey[400]]),
                        color: boosted
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Text('statistics'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge.copyWith(
                                color: boosted
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer
                                    : Theme.of(context).colorScheme.onError,
                              )),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'statistics_explanation'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            child: Icon(Icons.assessment),
            onTap: () {
              if (boosted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StatisticsPage(
                              groupCreation: created == null
                                  ? DateTime.parse('2020-01-17')
                                  : created,
                            )));
              } else {
                showNoStatisticsDialog();
              }
            }),
        SpeedDialChild(
            foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            labelWidget: GestureDetector(
              onTap: () {
                //TODO
                // showDialog(
                //   builder: (context) => DownloadExportDialog(),
                //   context: context,
                // );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                      decoration: BoxDecoration(
                        // gradient: AppTheme.gradientFromTheme(Theme.of(context)),
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Text('export'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                              fontSize: 18)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'export_explanation'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            child: Icon(Icons.table_chart),
            onTap: () {
              showDialog(
                builder: (context) => DownloadExportDialog(),
                context: context,
              );
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _isGroupBoosted(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            DateTime created;
            if (snapshot.data['created_at'] != null) {
              created = DateTime.parse(snapshot.data['created_at']).toLocal();
            }
            if (snapshot.data['is_boosted'] == 1 ||
                snapshot.data['trial'] == 1) {
              return _generateSpeedDial(true, created: created);
            } else {
              return _generateSpeedDial(false, created: created);
            }
          }
          return Container();
        });
  }
}
