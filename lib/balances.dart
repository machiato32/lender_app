import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'person.dart';
import 'main.dart';

class Balances extends StatefulWidget {
  @override
  _BalancesState createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  Future<List<Person>> money;

  Future<List<Person>> getMoney() async {
    try{
      http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/');
      List<dynamic> list = jsonDecode(response.body);
      List<Person> people = List<Person>();
      for(var element in list){
        people.add(Person.fromJson(element));
      }
      return people;
    }catch(ex){
      throw 'Hiba a betöltés közben';
    }

  }

  @override
  void initState() {
    super.initState();
    money=null;
    money=getMoney();
  }
  @override
  void didUpdateWidget(Balances oldWidget) {
    super.didUpdateWidget(oldWidget);
    money=null;
    money=getMoney();
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
                          children: _fromFuture(context, snapshot)
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
                              money=getMoney();
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

  List<Widget> _fromFuture(context, snapshot){

    return snapshot.data.map<Widget>((Person person){
      if(person.name==currentUser){
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
                    Text(person.name, style: Theme.of(context).textTheme.button,),
                    Text(person.amount.toString(), style: Theme.of(context).textTheme.button,)
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
                  Text(person.name, style: Theme.of(context).textTheme.body2,),
                  Text(person.amount.toString(), style: Theme.of(context).textTheme.body2,)
                ],
              )
          ),
          SizedBox(height: 3,)
        ],
      );
    }).toList();

  }

}
