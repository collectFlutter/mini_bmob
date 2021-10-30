import 'package:mini_bmob/mini_bmob.dart';

import 'author.dart';
import 'category.dart';

class Book extends BmobTable {
  String? name;
  Relation<Author>? author;
  Pointer<Category>? category;

  @override
  String getBmobTabName() => "book";

  @override
  Map<String, dynamic> createJson() => {
        "name": name,
        "category": category?.createJson(),
        "author": author?.createJson(),
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    category = Pointer(Category())..fromJson(json);
  }

  Future<bool> queryAuthor() async {

    return false;
  }
}
