import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/hearts_icons.dart';
import 'package:music_mobile_app/helpers/route_arguments.dart';
import 'package:music_mobile_app/repo/playlist_repo.dart';
import 'package:music_mobile_app/repo/spotify_repo.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

String status = 'pause';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key, this.routeArgument}) : super(key: key);

  final RouteArgument routeArgument;

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showOverlay = false;
  Timer time;
  ValueNotifier<double> progress = ValueNotifier(0.001);
  double maxTime = 0.001;

  //String currentTrackName;
  delTrack(int i) async {
    await ApiRouter.sendRequest(
      method: 'delete',
      path: 'api/event_follow/${userRepo.clientId}',
      requestParams: {
        "event_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .eventId
            .toString(),
        "track_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .track["id"]
            .toString()
      },
    ).then(
      (value) {
        log(value);
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .track["is_follow"] = false;
        userRepo.changeTiles(
            userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]);
        scaffoldKey?.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content:
                Text('Плейлист удалён', style: TextStyle(color: Colors.black)),
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
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .eventId
            .toString(),
        "track_id": playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .track["id"]
            .toString(),
      },
    ).then(
      (value) {
        log(value);
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks[i]
            .track["is_follow"] = true;
        userRepo.changeTiles(
            userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]);
        scaffoldKey?.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: Text(
              'Плейлист добавлен',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
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

  void playCurrentTrack() {
    int i = 0;
    bool thisPlaylist = false;
    SpotifySdk.getPlayerState().then(
      (value) {
        //currentTrackName = value.track.name;
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks
            .forEach(
          (element) {
            if (element.track["name"] == value.track.name)
              thisPlaylist = true;
            else if (thisPlaylist == false) i++;
          },
        );
        if (thisPlaylist && widget.routeArgument.trackNumber > i) {
          SpotifySdk.resume();
          skipTracksInPlaylist(i);
        } else {
          spotyRepo
              .play(playListRepo
                  .listPlaylist
                  .value[userRepo.cities.value[userRepo.cityIdForPlaylist]
                      ["name"]][widget.routeArgument.period]
                  .playListUrl)
              .then(
            (value) async {
              await Future.delayed(new Duration(seconds: 1));
              skipTracksInPlaylist(0);
            },
          );
        }
        time = Timer.periodic(
          new Duration(seconds: 1),
          (timer) {
            SpotifySdk.getPlayerState().then(
              (value) {
                maxTime = value.track.duration.toDouble();
                progress.value = value.playbackPosition.toDouble();
              },
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    status = "play";
    if (!widget.routeArgument.currentTrack) playCurrentTrack();
    else time = Timer.periodic(
      new Duration(seconds: 1),
          (timer) {
        SpotifySdk.getPlayerState().then(
              (value) {
            maxTime = value.track.duration.toDouble();
            progress.value = value.playbackPosition.toDouble();
          },
        );
      },
    );
  }

  showPopup() {
    setState(() {
      showOverlay = true;
    });
  }

  skipTracksInPlaylist(int i) async {
    while (i != widget.routeArgument.trackNumber) {
      SpotifySdk.skipNext();
      i++;
    }
  }

  goBack() async {
    await SpotifySdk.skipPrevious().then(
      (q) async {
        await Future.delayed(new Duration(seconds: 1));
        SpotifySdk.getPlayerState().then(
          (value) {
            if (value.track.name !=
                playListRepo
                    .listPlaylist
                    .value[userRepo.cities.value[userRepo.cityIdForPlaylist]
                        ["name"]][widget.routeArgument.period]
                    .tracks[widget.routeArgument.trackNumber]
                    .track["name"]) {
              widget.routeArgument.trackNumber--;
              status = 'play';
              setState(() {});
            }
          },
        );
      },
    );
  }

  goNextTrack() async {
    if (playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                [widget.routeArgument.period]
            .tracks
            .length >
        widget.routeArgument.trackNumber + 1) {
      widget.routeArgument.trackNumber++;
      SpotifySdk.skipNext();
      status = 'play';
      setState(() {});
    } else
      setState(
        () {
          spotyRepo.pause().then(
            (value) {
              Navigator.of(context).pop();
            },
          );
        },
      );
  }

  hideOverlay() {
    setState(() {
      showOverlay = false;
    });
  }

  @override
  void dispose() {
    time.cancel();
    super.dispose();
  }

  void rewindTrack(int i) {
    SpotifySdk.seekTo(positionedMilliseconds: i);
  }

  @override
  Widget build(BuildContext context) {
    Widget _timing() {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (BuildContext context, double snapshot, Widget child) {
            return Column(
              children: [
                Slider(
                  value: snapshot,
                  min: 0,
                  max: maxTime,
                  activeColor: Color(0xFF3B6CEB),
                  inactiveColor: Colors.white,
                  divisions: 1000,
                  onChanged: (double value) {
                    rewindTrack(int.parse(value.round().toString()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        (snapshot ~/ 1000 % 60).toString().length == 1
                            ? (snapshot ~/ 1000 ~/ 60).toString() +
                            ":0" +
                            (snapshot ~/ 1000 % 60).toString()
                            : (snapshot ~/ 1000 ~/ 60).toString() +
                            ":" +
                            (snapshot ~/ 1000 % 60).toString(),
                        style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        (maxTime ~/ 1000 % 60).toString().length == 1
                            ? (maxTime ~/ 1000 ~/ 60).toString() +
                            ":0" +
                            (maxTime ~/ 1000 % 60).toString()
                            : (maxTime ~/ 1000 ~/ 60).toString() +
                            ":" +
                            (maxTime ~/ 1000 % 60).toString(),
                        style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return Container(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(0xFF101010),
        child: Stack(
          children: [
            Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.transparent,
              bottomNavigationBar: Container(
                padding: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      iconSize: 32,
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/icons/favorite.png',
                        height: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/icons/share_blue.png',
                        height: 28,
                      ),
                    )
                  ],
                ),
              ),
              appBar: AppBar(
                elevation: 1,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Image.asset(
                    'assets/icons/arrow_back.png',
                    width: 26,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      showPopup();
                    },
                    icon: Icon(Icons.more_vert),
                  )
                ],
              ),
              body: StreamBuilder<PlayerState>(
                stream: SpotifySdk.subscribePlayerState(),
                initialData: PlayerState(
                  null,
                  1,
                  1,
                  null,
                  null,
                  isPaused: false,
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<PlayerState> snapshot) {
                  if (snapshot.data != null && snapshot.data.track != null) {
                    String picture;
                    playListRepo
                        .listPlaylist
                        .value[userRepo.cities.value[userRepo.cityIdForPlaylist]
                            ["name"]][widget.routeArgument.period]
                        .tracks
                        .forEach(
                      (element) {
                        if (element.track["name"] == snapshot.data.track.name)
                          picture = element.track["cover"];
                      },
                    );
                    return ListView(
                      children: [
                        Center(
                          child: Image.network(
                            picture,
                            fit: BoxFit.cover,
                            height: 325,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                snapshot.data.track.name.toString(),
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data.track.artist.name.toString(),
                                style: TextStyle(
                                  color: Color(0xFF3B6CEB),
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        iconSize: 35,
                                        onPressed: () {
                                          goBack();
                                        },
                                        icon: Icon(Icons.fast_rewind),
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        iconSize: 65,
                                        onPressed: () {
                                          if (status == 'play') {
                                            spotyRepo.pause();
                                            status = 'pause';
                                            setState(() {});
                                          } else {
                                            spotyRepo.resume();
                                            status = 'play';
                                            setState(() {});
                                          }
                                        },
                                        icon: Icon(
                                          status == 'play'
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        iconSize: 35,
                                        onPressed: () {
                                          goNextTrack();
                                        },
                                        icon: Icon(Icons.fast_forward),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        _timing()
                      ],
                    );
                  } else
                    return Container();
                },
              ),
            ),
            (showOverlay)
                ? Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: MyCustomAppBar(
                      height: 62,
                      showOverlay: () {
                        hideOverlay();
                      },
                    ),
                    body: AnimatedOpacity(
                      opacity: showOverlay ? 1 : 0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Visibility(
                        visible: showOverlay,
                        child: Overlay(
                          initialEntries: [
                            OverlayEntry(
                              builder: (context) {
                                return CustomPaint(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.1, 0.4],
                                        colors: [
                                          Colors.black,
                                          Color(0x000000).withOpacity(0),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 280,
                                          child: ListTile(
                                            onTap: () async {
                                              time.cancel();
                                              await Navigator.of(context)
                                                  .pushNamed('/concert',
                                                      arguments:
                                                          widget.routeArgument)
                                                  .then(
                                                (value) {
                                                  time = Timer.periodic(
                                                    new Duration(seconds: 1),
                                                    (timer) {
                                                      SpotifySdk
                                                              .getPlayerState()
                                                          .then(
                                                        (value) {
                                                          maxTime = value
                                                              .track.duration
                                                              .toDouble();
                                                          progress.value = value
                                                              .playbackPosition
                                                              .toDouble();
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            leading: Icon(Icons.error_outline),
                                            title: Text(
                                              'Информация о концерте',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 280,
                                          child: ListTile(
                                            onTap: () async {
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
                                                    location:
                                                        'Place - ${json.decode(value)["Event"][0]["venue"]["name"]}',
                                                    startDate: DateTime.parse(
                                                      json.decode(
                                                              value)["Event"][0]
                                                          ["datetime_start"],
                                                    ),
                                                    endDate: DateTime.parse(
                                                      json.decode(
                                                              value)["Event"][0]
                                                          ["datetime_start"],
                                                    ),
                                                  );
                                                  Add2Calendar.addEvent2Cal(
                                                      event);
                                                },
                                              );
                                            },
                                            leading: Icon(Icons.calendar_today),
                                            title: Text(
                                              'Добавить в календарь',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 280,
                                          child: ListTile(
                                            onTap: () {
                                              launch(
                                                  "https://open.spotify.com/artist/" +
                                                      playListRepo
                                                              .listPlaylist
                                                              .value[userRepo
                                                                      .cities.value[
                                                                  userRepo
                                                                      .cityIdForPlaylist]["name"]][widget
                                                                  .routeArgument
                                                                  .period]
                                                              .tracks[widget
                                                                  .routeArgument
                                                                  .trackNumber]
                                                              .track["artist"]
                                                          ["spotify_artist_id"],
                                                  forceSafariVC: false,
                                                  forceWebView: false);
                                            },
                                            leading: Icon(Icons.perm_identity),
                                            title: Text(
                                              'Профиль артиста',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 280,
                                          child: ListTile(
                                            onTap: () async {
                                              if (playListRepo
                                                  .listPlaylist
                                                  .value[userRepo.cities.value[
                                                              userRepo
                                                                  .cityIdForPlaylist]
                                                          ["name"]][
                                                      widget
                                                          .routeArgument.period]
                                                  .tracks[widget.routeArgument
                                                      .trackNumber]
                                                  .track["is_follow"]) {
                                                delTrack(widget
                                                    .routeArgument.trackNumber);
                                                await Future.delayed(
                                                  new Duration(seconds: 1),
                                                );
                                                setState(() {});
                                              } else {
                                                addTrack(widget
                                                    .routeArgument.trackNumber);
                                                await Future.delayed(
                                                  new Duration(seconds: 1),
                                                );
                                                setState(() {});
                                              }
                                            },
                                            leading: playListRepo
                                                    .listPlaylist
                                                    .value[userRepo.cities.value[
                                                                userRepo
                                                                    .cityIdForPlaylist]
                                                            ["name"]][
                                                        widget.routeArgument
                                                            .period]
                                                    .tracks[widget.routeArgument
                                                        .trackNumber]
                                                    .track["is_follow"]
                                                ? Icon(
                                                    Hearts.heart2,
                                                    color: Colors.blue,
                                                  )
                                                : Icon(Hearts.heart1),
                                            title: Text(
                                              playListRepo
                                                      .listPlaylist
                                                      .value[
                                                          userRepo.cities.value[
                                                                  userRepo
                                                                      .cityIdForPlaylist]
                                                              ["name"]][
                                                          widget.routeArgument
                                                              .period]
                                                      .tracks[widget
                                                          .routeArgument
                                                          .trackNumber]
                                                      .track["is_follow"]
                                                  ? "Удалить из избранного"
                                                  : 'Добавить в избранное',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

String getStringTimeNow() {
  DateTime timeStart = DateTime.now();
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

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Function showOverlay;

  const MyCustomAppBar({
    Key key,
    this.parentScaffoldKey,
    this.showOverlay,
    @required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, left: 15, right: 15),
          color: Colors.black,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getStringTimeNow(),
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    iconSize: 40,
                    onPressed: showOverlay,
                    icon: Icon(
                      Icons.close_sharp,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                height: 1,
                color: Color(0xFF2F2F2F),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 1);
}
