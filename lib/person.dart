class Person{
  int amount;
  String name;
  Person({this.name, this.amount});

  factory Person.fromJson(Map<String,dynamic> json){
    return Person(
      amount: json['Amount'],
      name: json['Name']
    );
  }
}