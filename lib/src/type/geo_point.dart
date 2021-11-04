class BmobGeoPoint {
  /// 纬度
  double? latitude;

  /// 经度
  double? longitude;

  BmobGeoPoint([this.latitude, this.longitude]) {
    assert(latitude == null || latitude!.abs() <= 90);
    assert(longitude == null || longitude!.abs() <= 180);
  }

  factory BmobGeoPoint.fromJson(Map<String, dynamic> json) {
    return BmobGeoPoint(
      json['latitude'],
      json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        "__type": "GeoPoint",
        "latitude": latitude,
        "longitude": longitude,
      };
}
