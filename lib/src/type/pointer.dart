import 'package:mini_bmob/src/table/bmob_table.dart';

class Pointer<T extends BmobTable> {
  T? subSet;

  Pointer(this.subSet);

  Map<String, dynamic> createJson() => {
        "__type": "Pointer",
        "className": subSet?.getBmobTabName(),
        "objectId": subSet?.objectId,
      };

  void fromJson(Map<String, dynamic> json) {
    subSet?.fromJson(json);
  }

  Future<bool> include() async {
    if (subSet == null || subSet!.objectId == null) return false;
    return subSet!.getInfo();
  }

  Map<String, dynamic> toJson() => subSet?.toJson() ?? {};
}
