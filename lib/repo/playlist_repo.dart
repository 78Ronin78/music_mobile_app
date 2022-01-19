import 'package:flutter/cupertino.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/preferences_helper.dart';
import 'package:music_mobile_app/models/banner_model.dart';
import 'package:music_mobile_app/models/playlist_model.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'dart:convert';
import 'dart:developer';

class PlayListRepo extends ChangeNotifier {
  ValueNotifier<Map> listPlaylist = ValueNotifier({});
  ValueNotifier<Map> cityMap = ValueNotifier({});
  List<String> periods = [
    "today",
    "tomorrow",
    "this_week",
    "next_week",
    "this_weekend",
    "next_weekend",
    "this_month",
    "next_month",
  ];

  delPlaylist(String period) async {
    String token = userRepo.authenticationToken;

    PreferencesHelper.getString("oldPlayList").then(
      (value) {
        if (value.isNotEmpty)
          ApiRouter.sendRequest(
            method: "delete",
            path: "api/play-list/$value",
            requestParams: {
              "token": token,
            },
          );
      },
    );
    listPlaylist.value.clear();
  }

  getPlaylist(String period, {BannerModel bannerItem}) async {
    String token = userRepo.authenticationToken;
    try {
      PreferencesHelper.getString("oldPlayList").then(
        (value) {
          if (value.isNotEmpty)
            ApiRouter.sendRequest(
              method: "delete",
              path: "api/play-list/$value",
              requestParams: {
                "token": token,
              },
            );
        },
      );
      listPlaylist.value.clear();
    } catch (e) {}
    if (period == "") {
      if (bannerItem.event) {
        ApiRouter.sendRequest(method: 'get', path: 'api/play-list', requestParams: {
          "token": token,
          "client_id": userRepo.clientId,
          "event_id": bannerItem.id.toString(),
        }).then(
          (value) {
            log(value);
            listPlaylist.value.addAll(
              {
                userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]: {
                  period: PlayListModel.fromMap(
                    json.decode(value)["playlist"],
                  )
                }
              },
            );
            PreferencesHelper.setString("oldPlayList",
                listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][period].playlistId);
          },
        );
        return true;
      } else {
        ApiRouter.sendRequest(
          method: 'get',
          path: 'api/promotional-play-list/${bannerItem.id}',
          requestParams: {
            "token": token,
            "client_id": userRepo.clientId,
          },
        ).then(
          (value) {
            listPlaylist.value.addAll(
              {
                userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]: {
                  period: PlayListModel.fromMap(json.decode(value)["playlist"])
                }
              },
            );
            PreferencesHelper.setString("oldPlayList",
                listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][period].playlistId);
          },
        );
        return true;
      }
    } else if (period != "future_follow" && period != "past_follow") {
      ApiRouter.sendRequest(
        method: 'get',
        path: 'api/play-list',
        requestParams: {
          "city_id": "${userRepo.getCityId(userRepo.cities.value[userRepo.cityIdForPlaylist]["name"])}",
          "period": period,
          "token": token,
          "client_id": userRepo.clientId,
        },
      ).then(
        (value) {
          listPlaylist.value.addAll(
            {
              userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]: {
                period: PlayListModel.fromMap(json.decode(value)["playlist"])
              }
            },
          );
          PreferencesHelper.setString("oldPlayList",
              listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][period].playlistId);
        },
      );
      return true;
    } else {
      ApiRouter.sendRequest(
        method: 'get',
        path: 'api/play-list',
        requestParams: {
          "follow": period,
          "token": token,
          "client_id": userRepo.clientId,
        },
      ).then(
        (value) {
          listPlaylist.value.addAll({
            userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]: {
              period: PlayListModel.fromMap(json.decode(value)["playlist"])
            }
          });
          PreferencesHelper.setString("oldPlayList",
              listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][period].playlistId);
        },
      );
      return true;
    }
  }
}

PlayListRepo playListRepo = PlayListRepo();
