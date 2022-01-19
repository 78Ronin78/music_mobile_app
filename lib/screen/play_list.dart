import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:music_mobile_app/helpers/hearts_icons.dart';
import 'package:music_mobile_app/repo/spotify_repo.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_mobile_app/components/big_appbar.dart';
import 'package:music_mobile_app/components/city_carusel.dart';
import 'package:music_mobile_app/components/drawer_element.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/route_arguments.dart';
import 'package:music_mobile_app/screen/player.dart';
import 'package:music_mobile_app/repo/playlist_repo.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class PlayListPage extends StatefulWidget {
  PlayListPage({Key key, this.routeArgument}) : super(key: key);

  final RouteArgument routeArgument;

  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  ScrollController controllerScroll = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  RouteArgument routeArgument;
  ValueNotifier<double> progress = ValueNotifier(0.001);
  List left = [];
  bool buttonStatus = true;

  @override
  void initState() {
    routeArgument = widget.routeArgument;
    super.initState();
    userRepo.cityIdForPlaylist = userRepo.cityIdForHome;
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (userRepo.cityListForCarusel.value.isNotEmpty && userRepo.cityIdForHome != userRepo.cityIdForPlaylist)
          userRepo.buttonCarouselControllerForPlaylist.jumpToPage(userRepo.cityIdForHome);
      },
    );
    playListRepo.getPlaylist(routeArgument.period, bannerItem: routeArgument.bannerItem).then(
      (value) async {
        await Future.delayed(new Duration(seconds: 2));
        refactorBool();
        int i = playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][routeArgument.period]
            .tracks
            .length;
        while (i != 0) {
          left.add(0);
          i--;
        }
        setState(() {});
      },
    );
    //addTimer();
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
        log(value);
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
        playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks.removeAt(i);
        setState(() {

        });
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
        log(value);
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

  // addTimer(){
  //   // time = Timer.periodic(new Duration(seconds: 1), (timer) {
  //   //   SpotifySdk.getPlayerState().then((value) {
  //   //     try {progress.value = value.playbackPosition.toDouble()/value.track.duration.toDouble();}
  //   //     catch (e) {}
  //   //   });
  //   // });
  // }

  String getStringTime(DateTime timeStart) {
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

  refactorBool() {
    buttonStatus = true;
    if (playListRepo
            .listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
            .tracks
            .length <=
        20) buttonStatus = false;
  }

  @override
  void dispose() {
    //time.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _playControll() {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routeArgument.date,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks.length.toString()} треков',
                    style: TextStyle(
                      color: Color(0xFFB8B8B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (status == "pause") {
                  status = "play";
                  setState(() {});
                  spotyRepo.play(playListRepo
                      .listPlaylist
                      .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period]
                      .playListUrl);
                } else if (status == "play") {
                  status = "pause";
                  SpotifySdk.pause();
                  setState(() {});
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFFFFFFF),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child:
                    (status == "play") ? Icon(Icons.pause_rounded, size: 32) : Icon(Icons.play_arrow_rounded, size: 36),
              ),
            ),
          ],
        ),
      );
    }

    Widget loadWholeList() {
      return GestureDetector(
        onTap: () {
          setState(() {
            buttonStatus = false;
          });
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Container(
            width: double.infinity,
            height: 50,
            margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0, 1],
                colors: [Color(0xFF3B6CEB), Color(0xFF112F7D)],
              ),
            ),
            child: Text(
              'Загрузить весь список',
              style: TextStyle(fontSize: 16, height: 2.4, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    Widget _trackPopup(int i) {
      Widget _divider = Container(
        width: double.infinity,
        height: 1,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: Color(0xFFE1E1E1),
      );

      return Container(
        width: 255,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                width: 248,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    width: 1,
                    color: Color(0xFF3B6CEB),
                  ),
                  color: Color(0xFFFFFFFF),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 39,
                      decoration: BoxDecoration(
                        color: Color(0xFF3B6CEB),
                      ),
                      child: Text(
                        getStringTime(DateTime.now()),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 2.1,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        routeArgument.trackNumber = i;
                        //time.cancel();
                        await Navigator.of(context).pushNamed('/concert', arguments: routeArgument);
                        //addTimer();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Icon(
                                Icons.error_outline,
                                size: 18,
                                color: Color(0xFFA0A0A0),
                              ),
                            ),
                            Text(
                              'Информация о концерте',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF222222),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    GestureDetector(
                      onTap: () async {
                        if (playListRepo
                            .listPlaylist
                            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                [widget.routeArgument.period]
                            .tracks[i]
                            .track["is_follow"]) {
                          Navigator.of(context).pop();
                          delTrack(i);
                        } else {
                          Navigator.of(context).pop();
                          addTrack(i);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: playListRepo
                                      .listPlaylist
                                      .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                          [widget.routeArgument.period]
                                      .tracks[i]
                                      .track["is_follow"]
                                  ? Icon(
                                      Hearts.heart2,
                                      color: Colors.blue,
                                      size: 18,
                                    )
                                  : Icon(
                                      Hearts.heart1,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                            ),
                            Text(
                              playListRepo
                                      .listPlaylist
                                      .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                          [widget.routeArgument.period]
                                      .tracks[i]
                                      .track["is_follow"]
                                  ? "Удалить из избранного"
                                  : 'Добавить в избранное',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF222222),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    GestureDetector(
                      onTap: () async {
                        await ApiRouter.sendRequest(
                                method: 'get',
                                path:
                                    'api/event/${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[i].eventId.toString()}')
                            .then((value) {
                          final Event event = Event(
                            title: 'Artist - ${json.decode(value)["Event"][0]["performance"][0]["artist"]["name"]}',
                            description: '',
                            location: 'Place - ${json.decode(value)["Event"][0]["venue"]["name"]}',
                            startDate: DateTime.parse(json.decode(value)["Event"][0]["datetime_start"]),
                            endDate: DateTime.parse(json.decode(value)["Event"][0]["datetime_start"]),
                          );
                          Add2Calendar.addEvent2Cal(event);
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFFA0A0A0),
                              ),
                            ),
                            Text(
                              'Добавить в календарь',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF222222),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    GestureDetector(
                      onTap: () {
                        launch(
                            "https://open.spotify.com/artist/" +
                                playListRepo
                                    .listPlaylist
                                    .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                        [widget.routeArgument.period]
                                    .tracks[i]
                                    .track["artist"]["spotify_artist_id"],
                            forceSafariVC: false,
                            forceWebView: false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Icon(
                                Icons.perm_identity,
                                color: Color(0xFFA0A0A0),
                              ),
                            ),
                            Text(
                              'Профиль артиста',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF222222),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _divider,
                    GestureDetector(
                      onTap: () async {
                        await ApiRouter.sendRequest(
                                method: 'get',
                                path:
                                    'api/event/${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[i].eventId.toString()}')
                            .then((value) {
                          Share.share(
                              "Artist - ${json.decode(value)["Event"][0]["performance"][0]["artist"]["name"]}, Place - ${json.decode(value)["Event"][0]["venue"]["name"]}, Date - ${getStringTime(DateTime.parse(json.decode(value)["Event"][0]["datetime_start"]))}");
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Image.asset(
                                'assets/icons/share_small.png',
                                width: 14,
                                height: 14,
                              ),
                            ),
                            Text(
                              'Поделиться',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF222222),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: BigAppBar(
        background: widget.routeArgument.plate,
        title: widget.routeArgument.title == "Рекламный плэйлист"
            ? playListRepo.listPlaylist.value.isNotEmpty
                ? "${playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks[0].track["artist"]["name"]}"
                : ""
            : widget.routeArgument.title,
        subtitle: widget.routeArgument.subtitle,
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
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          if (snapshot.data != null && snapshot.data.track != null) {
            String picture = "";
            var i = 0;
            if (playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] == null)
              return Center(child: CircularProgressIndicator());
            playListRepo.listPlaylist
                .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][widget.routeArgument.period].tracks
                .forEach(
              (element) {
                if (element.track["name"] == snapshot.data.track.name) picture = element.track["cover"];
                if (picture == "") i++;
              },
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        IgnorePointer(
                          child: CityCarusel(
                            'playlist',
                            cityId: userRepo.cityIdForPlaylist,
                            controller: userRepo.buttonCarouselControllerForPlaylist,
                            onChange: () {
                              setState(() {
                                refactorBool();
                              });
                            },
                            refactor: () {
                              setState(() {
                                refactorBool();
                              });
                            },
                          ),
                        ),
                        playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] !=
                                null
                            ? playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                        [widget.routeArgument.period] !=
                                    null
                                ? _playControll()
                                : Container()
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] !=
                                null
                            ? playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                        [widget.routeArgument.period] !=
                                    null
                                ? ValueListenableBuilder<double>(
                                    valueListenable: progress,
                                    builder: (BuildContext context, double progress2, Widget child) {
                                      return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: playListRepo
                                                    .listPlaylist
                                                    .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                        [widget.routeArgument.period]
                                                    .tracks
                                                    .length <=
                                                20
                                            ? playListRepo
                                                .listPlaylist
                                                .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                    [widget.routeArgument.period]
                                                .tracks
                                                .length
                                            : buttonStatus
                                                ? 20
                                                : playListRepo
                                                    .listPlaylist
                                                    .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                        [widget.routeArgument.period]
                                                    .tracks
                                                    .length,
                                        shrinkWrap: true,
                                        itemBuilder: (ctx, i) {
                                          bool currentTrack = false;
                                          if (snapshot.hasData) if (snapshot.data.track != null) if (snapshot
                                                  .data.track.name ==
                                              playListRepo
                                                  .listPlaylist
                                                  .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                      [widget.routeArgument.period]
                                                  .tracks[i]
                                                  .track["name"]) currentTrack = true;
                                          return Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    color: Colors.red,
                                                    height: 72,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        SizedBox(
                                                          width: 60,
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  AnimatedPositioned(
                                                    left: left[i].toDouble(),
                                                    duration: Duration(milliseconds: 100),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        widget.routeArgument.trackNumber = i;
                                                        //time.cancel();
                                                        await Navigator.of(context)
                                                            .pushNamed('/player', arguments: widget.routeArgument);
                                                        //addTimer();
                                                        setState(() {});
                                                      },
                                                      // onPanUpdate: (DragUpdateDetails details) {
                                                      //   if (widget.routeArgument.period == "future_follow" ||
                                                      //       widget.routeArgument.period == "past_follow") {
                                                      //     if (left[i] + details.delta.dx > -60 &&
                                                      //         left[i] + details.delta.dx < 0)
                                                      //       setState(() {
                                                      //         left[i] = left[i] + details.delta.dx;
                                                      //       });
                                                      //   }
                                                      // },
                                                      // onPanEnd: (DragEndDetails details) {
                                                      //   if (left[i] < -10)
                                                      //     delTrack(i);
                                                      //   else
                                                      //     addTrack(i);
                                                      //   setState(() {
                                                      //     if (left[i] < -10)
                                                      //       left[i] = -60;
                                                      //     else
                                                      //       left[i] = 0;
                                                      //   });
                                                      // },
                                                      child: Column(
                                                        children: [
                                                          // currentTrack? LinearProgressIndicator(
                                                          //   minHeight: 6,
                                                          //   value: progress2,
                                                          //   backgroundColor: Color(0xFFFFFFFF),
                                                          //   valueColor:
                                                          //   new AlwaysStoppedAnimation<Color>(Color(0xFF3B6CEB)),
                                                          // ): Container(),
                                                          Container(
                                                            color: Colors.black,
                                                            height: 72,
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Container(
                                                                      width: 45,
                                                                      height: 45,
                                                                      child: Image.network(
                                                                        playListRepo
                                                                            .listPlaylist
                                                                            .value[userRepo.cities
                                                                                    .value[userRepo.cityIdForPlaylist]
                                                                                ["name"]][widget.routeArgument.period]
                                                                            .tracks[i]
                                                                            .track["cover"],
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 17,
                                                                    ),
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width /
                                                                              3 *
                                                                              1.5,
                                                                          child: Text(
                                                                            playListRepo
                                                                                .listPlaylist
                                                                                .value[userRepo.cities.value[userRepo
                                                                                        .cityIdForPlaylist]["name"]]
                                                                                    [widget.routeArgument.period]
                                                                                .tracks[i]
                                                                                .track["name"],
                                                                            style: TextStyle(
                                                                              color: currentTrack
                                                                                  ? Colors.blue
                                                                                  : Colors.white,
                                                                              fontSize: 16,
                                                                              fontFamily: 'HelveticaNeue',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 4,
                                                                        ),
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width /
                                                                              3 *
                                                                              1.5,
                                                                          child: Text(
                                                                            playListRepo
                                                                                        .listPlaylist
                                                                                        .value[userRepo.cities.value[
                                                                                                    userRepo.cityIdForPlaylist]
                                                                                                ["name"]][
                                                                                            widget.routeArgument.period]
                                                                                        .tracks[i]
                                                                                        .track["artist"] !=
                                                                                    null
                                                                                ? playListRepo
                                                                                    .listPlaylist
                                                                                    .value[userRepo.cities
                                                                                            .value[userRepo.cityIdForPlaylist]
                                                                                        ["name"]][widget.routeArgument.period]
                                                                                    .tracks[i]
                                                                                    .track["artist"]["name"] + " - " + playListRepo
                                                                                .listPlaylist
                                                                                .value[userRepo
                                                                                .cities.value[userRepo.cityIdForPlaylist]
                                                                            ["name"]][widget.routeArgument.period]
                                                                                .tracks[i]
                                                                                .venue["name"]
                                                                                : "",
                                                                            style: TextStyle(
                                                                              color: currentTrack
                                                                                  ? Colors.blue
                                                                                  : Colors.grey,
                                                                              fontSize: 14,
                                                                              fontFamily: 'HelveticaNeue',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                      icon: Icon(
                                                                        Icons.more_vert,
                                                                      ),
                                                                      onPressed: () {
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return Center(
                                                                              child: SizedBox(
                                                                                height: 270,
                                                                                child: _trackPopup(i),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                : CircularProgressIndicator()
                            : CircularProgressIndicator(),
                        buttonStatus ? loadWholeList() : Container(),
                      ],
                    ),
                  ),
                ),
                picture == ""
                    ? Container()
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              routeArgument.trackNumber = i;
                              routeArgument.currentTrack = true;
                              //time.cancel();
                              await Navigator.of(context)
                                  .pushNamed('/player', arguments: routeArgument);
                              //addTimer();
                              setState(() {});
                            },
                            child: Container(
                              color: Color(0xFF1D1D1D),
                              height: 72,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        child: Image.network(picture, fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                        width: 17,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width / 3 * 1.5,
                                            child: Text(
                                              snapshot.data.track.name.toString(),
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 16, fontFamily: 'HelveticaNeue'),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width / 3 * 1.5,
                                            child: Text(
                                              snapshot.data.track.artist.name.toString(),
                                              style: TextStyle(
                                                  color: Colors.grey, fontSize: 14, fontFamily: 'HelveticaNeue'),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          (status == "pause") ? Icons.play_arrow : Icons.pause,
                                        ),
                                        onPressed: () {
                                          if (status == "pause") {
                                            status = "play";
                                            SpotifySdk.resume();
                                            setState(() {});
                                          } else if (status == "play") {
                                            status = "pause";
                                            SpotifySdk.pause();
                                            setState(() {});
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: SizedBox(height: 270, child: _trackPopup(i)),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
              ],
            );
          } else {
            if (playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] == null) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  IgnorePointer(
                    child: CityCarusel(
                      'playlist',
                      cityId: userRepo.cityIdForPlaylist,
                      controller: userRepo.buttonCarouselControllerForPlaylist,
                      onChange: () {
                        setState(() {
                          refactorBool();
                        });
                      },
                      refactor: () {
                        setState(() {
                          refactorBool();
                        });
                      },
                    ),
                  ),
                  playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] != null
                      ? playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                  [widget.routeArgument.period] !=
                              null
                          ? _playControll()
                          : Container()
                      : Container(),
                  // RaisedButton(
                  //     child: Text("setState"),
                  //     onPressed: (){setState(() {});}
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]] != null
                      ? playListRepo.listPlaylist.value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                  [widget.routeArgument.period] !=
                              null
                          ? ValueListenableBuilder<double>(
                              valueListenable: progress,
                              builder: (BuildContext context, double progress2, Widget child) {
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: playListRepo
                                              .listPlaylist
                                              .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                  [widget.routeArgument.period]
                                              .tracks
                                              .length <
                                          20
                                      ? playListRepo
                                          .listPlaylist
                                          .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                              [widget.routeArgument.period]
                                          .tracks
                                          .length
                                      : buttonStatus
                                          ? 20
                                          : playListRepo
                                              .listPlaylist
                                              .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]]
                                                  [widget.routeArgument.period]
                                              .tracks
                                              .length,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, i) {
                                    return Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              color: Colors.red,
                                              height: 72,
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    width: 60,
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AnimatedPositioned(
                                              left: left[i].toDouble(),
                                              duration: Duration(milliseconds: 100),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  widget.routeArgument.trackNumber = i;
                                                  //time.cancel();
                                                  await Navigator.of(context)
                                                      .pushNamed('/player', arguments: widget.routeArgument);
                                                  //addTimer();
                                                  setState(() {});
                                                },
                                                onPanUpdate: (DragUpdateDetails details) {
                                                  if (widget.routeArgument.period == "future_follow" ||
                                                      widget.routeArgument.period == "past_follow") {
                                                    if (left[i] + details.delta.dx > -60 &&
                                                        left[i] + details.delta.dx < 0)
                                                      setState(() {
                                                        left[i] = left[i] + details.delta.dx;
                                                      });
                                                  }
                                                },
                                                onPanEnd: (DragEndDetails details) {
                                                  if (left[i] < -10)
                                                    delTrack(i);
                                                  else
                                                    addTrack(i);
                                                  setState(() {
                                                    if (left[i] < -10)
                                                      left[i] = -60;
                                                    else
                                                      left[i] = 0;
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    // currentTrack? LinearProgressIndicator(
                                                    //   minHeight: 6,
                                                    //   value: progress2,
                                                    //   backgroundColor: Color(0xFFFFFFFF),
                                                    //   valueColor:
                                                    //   new AlwaysStoppedAnimation<Color>(Color(0xFF3B6CEB)),
                                                    // ): Container(),
                                                    Container(
                                                      color: Colors.black,
                                                      height: 72,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                width: 45,
                                                                height: 45,
                                                                child: Image.network(
                                                                  playListRepo
                                                                      .listPlaylist
                                                                      .value[userRepo
                                                                              .cities.value[userRepo.cityIdForPlaylist]
                                                                          ["name"]][widget.routeArgument.period]
                                                                      .tracks[i]
                                                                      .track["cover"],
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 17,
                                                              ),
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 3 * 1.5,
                                                                    child: Text(
                                                                      playListRepo
                                                                          .listPlaylist
                                                                          .value[userRepo.cities
                                                                                  .value[userRepo.cityIdForPlaylist]
                                                                              ["name"]][widget.routeArgument.period]
                                                                          .tracks[i]
                                                                          .track["name"],
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 16,
                                                                        fontFamily: 'HelveticaNeue',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 3 * 1.5,
                                                                    child: Text(
                                                                      playListRepo
                                                                                  .listPlaylist
                                                                                  .value[userRepo.cities.value[userRepo
                                                                                          .cityIdForPlaylist]["name"]]
                                                                                      [widget.routeArgument.period]
                                                                                  .tracks[i]
                                                                                  .track["artist"] !=
                                                                              null
                                                                          ? playListRepo
                                                                              .listPlaylist
                                                                              .value[userRepo.cities
                                                                                      .value[userRepo.cityIdForPlaylist]
                                                                                  ["name"]][widget.routeArgument.period]
                                                                              .tracks[i]
                                                                              .track["artist"]["name"] + " - " + playListRepo
                                                                          .listPlaylist
                                                                          .value[userRepo
                                                                          .cities.value[userRepo.cityIdForPlaylist]
                                                                      ["name"]][widget.routeArgument.period]
                                                                          .tracks[i]
                                                                          .venue["name"]
                                                                          : "",
                                                                      style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                          fontFamily: 'HelveticaNeue'),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.more_vert,
                                                                ),
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return Center(
                                                                        child: SizedBox(
                                                                            height: 270, child: _trackPopup(i)),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          : CircularProgressIndicator()
                      : CircularProgressIndicator(),
                  buttonStatus ? loadWholeList() : Container(),
                ],
              ),
            );
          }
        },
      ),
      endDrawer: DrawerElement(),
    );
  }
}
