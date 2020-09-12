import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'group_objects.dart';

List<PaymentData> paymentsNeeded(List<Member> members){
  List<PaymentData> transactions = new List<PaymentData>();
  List<Member> memberCopy = new List<Member>();
  if (members.where((member) => member.balance != 0).length>0){
    for(Member member in members)
    {
      memberCopy.add(new Member(nickname: member.nickname, userId: member.userId, balance: member.balance));
    }
    do
    {
      memberCopy.sort((member1, member2) => member1.balance.compareTo(member2.balance));
      var minPerson = memberCopy[0];
      var maxPerson = memberCopy[memberCopy.length - 1];
      if (maxPerson.balance > minPerson.balance.abs())
      {
        transactions.add(new PaymentData(payerId: minPerson.userId, payerNickname: minPerson.nickname, takerId: maxPerson.userId, takerNickname: maxPerson.nickname, amount: minPerson.balance.abs()));
        maxPerson.balance -= minPerson.balance.abs();
        minPerson.balance = 0;
      }
      else
      {
        transactions.add(new PaymentData(payerId: minPerson.userId, payerNickname: minPerson.nickname, takerId: maxPerson.userId, takerNickname: maxPerson.nickname, amount: maxPerson.balance.abs()));
        minPerson.balance += maxPerson.balance;
        maxPerson.balance = 0;
      }

    } while (memberCopy.where((member) => member.balance>0).length>0 && memberCopy.where((member) => member.balance<0).length>0);

    return transactions;
  }
  else
  {
    return transactions;
  }
}