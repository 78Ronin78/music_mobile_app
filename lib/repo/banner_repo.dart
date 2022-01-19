import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/models/banner_model.dart';

class BannerRepo extends ChangeNotifier {
  List banners = [];

  updateBanners(int cityId) async {
    banners = [];
    var response = await ApiRouter.sendRequest(
        method: "get", path: "api/promotional-play-list", requestParams: {"city_id": cityId.toString()});
    json.decode(response)["banners"].forEach((value) {
      banners.add(BannerModel.fromJson(value));
    });
    return true;
  }
}

BannerRepo bannerRepo = BannerRepo();
