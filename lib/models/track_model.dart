class TrackModel {
  int id;
  int playListId;
  int trackId;
  int pos;
  int eventId;
  String dateCreate;
  String dateUpdate;
  Map track;
  Map venue;

  TrackModel({
    this.dateUpdate,
    this.id,
    this.dateCreate,
    this.playListId,
    this.pos,
    this.track,
    this.trackId,
    this.eventId,
    this.venue
  });

  TrackModel.fromMap(Map json) {
    eventId = json["event_id"] ?? 0;
    id = json["id"] ?? 0;
    playListId = json["play_list_id"] ?? 0;
    trackId = json["track_id"] ?? 0;
    pos = json["pos"] ?? 0;
    dateCreate = json["created_at"] ?? "";
    dateUpdate = json["updated_at"] ?? "";
    track = json["track"] ?? {};
    venue = json["venue"] ?? {};
  }
}
