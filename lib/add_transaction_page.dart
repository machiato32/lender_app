import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:csocsort_szamla/person.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';

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
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }

  }

  Future<bool> _deleteExpense(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "Transaction_Id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    return response.statusCode==200;
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
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
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
    return Scaffold(
      appBar: AppBar(title: Text('Bevásárlás')),

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
                        Row(
                          children: <Widget>[
                            Text('Végösszeg', style: Theme.of(context).textTheme.body2,),
                            SizedBox(width: 20,),
                            Flexible(
                              child: TextField(
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Ft',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                    //  when the TextFormField in unfocused
                                  ) ,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                  ) ,

                                ),
                                controller: amountController,
                                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                                cursorColor: Theme.of(context).colorScheme.secondary,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  BlacklistingTextInputFormatter(new RegExp('[ \\,=-]')),
                                  WhitelistingTextInputFormatter(RegExp('[0-9\\.]'))
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: <Widget>[
                            Text('Megjegyzés', style: Theme.of(context).textTheme.body2,),
                            SizedBox(width: 15,),
                            Flexible(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: placeholder[_randomInt],
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                  ) ,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                  ) ,

                                ),
                                controller: noteController,
                                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                                cursorColor: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
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
                                        ?Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.onSecondary)
                                        :Theme.of(context).textTheme.body2,
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
                          type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
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
                              (double.parse(amountController.text)/checkboxBool.values.where((element)=>element==true).toList().length).toStringAsFixed(2)+' Ft/fő':
                              '',
                              style: Theme.of(context).textTheme.body1,

                            ),
                          ),
                        ),
                      ),
                      Material(
                          type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
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
          //TODO:validator everywhere
          if(amountController.text==''){
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
                  Flexible(child: Text("Nem adtál meg összeget", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                ],
              ),
            );
            FlutterToast ft = FlutterToast(context);
            ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
            return;
          }
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
                  Flexible(child: Text("Nem választottál ki senkit!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                ],
              ),
            );
            FlutterToast ft = FlutterToast(context);
            ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
            return;
          }

          double amount = double.parse(amountController.text);
          if(amount<0){

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
                  Flexible(child: Text("A végösszeg nem lehet negatív!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                ],
              ),
            );
            FlutterToast ft = FlutterToast(context);
            ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
            return;
          }
          String note = noteController.text;
          List<Member> members = new List<Member>();
          checkboxBool.forEach((Member key, bool value) {
            if(value) members.add(key);
          });
          Function f;
          var param;
          if(widget.type==ExpenseType.fromSavedExpense){
            f=_deleteExpense;
            param=widget.expense.iD;
          }else{
            f=(par){return true;};
            param=5;
          }
          f(param);
          Future<bool> success = _postNewExpense(members, amount, note);
          showDialog(
              barrierDismissible: false,
              context: context,
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: FutureBuilder(
                  future: success,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data){
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text("A tranzakciót sikeresen könyveltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                            SizedBox(height: 15,),
                            FlatButton.icon(
                              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                              onPressed: (){
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              label: Text('Rendben', style: Theme.of(context).textTheme.button,),
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
                              label: Text('Új hozzáadása', style: Theme.of(context).textTheme.button,),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        );
                      }else{
                        return Container(
                          color: Colors.transparent ,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.clear, color: Colors.white,),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
                                color: Colors.red,
                              )
                            ],
                          ),
                        );
                      }
                    }else{
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
          );
        },
      ),
    );
  }
}
