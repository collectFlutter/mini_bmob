import '../table/_table.dart';

class BmobPointer<T extends BmobTable> {
  T? subSet;

  BmobPointer(this.subSet);

  Map<String, dynamic> createJson() => {
        "__type": "Pointer",
        "className": subSet?.getBmobTabName(),
        "objectId": subSet?.objectId,
      };

  void fromJson(Map<String, dynamic> json) {
    subSet?.fromJson(json);
  }

  Future<bool> include() async {
    if (subSet == null || subSet!.objectId.isEmpty) return false;
    return subSet!.getInfo();
  }

  Map<String, dynamic> toJson() => subSet?.toJson() ?? {};
}
