import 'package:music_mobile_app/models/banner_model.dart';

class RouteArgument {
  String id;
  String title;
  String subtitle;
  int plate;
  String date;
  String period;
  int trackNumber;
  bool currentTrack;
  BannerModel bannerItem;

  RouteArgument({
    this.id,
    this.title,
    this.subtitle,
    this.plate,
    this.date,
    this.period,
    this.currentTrack = false,
    this.trackNumber,
    this.bannerItem,
  });
}
