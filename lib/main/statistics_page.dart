import 'dart:convert';
import 'dart:math';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class StatisticsPage extends StatefulWidget {
  final DateTime groupCreation;
  StatisticsPage({this.groupCreation});
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<List<Map<DateTime, double>>> _paymentStats;
  Future<List<Map<DateTime, double>>> _purchaseStats;
  Future<List<Map<DateTime, double>>> _groupStats;

  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.groupCreation != null &&
        _startDate.isBefore(widget.groupCreation)) {
      _startDate = widget.groupCreation;
    }
    _paymentStats = _getPaymentStats();
    _purchaseStats = _getPurchaseStats();
    _groupStats = _getGroupStats();
  }

  Future<List<Map<DateTime, double>>> _getPaymentStats() async {
    try {
      String startDate = DateFormat('yyyy-MM-dd').format(_startDate);
      String endDate = DateFormat('yyyy-MM-dd').format(_endDate);
      print(startDate);
      http.Response response = await httpGet(
          useCache: false,
          context: context,
          uri: generateUri(GetUriKeys.statisticsPayments,
              args: [currentGroupId.toString(), startDate, endDate]));
      Map<String, dynamic> decoded = jsonDecode(response.body);

      Map<DateTime, double> payed =
          (decoded['data']['payed'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      Map<DateTime, double> taken =
          (decoded['data']['taken'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      return [
        payed,
        taken,
        ({DateTime.now(): decoded['data']['sum']['payed'] * 1.0}),
        ({DateTime.now(): decoded['data']['sum']['taken'] * 1.0})
      ];
    } catch (_) {
      throw _;
    }
  }

  Future<List<Map<DateTime, double>>> _getPurchaseStats() async {
    try {
      String startDate = DateFormat('yyyy-MM-dd').format(_startDate);
      String endDate = DateFormat('yyyy-MM-dd').format(_endDate);
      http.Response response = await httpGet(
          useCache: false,
          context: context,
          uri: generateUri(GetUriKeys.statisticsPurchases,
              args: [currentGroupId.toString(), startDate, endDate]));
      Map<String, dynamic> decoded = jsonDecode(response.body);

      Map<DateTime, double> bought =
          (decoded['data']['bought'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      Map<DateTime, double> received =
          (decoded['data']['received'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      return [
        bought,
        received,
        ({DateTime.now(): decoded['data']['sum']['bought'] * 1.0}),
        ({DateTime.now(): decoded['data']['sum']['received'] * 1.0})
      ];
    } catch (_) {
      throw _;
    }
  }

  Future<List<Map<DateTime, double>>> _getGroupStats() async {
    try {
      String startDate = DateFormat('yyyy-MM-dd').format(_startDate);
      String endDate = DateFormat('yyyy-MM-dd').format(_endDate);
      http.Response response = await httpGet(
          useCache: false,
          context: context,
          uri: generateUri(GetUriKeys.statisticsAll,
              args: [currentGroupId.toString(), startDate, endDate]));
      Map<String, dynamic> decoded = jsonDecode(response.body);

      Map<DateTime, double> purchases =
          (decoded['data']['purchases'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      Map<DateTime, double> payments =
          (decoded['data']['payments'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), value * 1.0));
      return [
        purchases,
        payments,
        ({DateTime.now(): decoded['data']['sum']['purchases'] * 1.0}),
        ({DateTime.now(): decoded['data']['sum']['payments'] * 1.0})
      ];
    } catch (_) {
      throw _;
    }
  }

  LineChartBarData _generateLineChartBarData(
      Map<DateTime, double> map, int index) {
    return LineChartBarData(
      spots: (map.keys.map<FlSpot>((DateTime key) {
        return FlSpot(key.millisecondsSinceEpoch.toDouble(), map[key]);
      }).toList()),
      color: (index == 0)
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      barWidth: 2.5,
      isCurved: false,
      preventCurveOverShooting: true,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: (index == 0)
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      ),
    );
  }

  LineChartData _generateLineChartData(
      List<Map<DateTime, double>> maps, List<String> keywords) {
    int minX = maps[0].keys.toList()[0].millisecondsSinceEpoch;
    int maxX = maps[0].keys.toList()[maps[0].length - 1].millisecondsSinceEpoch;
    double minY = 0;
    double maxY = max(maps[0].values.reduce(max), maps[1].values.reduce(max));
    double sideScale = 1;
    if (maxY > 0) {
      sideScale = pow(10, (log(maxY) / log(10)).floor() - 1).toDouble();
    } else {
      maxY = 1;
    }
    maxY += sideScale;
    double sideInterval =
        ((maxY / sideScale).round() + (3 - (maxY / sideScale).round()) % 3)
                .toDouble() *
            sideScale /
            3;

    int bottomDivider;
    Duration bottomDuration = Duration(milliseconds: maxX - minX);
    if (bottomDuration.inDays > 30) {
      bottomDivider = 15;
    } else {
      bottomDivider = (bottomDuration.inDays / 3).round();
      if (bottomDivider < 1) {
        bottomDivider = 1;
      }
    }

    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: minX.toDouble(),
      maxX: maxX.toDouble(),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                FlDotData(
                  show: true,
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: true,
            tooltipRoundedRadius: 15,
            tooltipBgColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
              lineBarsSpot.sort((a, b) => a.barIndex.compareTo(b.barIndex));
              return lineBarsSpot.map((lineBarSpot) {
                String date = DateFormat('yyyy-MM-dd').format(
                    DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt()));
                return LineTooltipItem(
                  (lineBarSpot.barIndex == 0 ? date + '\n' : '') +
                      (lineBarSpot.barIndex == 0
                          ? keywords[0].tr() + ' '
                          : keywords[1].tr() + ' ') +
                      lineBarSpot.y.printMoney(currentGroupCurrency),
                  Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(height: lineBarSpot.barIndex == 0 ? 1.5 : 1),
                );
              }).toList();
            },
          )),
      backgroundColor: Theme.of(context).cardTheme.color,
      lineBarsData: [
        _generateLineChartBarData(maps[0], 0),
        _generateLineChartBarData(maps[1], 1)
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, titleMeta) {
              String text = '';
              DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
              if (bottomDuration.inDays < 65) {
                if (date.day == 1) {
                  text = DateFormat.d().format(date);
                }
                if (date.day % bottomDivider == 0 && date.day < 29) {
                  if (!(date.month == 2 && date.day > 26)) {
                    text = DateFormat.d().format(date);
                  }
                }
                if ((value == minX || value == maxX) &&
                    (date.day % bottomDivider > 3 &&
                        date.day % bottomDivider < bottomDivider - 2)) {
                  if (date.day < 29 && date.day > 2) {
                    if (!(date.month == 2 && date.day > 26)) {
                      text = DateFormat.d().format(date);
                    }
                  }
                }
              }
              return Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 15));
            },
            interval: Duration(days: 1).inMilliseconds.toDouble(),
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, titleMeta) {
              String text = '';
              DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
              if ((bottomDuration.inDays < 270 && date.day == 1) ||
                  (date.month % 3 == 1 && date.day == 1)) {
                if (date.month == 1) {
                  text = DateFormat.y().format(date);
                } else {
                  if (bottomDuration.inDays < 90) {
                    text = DateFormat.MMM().format(date);
                  } else {
                    text = DateFormat.MMM().format(date);
                  }
                }
              }
              return Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 15));
            },
            interval: Duration(days: 1).inMilliseconds.toDouble(),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, titleMeta) {
              if (value == maxY && value % sideInterval != 0) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Text(
                  value.money(currentGroupCurrency),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 13),
                ),
              );
            },
            reservedSize: maxY.toString().length * 7.0,
            interval: sideInterval,
          ),
        ),
        rightTitles: AxisTitles(),
      ),
      gridData: FlGridData(
        show: true,
        // drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            strokeWidth: 1,
          );
        },
        checkToShowVerticalLine: (value) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          return date.day == 1;
        },
        getDrawingVerticalLine: (value) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          if (date.month == 1) {
            return FlLine(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300],
              // dashArray: [5, 2],
              strokeWidth: 3,
            );
          }
          return FlLine(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[300],
            dashArray: [5, 2],
            strokeWidth: 2,
          );
        },
        verticalInterval: Duration(days: 1).inMilliseconds.toDouble(),
        horizontalInterval: sideInterval,
      ),
    );
  }

  Widget _sumOf(double amount, int type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'sum_of'.tr() + ' ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                  color: type == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15)),
            ),
          ],
        ),
        Flexible(
            child: Text(
          amount.printMoney(currentGroupCurrency),
          style: Theme.of(context).textTheme.bodyText1,
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))),
        ),
        title: Text(
          'statistics'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'select_date'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'select_date_explanation'.tr(),
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    DateFormat.yMMMd().format(_startDate) +
                        ' - ' +
                        DateFormat.yMMMd().format(_endDate),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        child: Icon(Icons.date_range,
                            color: Theme.of(context).colorScheme.onSecondary),
                        onPressed: () async {
                          DateTimeRange range = await showDateRangePicker(
                              context: context,
                              firstDate: widget.groupCreation,
                              lastDate: DateTime.now(),
                              currentDate: DateTime.now(),
                              initialDateRange: DateTimeRange(
                                  start: _startDate, end: _endDate),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    primaryColor:
                                        Theme.of(context).colorScheme.primary,
                                    colorScheme: Theme.of(context)
                                        .colorScheme
                                        .copyWith(
                                          onSurface:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[800]
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                          onPrimary: Colors.white,
                                          surface: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                    scaffoldBackgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    textTheme:
                                        Theme.of(context).textTheme.copyWith(
                                              bodyText2: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal),
                                              headline5: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                              headline4: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                  ),
                                  child: child,
                                );
                              });
                          if (range != null) {
                            _startDate = range.start;
                            _endDate = range.end;
                            setState(() {
                              _paymentStats = _getPaymentStats();
                              _purchaseStats = _getPurchaseStats();
                              _groupStats = _getGroupStats();
                            });
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'payments_stats'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'payments_stats_explanation'.tr(),
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                    future: _paymentStats,
                    builder: (context,
                        AsyncSnapshot<List<Map<DateTime, double>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 21 / 9,
                                child: LineChart(_generateLineChartData(
                                    snapshot.data, ['payed', 'taken'])),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'you_payed'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'you_took'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _sumOf(snapshot.data[2].values.first, 1),
                              _sumOf(snapshot.data[3].values.first, 2),
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          return ErrorMessage(
                              error: snapshot.error.toString(),
                              locationOfError: 'statistics',
                              callback: () {
                                setState(() {
                                  _paymentStats = _getPaymentStats();
                                });
                              });
                        }
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'purchases_stats'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'purchases_stats_explanation'.tr(),
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                    future: _purchaseStats,
                    builder: (context,
                        AsyncSnapshot<List<Map<DateTime, double>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 21 / 9,
                                child: LineChart(_generateLineChartData(
                                    snapshot.data,
                                    ['stat_bought', 'received'])),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'you_bought'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'you_received'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _sumOf(snapshot.data[2].values.first, 1),
                              _sumOf(snapshot.data[3].values.first, 2),
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          return ErrorMessage(
                              error: snapshot.error.toString(),
                              locationOfError: 'statistics',
                              callback: () {
                                setState(() {
                                  _purchaseStats = _getPurchaseStats();
                                });
                              });
                        }
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'group_stats'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'group_stats_explanation'.tr(),
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                    future: _groupStats,
                    builder: (context,
                        AsyncSnapshot<List<Map<DateTime, double>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 21 / 9,
                                child: LineChart(_generateLineChartData(
                                    snapshot.data,
                                    ['stats_purchases', 'stats_payments'])),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'purchases_stats'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'payments_stats'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _sumOf(snapshot.data[2].values.first, 1),
                              _sumOf(snapshot.data[3].values.first, 2),
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          return ErrorMessage(
                              error: snapshot.error.toString(),
                              locationOfError: 'statistics',
                              callback: () {
                                setState(() {
                                  _groupStats = _getGroupStats();
                                });
                              });
                        }
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
