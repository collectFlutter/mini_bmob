import 'package:mini_bmob/src/table/bmob_table.dart';

class Pointer<T extends BmobTable> {
  late T object;

  Pointer(this.object);

  Map<String, dynamic> createJson() => {
        "__type": "Pointer",
        "className": object.getBmobTabName(),
        "objectId": object.objectId,
      };


  T fromJson(Map<String, dynamic> json) {
    object.fromJson(json);
    return object;
  }
}
