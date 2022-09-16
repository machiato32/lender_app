import 'dart:collection';

import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:csocsort_szamla/essentials/stack.dart';
import 'package:easy_localization/easy_localization.dart';

class Calculator extends StatefulWidget {
  final Function callback;
  final String initial;
  Calculator({this.callback, this.initial});
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _numToWrite = '';
  Queue<String> _RPNintput = Queue<String>();
  MyStack<String> _operators = MyStack<String>();
  bool _isStillNum = false;
  String _storeNum = '';
  String _lastOperator = 'asd';
  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _isStillNum = true;
      _numToWrite = widget.initial;
      _storeNum = widget.initial;
    }
  }

  void parse(String input) {
    if (input == '.') {
      if (_isStillNum && !_storeNum.contains('.')) {
        _storeNum += input;
        setState(() {
          _lastOperator = 'asd';
          _numToWrite = _storeNum;
        });
      }
    } else if (int.tryParse(input) != null) {
      if (_isStillNum || _storeNum == '') {
        _storeNum += input;
      }
      _isStillNum = true;
      setState(() {
        _lastOperator = 'asd';
        _numToWrite = _storeNum;
      });
    } else {
      if (_isStillNum) {
        if (_storeNum[_storeNum.length - 1] == '.') {
          _storeNum = _storeNum.substring(0, _storeNum.length - 1);
          setState(() {
            _numToWrite = _storeNum;
          });
        }
        _RPNintput.add(_storeNum);
        _storeNum = '';
      }
      _isStillNum = false;
      if (_operators.length > 0) {
        _RPNintput.add(_operators.pop());
        String calculated = calculate();
        setState(() {
          _numToWrite = calculated;
        });
        _RPNintput.clear();
        _RPNintput.add(calculated);
      }
      _operators.push(input);
      setState(() {
        _lastOperator = input;
      });
    }
    print(_RPNintput);
  }

  void equals() {
    setState(() {
      _lastOperator = 'asd';
    });
    if (_storeNum != '') {
      _RPNintput.add(_storeNum);
    }
    while (_operators.length != 0) {
      _RPNintput.add(_operators.pop());
    }
    // print(_RPNintput);
    setState(() {
      _numToWrite = calculate();
    });
    _storeNum = _numToWrite;
    _RPNintput.clear();
  }

  void changeOperator(String input) {
    _operators.pop();
    _operators.push(input);
    setState(() {
      if (_numToWrite.length != 0 &&
          _stuffOperators.contains(_numToWrite[_numToWrite.length - 1])) {
        _numToWrite = _numToWrite.substring(0, _numToWrite.length - 1) + input;
      }
      _lastOperator = input;
    });
  }

  String calculate() {
    MyStack newStack = MyStack();
    while (_RPNintput.length != 0) {
      String something = _RPNintput.removeFirst();
      if (double.tryParse(something) != null) {
        newStack.push(something);
      } else {
        String a = newStack.pop();
        String b = newStack.pop();
        String c = '';
        switch (something) {
          case '+':
            c = (double.parse(a) + double.parse(b)).toString();
            break;
          case '-':
            c = (-double.parse(a) + double.parse(b)).toString();
            break;
          case '*':
            c = (double.parse(a) * double.parse(b)).toString();
            break;
          case '/':
            c = (double.parse(b) / double.parse(a)).toString();
            break;
        }
        newStack.push(c);
      }
    }
    String result = newStack.pop();
    double resultDouble = double.parse(result);
    if (resultDouble.roundToDouble() == resultDouble) {
      return result.split('.')[0];
    }
    return result;
  }

  void backspace() {
    if (_storeNum != '') {
      _storeNum = _storeNum.substring(0, _storeNum.length - 1);
      setState(() {
        _numToWrite = _storeNum;
      });
    }
  }

  void clearAll() {
    _storeNum = '';
    _lastOperator = 'asd';
    _operators = MyStack<String>();
    _RPNintput.clear();
    _isStillNum = false;
    setState(() {
      _numToWrite = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            'calculator'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'calculator_explanation'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            height: 15,
          ),
          Column(
            children: [
              Visibility(
                visible: _numToWrite == '',
                child: Text(
                  '0',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      .copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              Visibility(
                visible: _numToWrite != '',
                child: Text(
                  _numToWrite,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      .copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Table(
                children: [
                  TableRow(children: _generateRow(1)),
                  TableRow(children: _generateRow(2)),
                  TableRow(children: _generateRow(3)),
                  TableRow(children: _generateRow(4)),
                ],
                // defaultColumnWidth: FractionColumnWidth(0.2),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                child: _operators.length != 0 && _isStillNum
                    ? Text(
                        '=',
                        style: Theme.of(context).textTheme.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                      )
                    : Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                onPressed: () {
                  if (_operators.length != 0 && _isStillNum) {
                    equals();
                  } else {
                    Navigator.pop(context);
                    if (double.tryParse(_numToWrite) != null) {
                      widget.callback(_numToWrite);
                    }
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  List<String> _firstRow = ['/', '1', '2', '3', 'C'];
  List<String> _secondRow = ['*', '4', '5', '6', ''];
  List<String> _thirdRow = ['-', '7', '8', '9', ''];
  List<String> _fourthRow = ['+', '.', '0', 'b', '='];
  List<String> _stuffOperators = ['+', '-', '/', '*', '='];

  List<Widget> _generateRow(int index) {
    List row;
    switch (index) {
      case 1:
        row = _firstRow;
        break;
      case 2:
        row = _secondRow;
        break;
      case 3:
        row = _thirdRow;
        break;
      case 4:
        row = _fourthRow;
        break;
    }
    return row.map((e) {
      List<String> operators = [
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '',
        'C',
        '='
      ];
      Color color, textColor;
      if (_lastOperator == e) {
        color = Theme.of(context).colorScheme.secondary;
        textColor = Theme.of(context).colorScheme.onSecondary;
      } else if (!operators.contains(e)) {
        color = Theme.of(context).colorScheme.secondaryContainer;
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
      } else if (e == 'C') {
        color = Theme.of(context).colorScheme.tertiaryContainer;
        textColor = Theme.of(context).colorScheme.onTertiaryContainer;
      } else if (e == '=') {
        color = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
      } else if (e == '') {
        color = Colors.transparent;
        textColor = Theme.of(context).colorScheme.onSurface;
      } else {
        color = Theme.of(context).colorScheme.surfaceVariant;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      }

      return AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: e != ''
                ? () {
                    if (e == 'C') {
                      clearAll();
                      return;
                    }
                    if (e == 'b') {
                      backspace();
                      return;
                    }
                    if (_stuffOperators.contains(e)) {
                      if (_isStillNum) {
                        if (e == '=') {
                          equals();
                        } else {
                          parse(e);
                        }
                      } else if (e != '=' && _operators.length != 0) {
                        changeOperator(e);
                      }
                    } else {
                      parse(e);
                    }
                  }
                : null,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: color,
              ),
              child: Center(
                child: e != 'b'
                    ? Text(
                        e,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            .copyWith(color: textColor),
                      )
                    : Icon(Icons.backspace, color: textColor),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
