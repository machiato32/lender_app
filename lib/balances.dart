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
    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/');
    List<dynamic> list = jsonDecode(response.body);
    List<Person> people = List<Person>();
    for(var element in list){
      people.add(Person.fromJson(element));
    }
    return people;
  }

  @override
  void initState() {
    super.initState();
    money=getMoney();
  }
  @override
  void didUpdateWidget(Balances oldWidget) {
    money=getMoney();
    super.didUpdateWidget(oldWidget);
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
                  if(snapshot.hasData){
                    return Column(
                      children: _fromFuture(context, snapshot)
                    );
//                    return ConstrainedBox(
//                      constraints: BoxConstraints(maxHeight: 500),
//                      child: ListView.builder(
//                        shrinkWrap: true,
//                        itemCount: snapshot.data.length,
//                        itemBuilder: (BuildContext context, int index){
//                          if(snapshot.data[index].name==name){
//                            return Column(
//                              children: <Widget>[
//                                Container(
//                                    padding: EdgeInsets.all(4),
//                                    decoration: BoxDecoration(
//                                      color: Theme.of(context).colorScheme.secondary,
//                                      borderRadius: BorderRadius.circular(2),
//                                    ),
//                                    child: Row(
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        Text(snapshot.data[index].name, style: Theme.of(context).textTheme.button,),
//                                        Text(snapshot.data[index].amount.toString(), style: Theme.of(context).textTheme.button,)
//                                      ],
//                                    )
//                                ),
//                                SizedBox(height: 3,)
//                              ],
//                            );
//                          }
//                          return Column(
//                            children: <Widget>[
//                              Container(
//                                padding: EdgeInsets.all(4),
//
//                                child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Text(snapshot.data[index].name, style: Theme.of(context).textTheme.body2,),
//                                    Text(snapshot.data[index].amount.toString(), style: Theme.of(context).textTheme.body2,)
//                                  ],
//                                )
//                              ),
//                              SizedBox(height: 3,)
//                            ],
//                          );
//                        },
//                      ),
//                    );
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
      if(person.name==name){
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
