import 'dart:collection';

import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csocsort_szamla/essentials/stack.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';

class Calculator extends StatefulWidget {
  final Function callback;
  Calculator({this.callback});
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _numToWrite='';
  Queue<String> _RPNintput = Queue<String>();
  MyStack<String> _operators = MyStack<String>();
  bool _isStillNum=false;
  String _storeNum='';
  String _lastOperator='asd';
  void parse(String input){
    if(input=='.'){
      if(_isStillNum && !_storeNum.contains('.')){
        _storeNum+=input;
        setState(() {
          // _lastOperator='asd';
          _numToWrite=_storeNum;
        });
      }
    }else if(int.tryParse(input)!=null){
      if(_isStillNum || _storeNum==''){
        _storeNum+=input;
      }
      _isStillNum=true;
      setState(() {
        // _lastOperator='asd';
        _numToWrite=_storeNum;
      });
    }else{
      if(_isStillNum){
        if(_storeNum[_storeNum.length-1]=='.'){
          _storeNum = _storeNum.substring(0, _storeNum.length-1);
          setState(() {
            _numToWrite=_storeNum;
          });
        }
        _RPNintput.add(_storeNum);
        _storeNum='';
      }
      _isStillNum=false;
      if(_operators.length>0){
        _RPNintput.add(_operators.pop());
        String calculated = calculate();
        setState(() {
          _numToWrite=calculated;
        });
        _RPNintput.clear();
        _RPNintput.add(calculated);
      }
      _operators.push(input);
      setState(() {
        _lastOperator=input;
      });
    }
    print(_RPNintput);
  }

  void equals(){
    setState(() {
      _lastOperator='asd';
    });
    if(_storeNum!=''){
      _RPNintput.add(_storeNum);
    }
    while(_operators.length!=0){
      _RPNintput.add(_operators.pop());
    }
    // print(_RPNintput);
    setState(() {
      _numToWrite = calculate();
    });
    _storeNum=_numToWrite;
    _RPNintput.clear();

  }

  void changeOperator(String input){
    _operators.pop();
    _operators.push(input);
    setState(() {
      if(_numToWrite.length!=0 && _stuffOperators.contains(_numToWrite[_numToWrite.length-1])){
        _numToWrite=_numToWrite.substring(0, _numToWrite.length-1)+input;
      }
      _lastOperator=input;
    });
  }

  String calculate(){
    MyStack newStack = MyStack();
    while(_RPNintput.length!=0){
      String something = _RPNintput.removeFirst();
      if(double.tryParse(something)!=null){
        newStack.push(something);
      }else{
        String a = newStack.pop();
        String b = newStack.pop();
        String c ='';
        switch(something){
          case '+':
            c=(double.parse(a)+double.parse(b)).toString();
            break;
          case '-':
            c=(-double.parse(a)+double.parse(b)).toString();
            break;
          case '*':
            c=(double.parse(a)*double.parse(b)).toString();
            break;
          case '/':
            c=(double.parse(b)/double.parse(a)).toString();
            break;
        }
        newStack.push(c);
      }
    }
    String result = newStack.pop();
    double resultDouble = double.parse(result);
    if(resultDouble.roundToDouble() == resultDouble){
      return result.split('.')[0];
    }
    return result;
  }

  void backspace(){
    if(_storeNum!=''){
      _storeNum=_storeNum.substring(0, _storeNum.length-1);
      setState(() {
        _numToWrite=_storeNum;
      });
    }
  }

  void clearAll(){
    _storeNum='';
    _lastOperator='asd';
    _operators=MyStack<String>();
    _RPNintput.clear();
    _isStillNum=false;
    setState(() {
      _numToWrite='0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text('calculator'.tr(), style: Theme.of(context).textTheme.headline6,),
          SizedBox(height: 10,),
          Text('calculator_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2,),
          SizedBox(height: 15,),
          Visibility(
            visible: _numToWrite=='',
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12),
              child: Column(
                children: [
                  Text('0', style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),)
                ],
              ),
            ),
          ),
          Visibility(
            visible: _numToWrite!='',
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_numToWrite, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),),
                  // SizedBox(height: 10,),
                  // Container(
                  //   color: Theme.of(context).colorScheme.primary,
                  //   height: 2,
                  // )
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Center(
            child: Table(
              children: [
                TableRow(
                  children: _generateRow(1)
                ),
                TableRow(
                    children: _generateRow(2)
                ),
                TableRow(
                    children: _generateRow(3)
                ),
                TableRow(
                    children: _generateRow(4)
                ),
              ],
              // defaultColumnWidth: FractionColumnWidth(0.2),
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                child: Icon(Icons.copy, color: Theme.of(context).colorScheme.onSecondary,),
                onPressed: (){
                  Navigator.pop(context);
                  if(double.tryParse(_numToWrite)!=null){
                    widget.callback(_numToWrite);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  List<String> _firstRow = [ '/', '1', '2', '3','C'];
  List<String> _secondRow = ['*', '4', '5', '6', ''];
  List<String> _thirdRow = ['-', '7', '8', '9', ''];
  List<String> _fourthRow = [ '+', '.', '0', '=', 'b',];
  List<String> _stuffOperators = ['+', '-', '/', '*', '='];

  List<Widget> _generateRow(int index){
    List row;
    switch(index){
      case 1:
        row=_firstRow;
        break;
      case 2:
        row=_secondRow;
        break;
      case 3:
        row=_thirdRow;
        break;
      case 4:
        row=_fourthRow;
        break;
    }
    return row.map((e){
      return InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: e!=''?(){
          if(e=='C'){
            print('asd');
            clearAll();
            return;
          }
          if(e=='b'){
            backspace();
            return;
          }
          if(_stuffOperators.contains(e)){
            if(_isStillNum){
              if(e=='='){
                equals();
              }else{
                parse(e);
              }
            }else if(e!='=' && _operators.length!=0){
              changeOperator(e);
            }
          }else{
            parse(e);
          }
        }:null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: _lastOperator==e?Colors.grey[200]:Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: e!='b'?
                Text(e, style: Theme.of(context).textTheme.bodyText1,)
                :Icon(Icons.backspace_outlined, color: Theme.of(context).textTheme.bodyText1.color),
            ),
          ),
        )
      );
    }).toList();
  }
}
