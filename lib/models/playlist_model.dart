import 'package:music_mobile_app/models/track_model.dart';

class PlayListModel {
  int id;
  int cityId;
  int eventId;
  String playListUrl;
  String period;
  String type;
  String dateCreated;
  String dateUpdate;
  String resourceUrl;
  List<TrackModel> tracks = [];
  String playlistId;

  PlayListModel(
      {this.cityId,
      this.id,
      this.dateCreated,
      this.dateUpdate,
      this.eventId,
      this.period,
      this.tracks,
      this.type,
      this.resourceUrl,
      this.playListUrl});

  PlayListModel.fromMap(Map json) {
    playlistId = json["playlist_id"] ?? "";
    id = json["id"] ?? 0;
    cityId = json["city_id"] ?? 0;
    period = json["period"] ?? "";
    type = json["type"] ?? "";
    playListUrl = json["playlist_url"] ?? "";
    eventId = json["event_id"] ?? 0;
    dateCreated = json["created_at"] ?? "";
    dateUpdate = json["updated_at"] ?? "";
    resourceUrl = json["resource_url"] ?? "";
    if (json["tracks"].length > 0)
      json["tracks"].forEach((element) {
        tracks.add(TrackModel.fromMap(element));
      });
  }
}
