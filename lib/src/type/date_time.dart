class BmobDateTime {
  late DateTime _dateTime;

  BmobDateTime(this._dateTime);

  factory BmobDateTime.fromJson(Map<String, dynamic> json) {
    return BmobDateTime(DateTime.parse(json['iso']));
  }

  Map<String, dynamic> toJson() => {
        "__type": "Date",
        "iso": _dateTime.toIso8601String().replaceAll('T', ' ')
      };
}
