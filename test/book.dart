import 'package:mini_bmob/mini_bmob.dart';

import 'author.dart';
import 'category.dart';

class Book extends BmobTable {
  String? name;
  late Relation<Book, Author> author;
  late Pointer<Book, Category> category;

  Book({this.name, List<Author>? author, Category? category}) {
    assert(category == null || category.objectId != null);
    assert(
        author == null || !author.any((element) => element.objectId == null));
    this.author = Relation(
      this,
      Author(),
      'author',
      (json) => Author()..fromJson(json),
      author ?? [],
    );
    this.category = Pointer(this, category);
  }

  @override
  String getBmobTabName() => "book";

  @override
  Map<String, dynamic> createJson() => {
        "name": name,
        "category": category.createJson(),
        "author": author.createJson(),
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    if (category.subSet == null) {
      category.subSet = Category()..fromJson(json);
    } else {
      category.fromJson(json);
    }
  }
}
