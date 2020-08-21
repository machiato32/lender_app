import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/person.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

List<String> placeholder = ["Mamut", "Sarki kisbolt", "Fapuma", "Eltört kiskanál", "Irtó büdös szúnyogirtó", "Borravaló a pizzásnak", "Buszjegy", "COO HD Piros Multivit 100% 1L",
  "Egy tökéletes kakaóscsiga", "Sajt sajttal", "Gyíkhúsos melegszendvics", "56 alma", "Csigaszerű játékizé", "10 batka", "Egész napos kirándulás", "Paradicsomos kenyér",
  "Kőrözöttes-szardíniás szendvics", "Menő napszemcsi", "Sokadik halálcsillag", "Draco Raphus Cuculatus", "Üres doboz", "Büdös zokni", "Nyikorgó szekér", "Emelt díjas SMS",
  "Teve, sok teve", "Helytartó", "Balatoni jacht", "Kacsajelmez", "Légycsapó", "Pisztáciás fagylalt", "Csocsó", "Egy működő app", "Lekváros couscous", "Nagy bevásárlás"];
Random random = Random();

class SavedExpense{
  String name, note;
  List<String> names;
  int amount;
  int iD;
  SavedExpense({this.name, this.names, this.amount, this.note, this.iD});
}

enum ExpenseType{
  fromShopping, fromSavedExpense, newExpense
}

class AddTransactionRoute extends StatefulWidget {
  final ExpenseType type;
  final SavedExpense expense;
  final ShoppingRequestData shoppingData;
  AddTransactionRoute({@required this.type, this.expense, this.shoppingData});
  @override
  _AddTransactionRouteState createState() => _AddTransactionRouteState();
}

class _AddTransactionRouteState extends State<AddTransactionRoute> {
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<Member>> _names;
  Future<bool> success;
  Map<Member,bool> checkboxBool = Map<Member,bool>();
  FocusNode _focusNode = FocusNode();
  int _randomInt;

  var _formKey = GlobalKey<FormState>();

