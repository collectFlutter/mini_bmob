import 'package:mini_bmob/mini_bmob.dart';

class Author extends BmobTable {
  String? name;
  String? nationality;

  @override
  String getBmobTabName() => "author";

  @override
  Map<String, dynamic> createJson() => {
        'name': name,
        'nationality': nationality,
      };
}
