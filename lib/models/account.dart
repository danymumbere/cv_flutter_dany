class Account {
  final int id;
  final String email;
  const Account({required this.id, required this.email});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: int.parse(json['id'].toString()),
        email: json['email'].toString(),
      );
}
