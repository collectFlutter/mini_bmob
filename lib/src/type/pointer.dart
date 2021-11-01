import 'package:mini_bmob/src/table/bmob_table.dart';

class Pointer<T extends BmobTable, S extends BmobTable> {
  T? object;
  S? subSet;

  Pointer(this.object,this.subSet);

  Map<String, dynamic> createJson() => {
        "__type": "Pointer",
        "className": subSet?.getBmobTabName(),
        "objectId": subSet?.objectId,
      };

  void fromJson(Map<String, dynamic> json) {
    subSet?.fromJson(json);
  }


}
