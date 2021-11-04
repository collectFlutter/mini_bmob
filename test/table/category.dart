import 'package:mini_bmob/mini_bmob.dart';

class CategoryTable extends BmobTable {
  String? name;
  String? code;

  CategoryTable({this.name, this.code});

  @override
  String getBmobTabName() => "category";

  @override
  Map<String, dynamic> createJson() => {
        ...super.createJson(),
        "name": name,
        "code": code,
      };

  @override
  CategoryTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
    code = json['code'];
    return this;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'code': code,
      };
}
