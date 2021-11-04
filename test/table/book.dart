import 'package:mini_bmob/mini_bmob.dart';

import 'author.dart';
import 'category.dart';

class BookTable extends BmobTable {
  /// 图书名称
  String? name;

  /// 出版时间
  BmobDateTime? pubDate;

  /// 作者
  late BmobRelation<BookTable, AuthorTable> author;

  /// 所属类别
  late BmobPointer<CategoryTable> category;

  BookTable({
    this.name,
    DateTime? pubDate,
    List<AuthorTable> author = const [],
    CategoryTable? category,
  }) {
    assert(category == null || category.objectId != null);
    assert(
        author.isEmpty || !author.any((element) => element.objectId == null));
    if (pubDate != null) {
      this.pubDate = BmobDateTime(pubDate);
    }
    this.author = BmobRelation(
      this,
      AuthorTable(),
      'author',
      (json) => AuthorTable().fromJson(json),
      author,
    );
    this.category = BmobPointer(category);
  }

  @override
  String getBmobTabName() => "book";

  @override
  Map<String, dynamic> createJson() => {
        ...super.createJson(),
        "name": name,
        "pubdate": pubDate?.toJson(),
        "category": category.createJson(),
        "author": author.createJson(),
      };

  @override
  BookTable fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'];
    if (json.containsKey('pubdate')) {
      pubDate = BmobDateTime.fromJson(json['pubdate']);
    }
    if (category.subSet == null) {
      category.subSet = CategoryTable()..fromJson(json['category']);
    } else {
      category.fromJson(json['category']);
    }
    author = BmobRelation(
      this,
      AuthorTable(),
      'author',
      (json) => AuthorTable().fromJson(json),
      [],
    );
    return this;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'author': author.toJson(),
        'category': category.toJson(),
      };
}
