import 'package:mini_bmob/mini_bmob.dart';

class Category extends BmobTable{
  String? name;

  @override
  String getBmobTabName() => "category";

  @override
  Map<String, dynamic> createJson() =>{
   "name":name,
  };

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
  }

}