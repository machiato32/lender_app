class Member{
  double balance;
  String nickname;
  String userId;
  Member({this.userId, this.nickname, this.balance});
  factory Member.fromJson(Map<String, dynamic> json){
    return Member(
      userId: json['user_id'],
      nickname: json['nickname'],
      balance: json['amount']*1.0
    );
  }

  @override
  String toString() {
    return nickname;
  }

}
class Group{
  String groupName;
  int groupId;
  Group({this.groupName, this.groupId});
}