  Future<List<Member>> _getNames() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString(), headers: header);

      if(response.statusCode==200){
        Map<String, dynamic> response2 = jsonDecode(response.body);
        List<Member> members=[];
        for(var member in response2['data']['members']){
          members.add(Member(nickname: member['nickname'], balance: member['balance']*1.0, userId: member['user_id']));
        }
        return members;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }

  }

  Future<bool> _postNewExpense(List<Member> members, double amount, String name) async{
    try{

      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      Map<String, dynamic> map = {
        "name":name,
        "group":currentGroupId,
        "amount":amount,
        "receivers":members.map((e) => e.toJson()).toList()
      };

      String encoded = json.encode(map);

      http.Response response = await http.post(APPURL+'/transactions', body: encoded, headers: header);
      if(response.statusCode==201){
        return true;
      }
      else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }


  }

  void setInitialValues(){
    if(widget.type==ExpenseType.fromSavedExpense){
      noteController.text = widget.expense.note;
      amountController.text=widget.expense.amount.toString();
    }else{
      noteController.text=widget.shoppingData.name;
    }
  }

  @override
  void initState() {
    super.initState();
    _randomInt=random.nextInt(placeholder.length);
    if(widget.type==ExpenseType.fromSavedExpense || widget.type==ExpenseType.fromShopping){
      setInitialValues();
    }
    _names = _getNames();

    _focusNode.addListener((){
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: Text('expense'.tr())),

        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value){
                              if(value.isEmpty){
                                return 'field_empty'.tr();
                              }
                              if(double.tryParse(value)==null){
                                return 'not_valid_num'.tr();
                              }
                              if(double.parse(value)<0){
                                return 'not_valid_num'.tr();
                              }
                              return null;
                            },
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              labelText: 'full_amount'.tr(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                //  when the TextFormField in unfocused
                              ) ,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                              ) ,

                            ),
                            controller: amountController,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9\\.]'))
                            ],
                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            validator: (value){
                              if(value.isEmpty){
                                return 'field_empty'.tr();
                              }
                              if(value.length<3){
                                return 'minimal_length'.tr(args: ['3']);
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'note'.tr(),
                              hintText: placeholder[_randomInt],
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                              ) ,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                              ) ,

                            ),
                            inputFormatters: [LengthLimitingTextInputFormatter(30)],
                            controller: noteController,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(),
                    Center(
                      child: FutureBuilder(
                        future: _names,
                        builder: (context, snapshot){
                          if(snapshot.connectionState==ConnectionState.done){
                            if(snapshot.hasData){
                              for(Member member in snapshot.data){
                                checkboxBool.putIfAbsent(member, () => false);
                              }
//                          if(widget.type==ExpenseType.fromSavedExpense && widget.expense.names!=null){
//                            for(String name in widget.expense.names){
//                              checkboxBool[name]=true;
//                            }
//                            widget.expense.names=null;
//                          }else
                              if(widget.type==ExpenseType.fromShopping){
                                checkboxBool[(snapshot.data as List<Member>).firstWhere((member) => member.userId==widget.shoppingData.requesterId)]=true;
                              }
                              return Wrap(
                                spacing: 10,
                                children: snapshot.data.map<ChoiceChip>((Member member)=>
                                    ChoiceChip(
                                      label: Text(member.nickname),
                                      pressElevation: 30,
                                      selected: checkboxBool[member],
                                      onSelected: (bool newValue){
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          checkboxBool[member]=newValue;
                                        });
                                      },
                                      labelStyle: checkboxBool[member]
                                          ?Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.onSecondary)
                                          :Theme.of(context).textTheme.bodyText1,
                                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                                      selectedColor: Theme.of(context).colorScheme.secondary,
                                    )
                                ).toList(),
                              );
                            }else{
                              return InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(snapshot.error.toString()),
                                  ),
                                  onTap: (){
                                    setState(() {
                                      _names=null;
                                      _names=_getNames();
                                    });
                                  }
                              );
                            }
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Material(
                            type: MaterialType.transparency,
                            child: Ink(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(1000.0),
                                onTap: (){
                                  FocusScope.of(context).unfocus();
                                  for(Member member in checkboxBool.keys){
                                    checkboxBool[member]=!checkboxBool[member];
                                  }
                                  setState(() {

                                  });
                                },
                                child: Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child: Icon(
                                      Icons.swap_horiz, color: Theme.of(context).colorScheme.secondary
                                  ),
                                ),
                              ),
                            )
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {

                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                amountController.text!='' && checkboxBool.values.where((element)=>element==true).toList().length>0?
                                ((double.tryParse(amountController.text)??0)/checkboxBool.values.where((element)=>element==true).toList().length).toStringAsFixed(2)+'per_person'.tr():
                                '',
                                style: Theme.of(context).textTheme.bodyText2,

                              ),
                            ),
                          ),
                        ),
                        Material(
                            type: MaterialType.transparency,
                            child: Ink(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(1000.0),
                                onTap: (){
                                  FocusScope.of(context).unfocus();
                                  for(Member member in checkboxBool.keys){
                                    checkboxBool[member]=false;
                                  }
                                  setState(() {

                                  });
                                },
                                child: Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child: Icon(
                                      Icons.clear, color: Colors.red
                                  ),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
//            Balances()
            ],

          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: (){
            FocusScope.of(context).unfocus();
            if(_formKey.currentState.validate()){
              if(!checkboxBool.containsValue(true)){
                Widget toast = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.red,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, color: Colors.white,),
                      SizedBox(
                        width: 12.0,
                      ),
                      Flexible(child: Text("person_not_chosen".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                    ],
                  ),
                );
                FlutterToast ft = FlutterToast(context);
                ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                return;
              }
              double amount = double.parse(amountController.text);
              String note = noteController.text;
              List<Member> members = new List<Member>();
              checkboxBool.forEach((Member key, bool value) {
                if(value) members.add(key);
              });
              Function f;
              var param;
//          if(widget.type==ExpenseType.fromSavedExpense){
//            f=_deleteExpense;
//            param=widget.expense.iD;
//          }else{
              f=(par){return true;};
              param=5;
//          }
              f(param);
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  child: FutureSuccessDialog(
                    future: _postNewExpense(members, amount, note),
                    dataTrue:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text("transaction_scf".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white), textAlign: TextAlign.center,)),
                        SizedBox(height: 15,),
                        FlatButton.icon(
                          icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          label: Text('okay'.tr(), style: Theme.of(context).textTheme.button,),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        FlatButton.icon(
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: (){
                            setState(() {
                              amountController.text='';
                              noteController.text='';
                              for(Member key in checkboxBool.keys){
                                checkboxBool[key]=false;
                              }
                            });
                            Navigator.pop(context);
                          },
                          label: Text('add_new'.tr(), style: Theme.of(context).textTheme.button,),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  )
              );

            }



          },
        ),
      ),
    );
  }
}
