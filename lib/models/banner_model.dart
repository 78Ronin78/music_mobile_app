class BannerModel {
  int id;
  String image;
  bool event = false;

  BannerModel();

  BannerModel.fromJson(Map map) {
    id = map["event_id"] ?? map["id"] ?? 0;
    image = map["banner_url"] ?? map["event"]["image"] ?? "";
    if (map.containsKey("event_id")) event = true;
  }
}
