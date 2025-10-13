class UserSales {
  final String userId;
  final String userName;

  final int paymentCount;
  final double totalAmount;

  UserSales({
    required this.userId,
    required this.userName,
    required this.paymentCount,
    required this.totalAmount,
  });

  factory UserSales.fromMap(Map<String, dynamic> map) {
    return UserSales(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',

      paymentCount: map['paymentCount'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'paymentCount': paymentCount,
      'totalAmount': totalAmount,
    };
  }
}
