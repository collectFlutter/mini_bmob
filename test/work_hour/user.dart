import 'package:mini_bmob/mini_bmob.dart';

class UserTable extends BmobUserTable {
  String? name;

  UserTable(
      {this.name,
      String? username,
      String? password,
      String? email,
      String? mobilePhoneNumber})
      : super(
            username: username,
            password: password ?? '',
            email: email,
            mobilePhoneNumber: mobilePhoneNumber);

  @override
  UserTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
    return this;
  }

  @override
  Map<String, dynamic> createJson() => {
        ...super.createJson(),
        'name': name,
      };

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
      };
}
