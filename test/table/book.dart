import 'package:mini_bmob/mini_bmob.dart';

import 'author.dart';
import 'category.dart';

class BookTable extends BmobTable {
  String? name;
  late Relation<BookTable, AuthorTable> author;
  late Pointer<CategoryTable> category;

  BookTable({this.name, List<AuthorTable>? author, CategoryTable? category}) {
    assert(category == null || category.objectId != null);
    assert(
        author == null || !author.any((element) => element.objectId == null));
    this.author = Relation(
      this,
      AuthorTable(),
      'author',
      (json) => AuthorTable()..fromJson(json),
      author ?? [],
    );
    this.category = Pointer(category);
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
    name = json['name'];
    if (category.subSet == null) {
      category.subSet = CategoryTable()..fromJson(json['category']);
    } else {
      category.fromJson(json['category']);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'author': author.toJson(),
        'category': category.toJson(),
      };
}
