import 'package:mini_bmob/mini_bmob.dart';

class AuthorTable extends BmobTable {
  String? name;
  String? nationality;

  AuthorTable({this.name, this.nationality});

  @override
  String getBmobTabName() => "author";

  @override
  Map<String, dynamic> createJson() => {
        ...super.createJson(),
        'name': name,
        'nationality': nationality,
      };

  @override
  AuthorTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
    nationality = json['nationality'];
    return this;
  }

  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'name': name, 'nationality': nationality};
}
