import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/getLocation.dart';
import 'package:music_mobile_app/helpers/preferences_helper.dart';
import 'package:music_mobile_app/models/city_model.dart';
import 'package:music_mobile_app/repo/spotify_repo.dart';
import 'package:music_mobile_app/screen/getSpotifyToken.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class UserRepo extends ChangeNotifier {
  ValueNotifier<List> cities = ValueNotifier([]);
  ValueNotifier<List> playlist = ValueNotifier([]);
  String clientId = "";
  String authenticationToken = "";
  bool firstOpen = true;
  List<String> allCitiesStringList = [];
  List<CityModel> allCitiesModelLIst = [];
  ValueNotifier<List> cityListForCarusel = ValueNotifier([]);
  CarouselController buttonCarouselControllerForHome = CarouselController();
  int cityIdForHome = 0;
  CarouselController buttonCarouselControllerForPlaylist = CarouselController();
  int cityIdForPlaylist = 0;
  DateTime tokenUpdateTime;

  String getCityId(String string) {
    CityModel currentCity =
        allCitiesModelLIst.firstWhere((element) => (element.city + ' , ' + element.state) == string);
    return currentCity.id.toString();
  }

  auth(BuildContext context) async {
    await getCities();
    try {
      cityInit().then(
        (value) async {
          if (value) {
            var location = new Location();
            try {
              await location.requestPermission();
            } on Exception catch (_) {
              print('There was a problem allowing location access');
            }
            getLocatin().then(
              (value) => Navigator.of(context).pushReplacementNamed('/home'),
            );
          } else {
            await userRepo.getCitiesFromLocal();
            PreferencesHelper.getString('firstOpen').then(
              (value) async {
                if (value != null) if (value == "false") {
                  await spotyRepo.connectToSpotifyRemote().then(
                    (value) async {
                      if (value) {
                        if (Platform.isAndroid) {
                          userRepo.authenticationToken = "";
                          await SpotifySdk.getAuthenticationToken(
                            scope: "playlist-modify-public playlist-modify-private",
                            clientId: DotEnv().env['CLIENT_ID'].toString(),
                            redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
                          ).then(
                            (value) {
                              userRepo.tokenUpdateTime = DateTime.now();
                              userRepo.authenticationToken = value;
                            },
                          );
                        }
                        if (Platform.isIOS)
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => GetToken()));

                        // String token  = await SpotifySdk.getAuthenticationToken(scope: "playlist-modify-public playlist-modify-private", clientId: DotEnv().env['CLIENT_ID'].toString(), redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
                        // authenticationToken = token;
                        // tokenUpdateTime = DateTime.now();

                        String auth = await ApiRouter.sendRequest(
                          method: 'post',
                          path: 'api/user',
                          requestBody: {"token": authenticationToken},
                        );
                        userRepo.clientId = (json.decode(auth)["user"]["client_id"]);
                        firstOpen = false;
                        await userRepo.getPlaylistFromLocal().then(
                          (value) async {
                            if (userRepo.cities.value.isNotEmpty) {
                              await userRepo.changeTiles(userRepo.cities.value[userRepo.cityIdForHome]["name"]);
                            }
                          },
                        );
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<bool> cityInit() async {
    List prefList = await PreferencesHelper.getStringList('favorites');
    return (prefList.length < 1 || prefList == null);
  }

  Future getCitiesFromLocal() async {
    List prefMap = [];
    List prefList = await PreferencesHelper.getStringList('favorites');
    prefList.forEach((element) {
      prefMap.add({'name': element});
    });
    cities.value = prefMap;
    cityListForCarusel.value = prefMap;
    cities.notifyListeners();
    if (prefMap != null) return true;
    return false;
  }

  Future<bool> getCities() async {
    allCitiesModelLIst = [];
    allCitiesStringList = [];
    await ApiRouter.sendRequest(method: 'get', path: 'api/city').then(
      (value3) {
        json.decode(value3)['Cities'].forEach(
          (element) {
            allCitiesStringList.add(element['city'] + ' , ' + element['state']);
            allCitiesModelLIst.add(CityModel.fromMap(element));
          },
        );
      },
    );
    return true;
  }

  // getUser() async {
  //   var result = await ApiRouter.sendRequest(
  //     method: 'post',
  //     path: 'api/user',
  //     requestBody: {
  //       "client_id": "u6geqpxlk36scxsxl7ryda9o1",
  //     },
  //   );
  //   return result;
  // }

  Future refactorFavotites() async {
    cities.value = [];
    cityListForCarusel.value = [];
    PreferencesHelper.getStringList('favorites').then(
      (value) {
        value.forEach(
          (element) {
            cities.value.add({'name': element});
            cityListForCarusel.value.add({'name': element});
          },
        );
        if (value.length >= 1) {
          changeTiles(value[0]);
        } else {
          playlist.value.forEach(
            (element) {
              element["tracks"] = false;
            },
          );
          playlist.notifyListeners();
        }

        cityIdForHome = 0;
        cityIdForPlaylist = 0;
        try {
          buttonCarouselControllerForPlaylist.jumpToPage(0);
        } catch (e) {}
        try {
          buttonCarouselControllerForHome.jumpToPage(0);
        } catch (e) {}
      },
    );
    cities.notifyListeners();
  }

  String getStringDate(DateTime date) {
    String month = date.month < 10 ? "0${date.month}" : date.month.toString();
    String day = date.day < 10 ? "0${date.day}" : date.day.toString();
    return "$day.$month";
  }

  DateTime getDayOfWeek(DateTime date, int currentDay) {
    while (date.weekday != currentDay) {
      date = date.add(new Duration(days: 1));
    }
    return date;
  }

  DateTime getLastDayOnMonth(DateTime date) {
    int month = date.month;
    while (date.month == month) {
      date = date.add(new Duration(days: 1));
    }
    return date.subtract(new Duration(days: 1));
  }

  changeTiles(String city) {
    ApiRouter.sendRequest(method: "get", path: "api/city/map/${getCityId(city)}/$clientId").then(
      (value) async {
        playlist.value.forEach(
          (element) {
            element["tracks"] = false;
            if (jsonDecode(value)[0][getCityId(city)][element["dateTime"]]) element["tracks"] = true;
          },
        );
        playlist.notifyListeners();
      },
    );
    return true;
  }

  Future<void> getPlaylistFromLocal() async {
    var response = await rootBundle.loadString("assets/json/playlists.json");
    playlist.value = json.decode(response);
    playlist.notifyListeners();

    DateTime dateNow = DateTime.now();
    DateTime dateForGetWeekend = dateNow;
    if (dateNow.weekday == 7) dateForGetWeekend = dateNow.subtract(new Duration(days: 1));
    DateTime dateForGetWeek = dateNow;
    while (dateForGetWeek.weekday != 1) {
      dateForGetWeek = dateForGetWeek.subtract(new Duration(days: 1));
    }
    int nextMonth = dateNow.month;
    if (nextMonth != 12)
      nextMonth += 1;
    else
      nextMonth = 1;

    playlist.value[0]['firstDate'] = getStringDate(dateNow);
    playlist.value[1]['firstDate'] = getStringDate(dateNow.add(new Duration(days: 1)));
    playlist.value[2]['firstDate'] = getStringDate(getDayOfWeek(dateForGetWeekend, 6));
    playlist.value[2]['secondDate'] = getStringDate(getDayOfWeek(dateForGetWeekend, 7));
    playlist.value[3]['firstDate'] = getStringDate(getDayOfWeek(dateForGetWeekend.add(new Duration(days: 7)), 6));
    playlist.value[3]['secondDate'] = getStringDate(getDayOfWeek(dateForGetWeekend.add(new Duration(days: 7)), 7));
    playlist.value[4]['firstDate'] = getStringDate(dateForGetWeek);
    playlist.value[4]['secondDate'] = getStringDate(getDayOfWeek(dateForGetWeek, 7));
    playlist.value[5]['firstDate'] = getStringDate(dateForGetWeek.add(new Duration(days: 7)));
    playlist.value[5]['secondDate'] = getStringDate(getDayOfWeek(dateForGetWeek.add(new Duration(days: 7)), 7));
    playlist.value[6]['firstDate'] = "01.${dateNow.month < 10 ? "0${dateNow.month}" : dateNow.month}";
    playlist.value[6]['secondDate'] = getStringDate(getLastDayOnMonth(dateNow));
    playlist.value[7]['firstDate'] = "01.${nextMonth < 10 ? "0${nextMonth.toString()}" : nextMonth.toString()}";
    playlist.value[7]['secondDate'] =
        getStringDate(getLastDayOnMonth(getLastDayOnMonth(dateNow).add(new Duration(days: 1))));

    switch (dateNow.month) {
      case 1:
        {
          playlist.value[6]["title"] = "Январь";
          playlist.value[7]["title"] = "Февраль";
        }
        break;
      case 2:
        {
          playlist.value[6]["title"] = "Февраль";
          playlist.value[7]["title"] = "Март";
        }
        break;
      case 3:
        {
          playlist.value[6]["title"] = "Март";
          playlist.value[7]["title"] = "Апрель";
        }
        break;
      case 4:
        {
          playlist.value[6]["title"] = "Апрель";
          playlist.value[7]["title"] = "Май";
        }
        break;
      case 5:
        {
          playlist.value[6]["title"] = "Май";
          playlist.value[7]["title"] = "Июнь";
        }
        break;
      case 6:
        {
          playlist.value[6]["title"] = "Июнь";
          playlist.value[7]["title"] = "Июль";
        }
        break;
      case 7:
        {
          playlist.value[6]["title"] = "Июль";
          playlist.value[7]["title"] = "Август";
        }
        break;
      case 8:
        {
          playlist.value[6]["title"] = "Август";
          playlist.value[7]["title"] = "Сентябрь";
        }
        break;
      case 9:
        {
          playlist.value[6]["title"] = "Сентябрь";
          playlist.value[7]["title"] = "Октябрь";
        }
        break;
      case 10:
        {
          playlist.value[6]["title"] = "Октябрь";
          playlist.value[7]["title"] = "Ноябрь";
        }
        break;
      case 11:
        {
          playlist.value[6]["title"] = "Ноябрь";
          playlist.value[7]["title"] = "Декабрь";
        }
        break;
      case 12:
        {
          playlist.value[6]["title"] = "Декабрь";
          playlist.value[7]["title"] = "Январь";
        }
        break;
    }
  }
}

UserRepo userRepo = UserRepo();
