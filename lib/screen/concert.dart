import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/hearts_icons.dart';
import 'package:music_mobile_app/helpers/route_arguments.dart';
import 'package:music_mobile_app/repo/playlist_repo.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:music_mobile_app/screen/google_maps.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share/share.dart';

LatLng currentLatLng = LatLng(0, 0);

class ConcertPage extends StatefulWidget {
  final RouteArgument routeArgument;
  ConcertPage({Key key, this.routeArgument}) : super(key: key);
  @override
  _ConcertPageState createState() => _ConcertPageState();
}

class _ConcertPageState extends State<ConcertPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  ValueNotifier<Map> concertInfo = ValueNotifier({});
  // MapController _mapController= MapController();

  @override
  void initState() {
    super.initState();
    getConcertData();
  }

  delTrack(int i) async {
    await ApiRouter.sendRequest(
      method: 'delete',
      path: 'api/event_follow/${userRepo.clientId}',
      requestParams: {
        "event_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .eventId
            .toString(),
        "track_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .track["id"]
            .toString()
      },
    ).then(
      (value) {
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .track["is_follow"] = false;
        userRepo.changeTiles(userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]);
        scaffoldKey?.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: Text('Плейлист удалён', style: TextStyle(color: Colors.black)),
            action: SnackBarAction(
              textColor: Colors.black,
              label: 'Скрыть',
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  addTrack(int i) async {
    await ApiRouter.sendRequest(
      method: 'post',
      path: 'api/event_follow',
      requestBody: {
        "client_id": userRepo.clientId,
        "event_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .eventId
            .toString(),
        "track_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .track["id"]
            .toString(),
      },
    ).then(
      (value) {
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks[i]
            .track["is_follow"] = true;
        userRepo.changeTiles(userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]);
        scaffoldKey?.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: Text('Плейлист добавлен', style: TextStyle(color: Colors.black)),
            action: SnackBarAction(
              textColor: Colors.black,
              label: 'Скрыть',
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  getConcertData() async {
    print("айди концерта на странице концерта" + playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[widget.routeArgument.trackNumber].eventId.toString());
    await ApiRouter.sendRequest(
            method: 'get',
            path:
                'api/event/${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[widget.routeArgument.trackNumber].eventId.toString()}')
        .then(
      (value) {
        concertInfo.value = json.decode(value);
        currentLatLng = LatLng(
          double.parse(json.decode(value)["Event"][0]["venue"]["lat"]),
          double.parse(json.decode(value)["Event"][0]["venue"]["lng"]),
        );
        setState(() {});
      },
    );
  }

  String getStringTime(String value) {
    DateTime timeStart = DateTime.parse(value);
    String weekday;
    String month;
    switch (timeStart.weekday) {
      case 1:
        weekday = "Monday".toUpperCase();
        break;
      case 2:
        weekday = "Tuesday".toUpperCase();
        break;
      case 3:
        weekday = "Wednesday".toUpperCase();
        break;
      case 4:
        weekday = "Thursday".toUpperCase();
        break;
      case 5:
        weekday = "Friday".toUpperCase();
        break;
      case 6:
        weekday = "Saturday".toUpperCase();
        break;
      case 7:
        weekday = "Sunday".toUpperCase();
        break;
    }
    switch (timeStart.month) {
      case 1:
        month = "January".toUpperCase();
        break;
      case 2:
        month = "February".toUpperCase();
        break;
      case 3:
        month = "March".toUpperCase();
        break;
      case 4:
        month = "April".toUpperCase();
        break;
      case 5:
        month = "May".toUpperCase();
        break;
      case 6:
        month = "June".toUpperCase();
        break;
      case 7:
        month = "July".toUpperCase();
        break;
      case 8:
        month = "August".toUpperCase();
        break;
      case 9:
        month = "September".toUpperCase();
        break;
      case 10:
        month = "October".toUpperCase();
        break;
      case 11:
        month = "November".toUpperCase();
        break;
      case 12:
        month = "December".toUpperCase();
        break;
    }

    return "$weekday - ${timeStart.day.toString()} $month ${timeStart.year.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 2.5;
    var markers = <Marker>[
      Marker(
        width: 60.0,
        height: 60.0,
        point: currentLatLng,
        builder: (ctx) => Container(
          child: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 50,
          ),
        ),
      ),
    ];
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
        valueListenable: concertInfo,
        builder: (BuildContext context, Map snapshot, Widget child) {
          if (snapshot.isNotEmpty)
            return Column(
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            snapshot["Event"][0]["image"],
                          ),
                        ),
                      ),
                      height: height,
                    ),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                          ],
                          stops: [
                            0.0,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      width: MediaQuery.of(context).size.width,
                      bottom: 0,
                      child: Column(
                        children: [
                          SelectableText(
                            snapshot["Event"][0]["performance"][0]["artist"]["name"],
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SelectableText(
                            snapshot["Event"][0]["venue"]["name"],
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Image.asset(
                          'assets/icons/arrow_back.png',
                          width: 26,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await ApiRouter.sendRequest(
                                      method: 'get',
                                      path:
                                          'api/event/${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[widget.routeArgument.trackNumber].eventId.toString()}')
                                  .then(
                                (value) {
                                  Share.share(
                                      "Artist - ${json.decode(value)["Event"][0]["performance"][0]["artist"]["name"]}, Place - ${json.decode(value)["Event"][0]["venue"]["name"]}, Date - ${getStringTime(json.decode(value)["Event"][0]["datetime_start"])}");
                                },
                              );
                            },
                            icon: Image.asset(
                              'assets/icons/share_1.png',
                              color: Colors.white,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          IconButton(
                            onPressed: () async {
                              if (playListRepo
                                  .listPlaylist
                                  .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                      [widget.routeArgument.period]
                                  .tracks[widget.routeArgument.trackNumber]
                                  .track["is_follow"]) {
                                delTrack(widget.routeArgument.trackNumber);
                                await Future.delayed(
                                  new Duration(seconds: 1),
                                );
                                setState(() {});
                              } else {
                                addTrack(widget.routeArgument.trackNumber);
                                await Future.delayed(
                                  new Duration(seconds: 1),
                                );
                                setState(() {});
                              }
                            },
                            icon: playListRepo
                                    .listPlaylist
                                    .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                        [widget.routeArgument.period]
                                    .tracks[widget.routeArgument.trackNumber]
                                    .track["is_follow"]
                                ? Icon(
                                    Hearts.heart2,
                                    color: Colors.blue,
                                  )
                                : Icon(Hearts.heart1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: SelectableText(
                              getStringTime(
                                snapshot["Event"][0]["datetime_start"],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF112F7D),
                                    Color(0xFF3B6CEB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FlatButton(
                                onPressed: () {},
                                child: Text(
                                  'Купить билеты',
                                  style: TextStyle(fontFamily: 'Gilroy', fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: 65,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFF3B6CEB),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  await ApiRouter.sendRequest(
                                          method: 'get',
                                          path:
                                              'api/event/${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[widget.routeArgument.trackNumber].eventId.toString()}')
                                      .then(
                                    (value) {
                                      final Event event = Event(
                                        title:
                                            'Artist - ${json.decode(value)["Event"][0]["performance"][0]["artist"]["name"]}',
                                        description: '',
                                        location: 'Place - ${json.decode(value)["Event"][0]["venue"]["name"]}',
                                        startDate: DateTime.parse(json.decode(value)["Event"][0]["datetime_start"]),
                                        endDate: DateTime.parse(json.decode(value)["Event"][0]["datetime_start"]),
                                      );
                                      Add2Calendar.addEvent2Cal(event);
                                    },
                                  );
                                },
                                child: Text(
                                  'Добавить в календарь',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              snapshot["Event"][0]["address"] != null
                                  ? Image.asset('assets/icons/marker.png', width: 14)
                                  : Container(),
                              SizedBox(
                                width: 10,
                              ),
                              snapshot["Event"][0]["address"] != null
                                  ? Text('Адрес: ',
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: 14,
                                          color: Color(0xFF3B6CEB),
                                          fontWeight: FontWeight.w800))
                                  : Container(),
                              snapshot["Event"][0]["address"] != null
                                  ? SelectableText(
                                      snapshot["Event"][0]["address"],
                                      style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          SizedBox(height: 10),
                          IgnorePointer(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 175,
                              child: FlutterMap(
                                options: MapOptions(
                                  center: LatLng(
                                    currentLatLng.latitude,
                                    currentLatLng.longitude,
                                  ),
                                  zoom: 16.0,
                                ),
                                layers: [
                                  TileLayerOptions(
                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: ['a', 'b', 'c'],
                                    tileProvider: NonCachingNetworkTileProvider(),
                                  ),
                                  MarkerLayerOptions(markers: markers)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GMap(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Показать на карте ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFFFFFFFF),
                                    size: 16,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          return Container();
        },
      ),
    );
  }
}
