class CityModel {
  int id;
  String country;
  String city;
  String state;
  String lat;
  String lng;
  int flaggedAsStored;
  String createdAt;
  String updateAt;
  String resourceUrl;
  CityModel({
    this.id,
    this.city,
    this.resourceUrl,
    this.country,
    this.createdAt,
    this.flaggedAsStored,
    this.lat,
    this.lng,
    this.state,
    this.updateAt,
  });

  CityModel.fromMap(Map json) {
    id = json["id"] ?? 0;
    country = json["country"] ?? '';
    city = json["city"] ?? '';
    state = json["state"] ?? '';
    lat = json["lat"] ?? '';
    lng = json["lng"] ?? '';
    flaggedAsStored = json["flagged_as_stored"] ?? 0;
    createdAt = json["created_at"] ?? '';
    updateAt = json["updated_at"] ?? '';
    resourceUrl = json["resource_url"] ?? '';
  }
}
