class User {
  int? id;
  String username;
  String password;
  double balance;

  User({this.id, required this.username, required this.password, required this.balance});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'balance': balance,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      balance: map['balance'],
    );
  }
}