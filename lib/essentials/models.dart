import '../config.dart';

class Member {
  double balance;
  String nickname;
  String username;
  String apiToken;
  int memberId;
  bool isAdmin;
  double balanceOriginalCurrency;
  bool isCustomAmount;
  Member({
    this.username,
    this.nickname,
    this.balance,
    this.isAdmin,
    this.memberId,
    this.apiToken,
    this.balanceOriginalCurrency,
    this.isCustomAmount,
  });
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      username: json['username'],
      memberId: json['user_id'],
      nickname: json['nickname'],
      balance: json['balance'] * 1.0,
      isAdmin: json['is_admin'] == 1,
      balanceOriginalCurrency: (json['original_balance'] ?? 0) * 1.0,
      isCustomAmount: json['custom_amount'],
    );
  }

  @override
  String toString() {
    return nickname;
  }

  Map toJson() {
    return {'user_id': memberId};
  }
}

class Group {
  String groupCurrency;
  String groupName;
  int groupId;
  Group({this.groupName, this.groupId, this.groupCurrency});
}

class Reaction {
  String reaction;
  String nickname;
  int userId;
  static List<String> possibleReactions = ['👍', '❤', '😲', '😥', '❗', '❓'];
  Reaction({this.reaction, this.nickname, this.userId});
  factory Reaction.fromJson(Map<String, dynamic> reaction) {
    return Reaction(
        reaction: reaction['reaction'],
        nickname: reaction['user_nickname'],
        userId: reaction['user_id']);
  }
  @override
  String toString() {
    return reaction;
  }
}

class Purchase {
  DateTime updatedAt;
  String buyerUsername, buyerNickname;
  int buyerId;
  List<Member> receivers;
  double totalAmount, totalAmountOriginalCurrency;
  int purchaseId;
  String name;
  List<Reaction> reactions;
  String originalCurrency;

  Purchase({
    this.updatedAt,
    this.buyerUsername,
    this.buyerNickname,
    this.buyerId,
    this.receivers,
    this.totalAmount,
    this.totalAmountOriginalCurrency,
    this.purchaseId,
    this.name,
    this.reactions,
    this.originalCurrency,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      purchaseId: json['purchase_id'],
      name: json['name'],
      updatedAt: json['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['updated_at']).toLocal(),
      originalCurrency: json['original_currency'] ?? currentGroupCurrency,
      buyerUsername: json['buyer_username'],
      buyerId: json['buyer_id'],
      buyerNickname: json['buyer_nickname'],
      totalAmount: (json['total_amount'] * 1.0),
      totalAmountOriginalCurrency: (json['original_total_amount'] ?? 0) * 1.0,
      receivers: json['receivers'].map<Member>((element) => Member.fromJson(element)).toList(),
      reactions:
          json['reactions'].map<Reaction>((reaction) => Reaction.fromJson(reaction)).toList(),
    );
  }
}
