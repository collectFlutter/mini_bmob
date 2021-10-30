import 'package:mini_bmob/src/table/bmob_table.dart';
import 'package:mini_bmob/src/type/pointer.dart';

class Relation<T extends BmobTable> {
  late List<T> list;

  Relation(this.list);

  Map<String, dynamic> createJson() => {
        "__op": "AddRelation",
        "objects": list.map((object) => Pointer(object).createJson()).toList()
      };

  Map<String, dynamic> toRemove() => {
        "__op": "RemoveRelation",
        "objects": list.map((object) => Pointer(object).createJson()).toList()
      };
}
