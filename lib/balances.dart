import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'person.dart';
import 'config.dart';

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
      Map<String, dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        List<Member> members=[];
        for(var member in response2['data']['members']){
          members.add(Member(nickname: member['nickname'], balance: member['balance']*1.0, userId: member['user_id']));
        }
        return members;
      }else{
        throw 'ASD';
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
        return Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(member.nickname, style: Theme.of(context).textTheme.button,),
                    Text(member.balance.toString(), style: Theme.of(context).textTheme.button,)
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
              padding: EdgeInsets.all(4),

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
