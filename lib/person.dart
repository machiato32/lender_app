class Member{
  double balance;
  String nickname;
  int userId;
  String userName;
  bool isAdmin;
  Member({this.userId, this.userName, this.nickname, this.balance, this.isAdmin});
  factory Member.fromJson(Map<String, dynamic> json){
    return Member(
      userId: json['user_id'],
      userName: json['username'],
      nickname: json['nickname'],
      balance: json['balance']*1.0,
      isAdmin: json['is_admin']==1
    );
  }

  @override
  String toString() {
    return nickname;
  }

  Map toJson(){
    return {
      'user_id':userId
    };
  }

}
class Group{
  String groupName;
  int groupId;
  Group({this.groupName, this.groupId});
}