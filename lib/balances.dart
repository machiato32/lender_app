import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'person.dart';
import 'config.dart';
import 'login_route.dart';

class Balances extends StatefulWidget {
  @override
  _BalancesState createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  Future<List<Member>> money;

  Future<List<Member>> _getMoney() async {
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute()));
        }
        throw error['error'];
      }
    }catch(_){
      throw 'Hiba';
    }

  }

  @override
  void initState() {
    super.initState();
    money=null;
    money=_getMoney();
  }
  @override
  void didUpdateWidget(Balances oldWidget) {
    super.didUpdateWidget(oldWidget);
    money=null;
    money=_getMoney();
  }

  @override
  Widget build(BuildContext context) {
    return Card(

      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text('Egyenlegek', style: Theme.of(context).textTheme.title,),
            ),
            SizedBox(height: 40),
            Center(
              child: FutureBuilder(
                future: money,
                builder: (context, snapshot){
                  if(snapshot.connectionState==ConnectionState.done){
                    if(snapshot.hasData){
                      return Column(
                          children: _generateBalances(snapshot.data)
                      );
                    }else{
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(snapshot.error.toString()),
                          ),
                          onTap: (){
                            setState(() {
                              money=null;
                              money=_getMoney();
                            });
                          }
                      );
                    }
                  }
                  return CircularProgressIndicator();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _generateBalances(List<Member> members){

    return members.map<Widget>((Member member){
      if(member.userId==currentUser){
        TextStyle style = (Theme.of(context).brightness==Brightness.dark)?Theme.of(context).textTheme.body2:Theme.of(context).textTheme.button;
        return Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness==Brightness.dark)?Colors.transparent:Theme.of(context).colorScheme.secondary,
                  border: Border.all(color: (Theme.of(context).brightness==Brightness.dark)?Theme.of(context).colorScheme.secondary:Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(member.nickname, style: style,),
                    Text(member.balance.toString(), style: style,)
                  ],
                )
            ),
            SizedBox(height: 3,)
          ],
        );
      }
      return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(8),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(member.nickname, style: Theme.of(context).textTheme.body2,),
                  Text(member.balance.toString(), style: Theme.of(context).textTheme.body2,)
                ],
              )
          ),
          SizedBox(height: 3,)
        ],
      );
    }).toList();

  }

}
